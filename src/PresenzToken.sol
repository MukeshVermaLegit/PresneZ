// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title PresenzToken ($PSZ)
 * @author PRESENZ Team
 * @notice The native utility token for the PRESENZ hyperlocal heatmap platform
 * @dev ERC20 token with minting, burning, and role-based access control
 *
 * Token Specifications:
 * - Total Supply Cap: 1,000,000,000 (1 Billion)
 * - Decimals: 18
 * - Blockchain: Base
 *
 * Token Distribution:
 * - Community Mining Rewards: 40% (400M) - Released over 7 years
 * - Team & Founders: 15% (150M) - 1-year cliff, 3-year vesting
 * - Treasury/DAO: 15% (150M) - Governance-controlled
 * - Investors: 12% (120M) - 6-month cliff, 18-month vesting
 * - Business Development: 8% (80M)
 * - Liquidity & Exchanges: 5% (50M)
 * - Advisors: 3% (30M) - 6-month cliff, 2-year vesting
 * - Marketing & Airdrops: 2% (20M)
 */
contract PresenzToken is ERC20, ERC20Burnable, ERC20Permit, AccessControl, Pausable {
    // ============ Constants ============

    /// @notice Maximum supply cap: 1 billion tokens
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    /// @notice Burn address for transparency
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // ============ Roles ============

    /// @notice Role for minting new tokens (e.g., mining rewards contract)
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role for pausing/unpausing transfers in emergencies
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Role for treasury operations
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    // ============ State Variables ============

    /// @notice Total tokens burned (sent to burn address)
    uint256 public totalBurned;

    /// @notice Treasury address for receiving fees
    address public treasury;

    // ============ Events ============

    /// @notice Emitted when tokens are burned
    event TokensBurned(address indexed burner, uint256 amount);

    /// @notice Emitted when tokens are burned with split to treasury
    event TokensBurnedWithSplit(address indexed spender, uint256 burnedAmount, uint256 treasuryAmount);

    /// @notice Emitted when treasury address is updated
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    // ============ Errors ============

    /// @notice Error when minting would exceed max supply
    error ExceedsMaxSupply(uint256 requested, uint256 available);

    /// @notice Error when treasury address is invalid
    error InvalidTreasuryAddress();

    /// @notice Error when amount is zero
    error ZeroAmount();

    // ============ Constructor ============

    /**
     * @notice Initializes the PRESENZ token
     * @param _treasury Address to receive treasury allocations
     * @param _admin Address with admin privileges
     */
    constructor(address _treasury, address _admin) ERC20("PRESENZ", "PSZ") ERC20Permit("PRESENZ") {
        if (_treasury == address(0)) revert InvalidTreasuryAddress();

        treasury = _treasury;

        // Grant roles to admin
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _admin);
        _grantRole(PAUSER_ROLE, _admin);
        _grantRole(TREASURY_ROLE, _admin);
    }

    // ============ Minting Functions ============

    /**
     * @notice Mints new tokens to a specified address
     * @dev Only callable by addresses with MINTER_ROLE
     * @param to Recipient address
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (amount == 0) revert ZeroAmount();

        uint256 newSupply = totalSupply() + amount;
        if (newSupply > MAX_SUPPLY) {
            revert ExceedsMaxSupply(amount, MAX_SUPPLY - totalSupply());
        }

        _mint(to, amount);
    }

    // ============ Burning Functions ============

    /**
     * @notice Burns tokens and updates burn counter
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) public override {
        if (amount == 0) revert ZeroAmount();

        super.burn(amount);
        totalBurned += amount;

        emit TokensBurned(_msgSender(), amount);
    }

    /**
     * @notice Burns tokens from allowance and updates burn counter
     * @param account Account to burn from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address account, uint256 amount) public override {
        if (amount == 0) revert ZeroAmount();

        super.burnFrom(account, amount);
        totalBurned += amount;

        emit TokensBurned(account, amount);
    }

    /**
     * @notice Burns tokens with a split to treasury (for spending features)
     * @dev Used for radius unlocks, business pins, etc.
     * @param amount Total amount to process
     * @param burnPercentage Percentage to burn (0-100)
     */
    function burnWithTreasurySplit(uint256 amount, uint256 burnPercentage) external {
        if (amount == 0) revert ZeroAmount();
        require(burnPercentage <= 100, "Invalid burn percentage");

        uint256 burnAmount = (amount * burnPercentage) / 100;
        uint256 treasuryAmount = amount - burnAmount;

        // Transfer to burn address for transparency
        if (burnAmount > 0) {
            _transfer(_msgSender(), BURN_ADDRESS, burnAmount);
            totalBurned += burnAmount;
        }

        // Transfer remaining to treasury
        if (treasuryAmount > 0) {
            _transfer(_msgSender(), treasury, treasuryAmount);
        }

        emit TokensBurnedWithSplit(_msgSender(), burnAmount, treasuryAmount);
    }

    // ============ Admin Functions ============

    /**
     * @notice Updates the treasury address
     * @param newTreasury New treasury address
     */
    function setTreasury(address newTreasury) external onlyRole(TREASURY_ROLE) {
        if (newTreasury == address(0)) revert InvalidTreasuryAddress();

        address oldTreasury = treasury;
        treasury = newTreasury;

        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    /**
     * @notice Pauses all token transfers
     * @dev Only callable by addresses with PAUSER_ROLE
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers
     * @dev Only callable by addresses with PAUSER_ROLE
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // ============ View Functions ============

    /**
     * @notice Returns the current circulating supply (total supply - burned)
     * @return Circulating supply
     */
    function circulatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(BURN_ADDRESS);
    }

    /**
     * @notice Returns the remaining mintable supply
     * @return Remaining tokens that can be minted
     */
    function remainingMintableSupply() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    // ============ Internal Overrides ============

    /**
     * @notice Hook that is called before any token transfer
     * @dev Adds pausable functionality
     */
    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        super._update(from, to, value);
    }
}
