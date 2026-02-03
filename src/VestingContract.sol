// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title VestingContract
 * @author PRESENZ Team
 * @notice Manages token vesting schedules for Team, Investors, and Advisors
 * @dev Supports cliff periods and linear vesting
 *
 * Vesting Schedules:
 * - Team & Founders: 1-year cliff, 3-year linear vesting (150M)
 * - Investors: 6-month cliff, 18-month linear vesting (120M)
 * - Advisors: 6-month cliff, 2-year linear vesting (30M)
 */
contract VestingContract is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ Structs ============

    struct VestingSchedule {
        uint256 totalAmount; // Total tokens to be vested
        uint256 claimedAmount; // Tokens already claimed
        uint256 startTime; // Vesting start timestamp
        uint256 cliffDuration; // Cliff period in seconds
        uint256 vestingDuration; // Total vesting duration after cliff
        bool revocable; // Whether schedule can be revoked
        bool revoked; // Whether schedule has been revoked
    }

    // ============ State Variables ============

    /// @notice The PSZ token contract
    IERC20 public immutable token;

    /// @notice Mapping of beneficiary to their vesting schedule
    mapping(address => VestingSchedule) public vestingSchedules;

    /// @notice Total tokens allocated to vesting
    uint256 public totalAllocated;

    /// @notice Total tokens claimed from vesting
    uint256 public totalClaimed;

    // ============ Events ============

    event VestingScheduleCreated(
        address indexed beneficiary, uint256 totalAmount, uint256 cliffDuration, uint256 vestingDuration, bool revocable
    );

    event TokensClaimed(address indexed beneficiary, uint256 amount);

    event VestingRevoked(address indexed beneficiary, uint256 unvestedAmount);

    // ============ Errors ============

    error InvalidAddress();
    error InvalidAmount();
    error InvalidDuration();
    error ScheduleAlreadyExists();
    error ScheduleNotFound();
    error ScheduleRevoked();
    error NothingToClaim();
    error NotRevocable();
    error InsufficientBalance();

    // ============ Constructor ============

    /**
     * @notice Initializes the vesting contract
     * @param _token Address of the PSZ token
     * @param _owner Address of the contract owner
     */
    constructor(address _token, address _owner) Ownable(_owner) {
        if (_token == address(0)) revert InvalidAddress();
        token = IERC20(_token);
    }

    // ============ Admin Functions ============

    /**
     * @notice Creates a vesting schedule for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @param totalAmount Total tokens to vest
     * @param startTime Vesting start timestamp
     * @param cliffDuration Cliff period in seconds
     * @param vestingDuration Vesting duration after cliff in seconds
     * @param revocable Whether the schedule can be revoked
     */
    function createVestingSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 vestingDuration,
        bool revocable
    ) external onlyOwner {
        if (beneficiary == address(0)) revert InvalidAddress();
        if (totalAmount == 0) revert InvalidAmount();
        if (vestingDuration == 0) revert InvalidDuration();
        if (vestingSchedules[beneficiary].totalAmount > 0) revert ScheduleAlreadyExists();

        // Ensure contract has enough tokens
        uint256 available = token.balanceOf(address(this)) - (totalAllocated - totalClaimed);
        if (available < totalAmount) revert InsufficientBalance();

        vestingSchedules[beneficiary] = VestingSchedule({
            totalAmount: totalAmount,
            claimedAmount: 0,
            startTime: startTime,
            cliffDuration: cliffDuration,
            vestingDuration: vestingDuration,
            revocable: revocable,
            revoked: false
        });

        totalAllocated += totalAmount;

        emit VestingScheduleCreated(beneficiary, totalAmount, cliffDuration, vestingDuration, revocable);
    }

    /**
     * @notice Creates vesting schedule for team members
     * @dev 1-year cliff, 3-year vesting
     */
    function createTeamVesting(address beneficiary, uint256 totalAmount) external onlyOwner {
        _createSchedule(
            beneficiary,
            totalAmount,
            block.timestamp,
            365 days, // 1-year cliff
            3 * 365 days, // 3-year vesting
            true // Revocable
        );
    }

    /**
     * @notice Creates vesting schedule for investors
     * @dev 6-month cliff, 18-month vesting
     */
    function createInvestorVesting(address beneficiary, uint256 totalAmount) external onlyOwner {
        _createSchedule(
            beneficiary,
            totalAmount,
            block.timestamp,
            180 days, // 6-month cliff
            540 days, // 18-month vesting
            false // Not revocable
        );
    }

    /**
     * @notice Creates vesting schedule for advisors
     * @dev 6-month cliff, 2-year vesting
     */
    function createAdvisorVesting(address beneficiary, uint256 totalAmount) external onlyOwner {
        _createSchedule(
            beneficiary,
            totalAmount,
            block.timestamp,
            180 days, // 6-month cliff
            2 * 365 days, // 2-year vesting
            true // Revocable
        );
    }

    /**
     * @notice Revokes a vesting schedule
     * @param beneficiary Address of the beneficiary
     */
    function revokeVesting(address beneficiary) external onlyOwner {
        VestingSchedule storage schedule = vestingSchedules[beneficiary];

        if (schedule.totalAmount == 0) revert ScheduleNotFound();
        if (!schedule.revocable) revert NotRevocable();
        if (schedule.revoked) revert ScheduleRevoked();

        uint256 vested = _vestedAmount(schedule);
        uint256 unvested = schedule.totalAmount - vested;

        schedule.revoked = true;
        totalAllocated -= unvested;

        // Transfer unvested tokens back to owner
        if (unvested > 0) {
            token.safeTransfer(owner(), unvested);
        }

        emit VestingRevoked(beneficiary, unvested);
    }

    // ============ Beneficiary Functions ============

    /**
     * @notice Claims vested tokens
     */
    function claim() external nonReentrant {
        VestingSchedule storage schedule = vestingSchedules[msg.sender];

        if (schedule.totalAmount == 0) revert ScheduleNotFound();
        if (schedule.revoked) revert ScheduleRevoked();

        uint256 claimable = _claimableAmount(schedule);
        if (claimable == 0) revert NothingToClaim();

        schedule.claimedAmount += claimable;
        totalClaimed += claimable;

        token.safeTransfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    // ============ View Functions ============

    /**
     * @notice Returns the claimable amount for a beneficiary
     */
    function getClaimableAmount(address beneficiary) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[beneficiary];
        if (schedule.totalAmount == 0 || schedule.revoked) return 0;
        return _claimableAmount(schedule);
    }

    /**
     * @notice Returns the vested amount for a beneficiary
     */
    function getVestedAmount(address beneficiary) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[beneficiary];
        if (schedule.totalAmount == 0) return 0;
        return _vestedAmount(schedule);
    }

    /**
     * @notice Returns vesting schedule details for a beneficiary
     */
    function getVestingSchedule(address beneficiary)
        external
        view
        returns (
            uint256 totalAmount,
            uint256 claimedAmount,
            uint256 startTime,
            uint256 cliffEnd,
            uint256 vestingEnd,
            bool revocable,
            bool revoked
        )
    {
        VestingSchedule storage schedule = vestingSchedules[beneficiary];
        return (
            schedule.totalAmount,
            schedule.claimedAmount,
            schedule.startTime,
            schedule.startTime + schedule.cliffDuration,
            schedule.startTime + schedule.cliffDuration + schedule.vestingDuration,
            schedule.revocable,
            schedule.revoked
        );
    }

    // ============ Internal Functions ============

    function _createSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 vestingDuration,
        bool revocable
    ) internal {
        if (beneficiary == address(0)) revert InvalidAddress();
        if (totalAmount == 0) revert InvalidAmount();
        if (vestingSchedules[beneficiary].totalAmount > 0) revert ScheduleAlreadyExists();

        uint256 available = token.balanceOf(address(this)) - (totalAllocated - totalClaimed);
        if (available < totalAmount) revert InsufficientBalance();

        vestingSchedules[beneficiary] = VestingSchedule({
            totalAmount: totalAmount,
            claimedAmount: 0,
            startTime: startTime,
            cliffDuration: cliffDuration,
            vestingDuration: vestingDuration,
            revocable: revocable,
            revoked: false
        });

        totalAllocated += totalAmount;

        emit VestingScheduleCreated(beneficiary, totalAmount, cliffDuration, vestingDuration, revocable);
    }

    function _vestedAmount(VestingSchedule storage schedule) internal view returns (uint256) {
        if (block.timestamp < schedule.startTime + schedule.cliffDuration) {
            return 0;
        }

        uint256 timeAfterCliff = block.timestamp - schedule.startTime - schedule.cliffDuration;

        if (timeAfterCliff >= schedule.vestingDuration) {
            return schedule.totalAmount;
        }

        return (schedule.totalAmount * timeAfterCliff) / schedule.vestingDuration;
    }

    function _claimableAmount(VestingSchedule storage schedule) internal view returns (uint256) {
        return _vestedAmount(schedule) - schedule.claimedAmount;
    }
}
