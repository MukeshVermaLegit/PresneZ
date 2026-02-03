// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MiningRewards
 * @author PRESENZ Team
 * @notice Manages community mining rewards distribution over 7 years
 * @dev Distributes 400M tokens according to the emission schedule
 *
 * Emission Schedule:
 * - Year 1: 100,000,000 (25%) - ~274,000/day
 * - Year 2: 80,000,000 (20%) - ~219,000/day
 * - Year 3: 60,000,000 (15%) - ~164,000/day
 * - Year 4: 48,000,000 (12%) - ~131,000/day
 * - Year 5: 40,000,000 (10%) - ~110,000/day
 * - Year 6: 36,000,000 (9%) - ~99,000/day
 * - Year 7: 36,000,000 (9%) - ~99,000/day
 */
contract MiningRewards is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ Constants ============

    /// @notice Total mining pool allocation: 400M tokens
    uint256 public constant TOTAL_MINING_POOL = 400_000_000 * 10 ** 18;

    /// @notice Number of years for emission schedule
    uint256 public constant EMISSION_YEARS = 7;

    /// @notice Role for distributing rewards
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    /// @notice Reward for photo post: 2 PSZ
    uint256 public constant PHOTO_REWARD = 2 * 10 ** 18;

    /// @notice Reward for video post: 2 PSZ
    uint256 public constant VIDEO_REWARD = 2 * 10 ** 18;

    /// @notice Reward for venue check-in post: 5 PSZ
    uint256 public constant VENUE_CHECKIN_REWARD = 5 * 10 ** 18;

    /// @notice Maximum rewarded posts per day per user
    uint256 public constant MAX_POSTS_PER_DAY = 5;

    /// @notice Daily reward cap per user: 10 PSZ (as per whitepaper)
    uint256 public constant DAILY_CAP = 10 * 10 ** 18;

    // ============ State Variables ============

    /// @notice The PSZ token contract
    IERC20 public immutable token;

    /// @notice Timestamp when mining started
    uint256 public miningStartTime;

    /// @notice Total tokens distributed so far
    uint256 public totalDistributed;

    /// @notice Daily cap per user (10 PSZ base, can be adjusted)
    uint256 public dailyUserCap;

    /// @notice Mapping of user => day => tokens earned that day
    mapping(address => mapping(uint256 => uint256)) public dailyEarnings;

    /// @notice Mapping of user => day => number of rewarded posts that day
    mapping(address => mapping(uint256 => uint256)) public dailyPostCount;

    /// @notice Emission amounts per year
    uint256[7] public yearlyEmissions;

    /// @notice Distributed amounts per year
    uint256[7] public yearlyDistributed;

    // ============ Events ============

    event MiningStarted(uint256 startTime);
    event RewardsDistributed(address indexed user, uint256 amount, string action);
    event DailyCapUpdated(uint256 oldCap, uint256 newCap);
    event EmergencyWithdraw(address indexed to, uint256 amount);

    // ============ Errors ============

    error MiningNotStarted();
    error MiningAlreadyStarted();
    error InvalidAmount();
    error DailyCapExceeded();
    error MaxPostsExceeded();
    error InvalidRewardType();
    error YearlyEmissionExceeded();
    error MiningPoolDepleted();
    error InvalidAddress();

    // ============ Constructor ============

    /**
     * @notice Initializes the mining rewards contract
     * @param _token Address of the PSZ token
     * @param _admin Address of the admin
     */
    constructor(address _token, address _admin) {
        if (_token == address(0) || _admin == address(0)) revert InvalidAddress();

        token = IERC20(_token);
        dailyUserCap = DAILY_CAP; // 10 PSZ as per whitepaper

        // Set yearly emissions according to tokenomics
        yearlyEmissions[0] = 100_000_000 * 10 ** 18; // Year 1: 100M (25%)
        yearlyEmissions[1] = 80_000_000 * 10 ** 18; // Year 2: 80M (20%)
        yearlyEmissions[2] = 60_000_000 * 10 ** 18; // Year 3: 60M (15%)
        yearlyEmissions[3] = 48_000_000 * 10 ** 18; // Year 4: 48M (12%)
        yearlyEmissions[4] = 40_000_000 * 10 ** 18; // Year 5: 40M (10%)
        yearlyEmissions[5] = 36_000_000 * 10 ** 18; // Year 6: 36M (9%)
        yearlyEmissions[6] = 36_000_000 * 10 ** 18; // Year 7: 36M (9%)

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(DISTRIBUTOR_ROLE, _admin);
    }

    // ============ Admin Functions ============

    /**
     * @notice Starts the mining period
     * @dev Can only be called once
     */
    function startMining() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (miningStartTime != 0) revert MiningAlreadyStarted();
        miningStartTime = block.timestamp;
        emit MiningStarted(block.timestamp);
    }

    /**
     * @notice Updates the daily user cap
     * @param newCap New daily cap in wei
     */
    function setDailyUserCap(uint256 newCap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 oldCap = dailyUserCap;
        dailyUserCap = newCap;
        emit DailyCapUpdated(oldCap, newCap);
    }

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

    // ============ Distribution Functions ============

    /**
     * @notice Distributes mining rewards to a user
     * @param user Address of the user
     * @param amount Amount of tokens to distribute
     * @param action Description of the earning action (e.g., "photo_post", "video_post", "venue_checkin")
     */
    function distributeRewards(address user, uint256 amount, string calldata action)
        external
        onlyRole(DISTRIBUTOR_ROLE)
        nonReentrant
    {
        if (miningStartTime == 0) revert MiningNotStarted();
        if (user == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        // Validate reward amount matches allowed types
        if (amount != PHOTO_REWARD && amount != VIDEO_REWARD && amount != VENUE_CHECKIN_REWARD) {
            revert InvalidRewardType();
        }

        uint256 currentYear = getCurrentYear();
        if (currentYear >= EMISSION_YEARS) revert MiningPoolDepleted();

        uint256 today = block.timestamp / 1 days;

        // Check max posts per day (5 posts max)
        uint256 newPostCount = dailyPostCount[user][today] + 1;
        if (newPostCount > MAX_POSTS_PER_DAY) revert MaxPostsExceeded();

        // Check daily cap (10 PSZ max)
        uint256 newDailyTotal = dailyEarnings[user][today] + amount;
        if (newDailyTotal > dailyUserCap) revert DailyCapExceeded();

        // Check yearly emission
        uint256 newYearlyTotal = yearlyDistributed[currentYear] + amount;
        if (newYearlyTotal > yearlyEmissions[currentYear]) revert YearlyEmissionExceeded();

        // Update state
        dailyPostCount[user][today] = newPostCount;
        dailyEarnings[user][today] = newDailyTotal;
        yearlyDistributed[currentYear] += amount;
        totalDistributed += amount;

        // Transfer tokens
        token.safeTransfer(user, amount);

        emit RewardsDistributed(user, amount, action);
    }

    /**
     * @notice Batch distribute rewards to multiple users
     * @param users Array of user addresses
     * @param amounts Array of amounts
     * @param actions Array of action descriptions
     */
    function batchDistributeRewards(address[] calldata users, uint256[] calldata amounts, string[] calldata actions)
        external
        onlyRole(DISTRIBUTOR_ROLE)
        nonReentrant
    {
        require(users.length == amounts.length && amounts.length == actions.length, "Array length mismatch");

        if (miningStartTime == 0) revert MiningNotStarted();

        uint256 currentYear = getCurrentYear();
        if (currentYear >= EMISSION_YEARS) revert MiningPoolDepleted();

        uint256 today = block.timestamp / 1 days;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == address(0)) revert InvalidAddress();
            if (amounts[i] == 0) revert InvalidAmount();

            // Validate reward amount matches allowed types
            if (amounts[i] != PHOTO_REWARD && amounts[i] != VIDEO_REWARD && amounts[i] != VENUE_CHECKIN_REWARD) {
                revert InvalidRewardType();
            }

            // Check max posts per day
            uint256 newPostCount = dailyPostCount[users[i]][today] + 1;
            if (newPostCount > MAX_POSTS_PER_DAY) revert MaxPostsExceeded();

            uint256 newDailyTotal = dailyEarnings[users[i]][today] + amounts[i];
            if (newDailyTotal > dailyUserCap) revert DailyCapExceeded();

            dailyPostCount[users[i]][today] = newPostCount;
            dailyEarnings[users[i]][today] = newDailyTotal;
            totalAmount += amounts[i];

            token.safeTransfer(users[i], amounts[i]);
            emit RewardsDistributed(users[i], amounts[i], actions[i]);
        }

        // Check yearly emission
        uint256 newYearlyTotal = yearlyDistributed[currentYear] + totalAmount;
        if (newYearlyTotal > yearlyEmissions[currentYear]) revert YearlyEmissionExceeded();

        yearlyDistributed[currentYear] += totalAmount;
        totalDistributed += totalAmount;
    }

    // ============ View Functions ============

    /**
     * @notice Returns the current mining year (0-6)
     */
    function getCurrentYear() public view returns (uint256) {
        if (miningStartTime == 0) return 0;
        uint256 elapsed = block.timestamp - miningStartTime;
        uint256 year = elapsed / 365 days;
        return year >= EMISSION_YEARS ? EMISSION_YEARS : year;
    }

    /**
     * @notice Returns the daily emission rate for current year
     */
    function getDailyEmissionRate() external view returns (uint256) {
        uint256 year = getCurrentYear();
        if (year >= EMISSION_YEARS) return 0;
        return yearlyEmissions[year] / 365;
    }

    /**
     * @notice Returns remaining tokens for the current year
     */
    function getRemainingYearlyEmission() external view returns (uint256) {
        uint256 year = getCurrentYear();
        if (year >= EMISSION_YEARS) return 0;
        return yearlyEmissions[year] - yearlyDistributed[year];
    }

    /**
     * @notice Returns user's remaining daily earning capacity
     */
    function getUserDailyRemaining(address user) external view returns (uint256) {
        uint256 today = block.timestamp / 1 days;
        uint256 earned = dailyEarnings[user][today];
        return earned >= dailyUserCap ? 0 : dailyUserCap - earned;
    }

    /**
     * @notice Returns user's remaining posts for today
     */
    function getUserDailyPostsRemaining(address user) external view returns (uint256) {
        uint256 today = block.timestamp / 1 days;
        uint256 posts = dailyPostCount[user][today];
        return posts >= MAX_POSTS_PER_DAY ? 0 : MAX_POSTS_PER_DAY - posts;
    }

    /**
     * @notice Returns user's daily stats
     */
    function getUserDailyStats(address user)
        external
        view
        returns (uint256 postsToday, uint256 postsRemaining, uint256 tokensEarned, uint256 tokensRemaining)
    {
        uint256 today = block.timestamp / 1 days;
        postsToday = dailyPostCount[user][today];
        postsRemaining = postsToday >= MAX_POSTS_PER_DAY ? 0 : MAX_POSTS_PER_DAY - postsToday;
        tokensEarned = dailyEarnings[user][today];
        tokensRemaining = tokensEarned >= dailyUserCap ? 0 : dailyUserCap - tokensEarned;
    }

    /**
     * @notice Returns total remaining tokens in mining pool
     */
    function getRemainingMiningPool() external view returns (uint256) {
        return TOTAL_MINING_POOL - totalDistributed;
    }

    /**
     * @notice Returns emission info for a specific year
     */
    function getYearInfo(uint256 year)
        external
        view
        returns (uint256 allocation, uint256 distributed, uint256 remaining)
    {
        require(year < EMISSION_YEARS, "Invalid year");
        return (yearlyEmissions[year], yearlyDistributed[year], yearlyEmissions[year] - yearlyDistributed[year]);
    }
}
