// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TokenAllocation
 * @author PRESENZ Team
 * @notice Manages token allocations for Business Development, Liquidity, and Marketing pools
 * @dev Provides controlled release of tokens for operational purposes
 *
 * Allocation Pools:
 * - Business Development: 8% (80M) - For venue partnerships & integrations
 * - Liquidity & Exchanges: 5% (50M) - Initial liquidity pools & CEX listings
 * - Marketing & Partnerships: 2% (20M) - User acquisition campaigns
 */
contract TokenAllocation is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ Enums ============

    enum AllocationPool {
        BusinessDevelopment,
        Liquidity,
        Marketing
    }

    // ============ Constants ============

    /// @notice Business Development allocation: 80M tokens (8%)
    uint256 public constant BUSINESS_DEV_ALLOCATION = 80_000_000 * 10 ** 18;

    /// @notice Liquidity allocation: 50M tokens (5%)
    uint256 public constant LIQUIDITY_ALLOCATION = 50_000_000 * 10 ** 18;

    /// @notice Marketing allocation: 20M tokens (2%)
    uint256 public constant MARKETING_ALLOCATION = 20_000_000 * 10 ** 18;

    /// @notice Total allocation managed by this contract: 150M tokens (15%)
    uint256 public constant TOTAL_ALLOCATION = 150_000_000 * 10 ** 18;

    // ============ Roles ============

    /// @notice Role for business development operations
    bytes32 public constant BUSINESS_DEV_ROLE = keccak256("BUSINESS_DEV_ROLE");

    /// @notice Role for liquidity management
    bytes32 public constant LIQUIDITY_ROLE = keccak256("LIQUIDITY_ROLE");

    /// @notice Role for marketing operations
    bytes32 public constant MARKETING_ROLE = keccak256("MARKETING_ROLE");

    // ============ State Variables ============

    /// @notice The PSZ token contract
    IERC20 public immutable token;

    /// @notice Tokens released from Business Development pool
    uint256 public businessDevReleased;

    /// @notice Tokens released from Liquidity pool
    uint256 public liquidityReleased;

    /// @notice Tokens released from Marketing pool
    uint256 public marketingReleased;

    /// @notice Whether the contract has been initialized with tokens
    bool public initialized;

    // ============ Events ============

    event ContractInitialized(uint256 totalTokens);
    event TokensReleased(AllocationPool indexed pool, address indexed recipient, uint256 amount, string purpose);
    event EmergencyWithdraw(address indexed to, uint256 amount);

    // ============ Errors ============

    error InvalidAddress();
    error InvalidAmount();
    error InsufficientAllocation();
    error AlreadyInitialized();
    error NotInitialized();
    error InvalidPool();

    // ============ Constructor ============

    /**
     * @notice Initializes the allocation contract
     * @param _token Address of the PSZ token
     * @param _admin Address of the admin
     */
    constructor(address _token, address _admin) {
        if (_token == address(0) || _admin == address(0)) revert InvalidAddress();

        token = IERC20(_token);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(BUSINESS_DEV_ROLE, _admin);
        _grantRole(LIQUIDITY_ROLE, _admin);
        _grantRole(MARKETING_ROLE, _admin);
    }

    // ============ Initialization ============

    /**
     * @notice Marks the contract as initialized after tokens are transferred
     * @dev Should be called after transferring 150M tokens to this contract
     */
    function initialize() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (initialized) revert AlreadyInitialized();

        uint256 balance = token.balanceOf(address(this));
        require(balance >= TOTAL_ALLOCATION, "Insufficient tokens deposited");

        initialized = true;
        emit ContractInitialized(balance);
    }

    // ============ Release Functions ============

    /**
     * @notice Releases tokens from the Business Development pool
     * @param recipient Address to receive tokens
     * @param amount Amount of tokens to release
     * @param purpose Description of the release purpose
     */
    function releaseBusinessDev(address recipient, uint256 amount, string calldata purpose)
        external
        onlyRole(BUSINESS_DEV_ROLE)
        nonReentrant
    {
        _release(AllocationPool.BusinessDevelopment, recipient, amount, purpose);
    }

    /**
     * @notice Releases tokens from the Liquidity pool
     * @param recipient Address to receive tokens
     * @param amount Amount of tokens to release
     * @param purpose Description of the release purpose
     */
    function releaseLiquidity(address recipient, uint256 amount, string calldata purpose)
        external
        onlyRole(LIQUIDITY_ROLE)
        nonReentrant
    {
        _release(AllocationPool.Liquidity, recipient, amount, purpose);
    }

    /**
     * @notice Releases tokens from the Marketing pool
     * @param recipient Address to receive tokens
     * @param amount Amount of tokens to release
     * @param purpose Description of the release purpose
     */
    function releaseMarketing(address recipient, uint256 amount, string calldata purpose)
        external
        onlyRole(MARKETING_ROLE)
        nonReentrant
    {
        _release(AllocationPool.Marketing, recipient, amount, purpose);
    }

    /**
     * @notice Internal function to release tokens from a pool
     */
    function _release(AllocationPool pool, address recipient, uint256 amount, string calldata purpose) internal {
        if (!initialized) revert NotInitialized();
        if (recipient == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        uint256 remaining = getRemainingAllocation(pool);
        if (amount > remaining) revert InsufficientAllocation();

        if (pool == AllocationPool.BusinessDevelopment) {
            businessDevReleased += amount;
        } else if (pool == AllocationPool.Liquidity) {
            liquidityReleased += amount;
        } else if (pool == AllocationPool.Marketing) {
            marketingReleased += amount;
        }

        token.safeTransfer(recipient, amount);
        emit TokensReleased(pool, recipient, amount, purpose);
    }

    // ============ Admin Functions ============

    /**
     * @notice Emergency withdrawal of tokens
     * @param to Address to send tokens to
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (to == address(0)) revert InvalidAddress();
        token.safeTransfer(to, amount);
        emit EmergencyWithdraw(to, amount);
    }

    // ============ View Functions ============

    /**
     * @notice Returns the remaining allocation for a pool
     */
    function getRemainingAllocation(AllocationPool pool) public view returns (uint256) {
        if (pool == AllocationPool.BusinessDevelopment) {
            return BUSINESS_DEV_ALLOCATION - businessDevReleased;
        } else if (pool == AllocationPool.Liquidity) {
            return LIQUIDITY_ALLOCATION - liquidityReleased;
        } else if (pool == AllocationPool.Marketing) {
            return MARKETING_ALLOCATION - marketingReleased;
        }
        revert InvalidPool();
    }

    /**
     * @notice Returns the total released tokens from a pool
     */
    function getReleasedAmount(AllocationPool pool) public view returns (uint256) {
        if (pool == AllocationPool.BusinessDevelopment) {
            return businessDevReleased;
        } else if (pool == AllocationPool.Liquidity) {
            return liquidityReleased;
        } else if (pool == AllocationPool.Marketing) {
            return marketingReleased;
        }
        revert InvalidPool();
    }

    /**
     * @notice Returns allocation info for a specific pool
     */
    function getPoolInfo(AllocationPool pool)
        external
        view
        returns (uint256 totalAllocation, uint256 released, uint256 remaining)
    {
        if (pool == AllocationPool.BusinessDevelopment) {
            return (BUSINESS_DEV_ALLOCATION, businessDevReleased, BUSINESS_DEV_ALLOCATION - businessDevReleased);
        } else if (pool == AllocationPool.Liquidity) {
            return (LIQUIDITY_ALLOCATION, liquidityReleased, LIQUIDITY_ALLOCATION - liquidityReleased);
        } else if (pool == AllocationPool.Marketing) {
            return (MARKETING_ALLOCATION, marketingReleased, MARKETING_ALLOCATION - marketingReleased);
        }
        revert InvalidPool();
    }

    /**
     * @notice Returns summary of all allocations
     */
    function getAllocationSummary()
        external
        view
        returns (uint256 totalManaged, uint256 totalReleased, uint256 totalRemaining, uint256 currentBalance)
    {
        totalManaged = TOTAL_ALLOCATION;
        totalReleased = businessDevReleased + liquidityReleased + marketingReleased;
        totalRemaining = totalManaged - totalReleased;
        currentBalance = token.balanceOf(address(this));
    }
}
