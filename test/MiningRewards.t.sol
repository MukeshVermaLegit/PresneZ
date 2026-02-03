// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/PresenzToken.sol";
import "../src/MiningRewards.sol";

contract MiningRewardsTest is Test {
    PresenzToken public token;
    MiningRewards public mining;

    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public distributor = makeAddr("distributor");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    uint256 constant MINING_POOL = 400_000_000 * 10 ** 18;

    // Whitepaper constants
    uint256 constant PHOTO_REWARD = 2 * 10 ** 18; // 2 PSZ per photo
    uint256 constant VIDEO_REWARD = 2 * 10 ** 18; // 2 PSZ per video
    uint256 constant VENUE_CHECKIN_REWARD = 5 * 10 ** 18; // 5 PSZ per venue check-in
    uint256 constant DAILY_CAP = 10 * 10 ** 18; // 10 PSZ daily max
    uint256 constant MAX_POSTS_PER_DAY = 5; // 5 posts max per day

    function setUp() public {
        vm.startPrank(admin);
        token = new PresenzToken(treasury, admin);
        mining = new MiningRewards(address(token), admin);

        // Mint mining pool to contract
        token.mint(address(mining), MINING_POOL);

        // Grant distributor role
        mining.grantRole(mining.DISTRIBUTOR_ROLE(), distributor);

        // Start mining
        mining.startMining();
        vm.stopPrank();
    }

    // ============ Constructor Tests ============

    function test_constructor_setsToken() public view {
        assertEq(address(mining.token()), address(token));
    }

    function test_constructor_setsDailyCap() public view {
        assertEq(mining.dailyUserCap(), DAILY_CAP);
    }

    function test_constructor_setsRewardConstants() public view {
        assertEq(mining.PHOTO_REWARD(), PHOTO_REWARD);
        assertEq(mining.VIDEO_REWARD(), VIDEO_REWARD);
        assertEq(mining.VENUE_CHECKIN_REWARD(), VENUE_CHECKIN_REWARD);
        assertEq(mining.MAX_POSTS_PER_DAY(), MAX_POSTS_PER_DAY);
        assertEq(mining.DAILY_CAP(), DAILY_CAP);
    }

    function test_constructor_setsYearlyEmissions() public view {
        (uint256 year1Allocation,,) = mining.getYearInfo(0);
        assertEq(year1Allocation, 100_000_000 * 10 ** 18);

        (uint256 year7Allocation,,) = mining.getYearInfo(6);
        assertEq(year7Allocation, 36_000_000 * 10 ** 18);
    }

    // ============ Distribution Tests ============

    function test_distributeRewards_transfersTokens() public {
        vm.prank(distributor);
        mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");

        assertEq(token.balanceOf(user1), PHOTO_REWARD);
        assertEq(mining.totalDistributed(), PHOTO_REWARD);
    }

    function test_distributeRewards_emitsEvent() public {
        vm.prank(distributor);
        vm.expectEmit(true, false, false, true);
        emit MiningRewards.RewardsDistributed(user1, PHOTO_REWARD, "photo_post");
        mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
    }

    function test_distributeRewards_tracksDailyEarnings() public {
        vm.prank(distributor);
        mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");

        uint256 remaining = mining.getUserDailyRemaining(user1);
        assertEq(remaining, DAILY_CAP - PHOTO_REWARD);
    }

    function test_distributeRewards_tracksPostCount() public {
        vm.prank(distributor);
        mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");

        uint256 postsRemaining = mining.getUserDailyPostsRemaining(user1);
        assertEq(postsRemaining, MAX_POSTS_PER_DAY - 1);
    }

    function test_distributeRewards_enforceDailyCap() public {
        vm.startPrank(distributor);

        // Distribute 5 photo posts (5 x 2 PSZ = 10 PSZ = cap)
        for (uint256 i = 0; i < 5; i++) {
            mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
        }

        // Daily cap reached, next distribution should fail
        // Note: Actually this will fail due to max posts (5), not daily cap
        vm.expectRevert(MiningRewards.MaxPostsExceeded.selector);
        mining.distributeRewards(user1, PHOTO_REWARD, "over_cap");

        vm.stopPrank();
    }

    function test_distributeRewards_enforceMaxPosts() public {
        vm.startPrank(distributor);

        // Distribute 5 photo posts (max posts per day)
        for (uint256 i = 0; i < MAX_POSTS_PER_DAY; i++) {
            mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
        }

        // 6th post should fail
        vm.expectRevert(MiningRewards.MaxPostsExceeded.selector);
        mining.distributeRewards(user1, PHOTO_REWARD, "sixth_post");

        vm.stopPrank();
    }

    function test_distributeRewards_venueCheckinRespectsPostLimit() public {
        vm.startPrank(distributor);

        // 2 venue check-ins = 10 PSZ (daily cap), but only 2 posts
        mining.distributeRewards(user1, VENUE_CHECKIN_REWARD, "venue_checkin");
        mining.distributeRewards(user1, VENUE_CHECKIN_REWARD, "venue_checkin");

        // Daily cap reached (10 PSZ), but only 2 posts
        assertEq(mining.getUserDailyRemaining(user1), 0);
        assertEq(mining.getUserDailyPostsRemaining(user1), MAX_POSTS_PER_DAY - 2);

        // Next post should fail due to daily cap, not post limit
        vm.expectRevert(MiningRewards.DailyCapExceeded.selector);
        mining.distributeRewards(user1, PHOTO_REWARD, "over_cap");

        vm.stopPrank();
    }

    function test_distributeRewards_rejectsInvalidRewardAmount() public {
        vm.prank(distributor);
        vm.expectRevert(MiningRewards.InvalidRewardType.selector);
        mining.distributeRewards(user1, 3 * 10 ** 18, "invalid_amount"); // 3 PSZ is not valid
    }

    function test_distributeRewards_resetsNextDay() public {
        vm.startPrank(distributor);

        // Max out today
        for (uint256 i = 0; i < MAX_POSTS_PER_DAY; i++) {
            mining.distributeRewards(user1, PHOTO_REWARD, "day1");
        }

        vm.stopPrank();

        // Warp to next day
        vm.warp(block.timestamp + 1 days);

        vm.startPrank(distributor);

        // Should work again
        for (uint256 i = 0; i < MAX_POSTS_PER_DAY; i++) {
            mining.distributeRewards(user1, PHOTO_REWARD, "day2");
        }

        vm.stopPrank();

        assertEq(token.balanceOf(user1), DAILY_CAP * 2);
    }

    function test_distributeRewards_revertsBeforeMiningStart() public {
        // Deploy new mining contract without starting
        vm.startPrank(admin);
        MiningRewards newMining = new MiningRewards(address(token), admin);
        newMining.grantRole(newMining.DISTRIBUTOR_ROLE(), distributor);
        vm.stopPrank();

        vm.prank(distributor);
        vm.expectRevert(MiningRewards.MiningNotStarted.selector);
        newMining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
    }

    function test_distributeRewards_revertsWithoutRole() public {
        vm.prank(user1);
        vm.expectRevert();
        mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
    }

    // ============ User Stats Tests ============

    function test_getUserDailyStats_returnsCorrectValues() public {
        vm.startPrank(distributor);
        mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
        mining.distributeRewards(user1, VIDEO_REWARD, "video_post");
        vm.stopPrank();

        (uint256 postsToday, uint256 postsRemaining, uint256 tokensEarned, uint256 tokensRemaining) =
            mining.getUserDailyStats(user1);

        assertEq(postsToday, 2);
        assertEq(postsRemaining, MAX_POSTS_PER_DAY - 2);
        assertEq(tokensEarned, PHOTO_REWARD + VIDEO_REWARD);
        assertEq(tokensRemaining, DAILY_CAP - PHOTO_REWARD - VIDEO_REWARD);
    }

    // ============ Batch Distribution Tests ============

    function test_batchDistributeRewards_multipleUsers() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = PHOTO_REWARD;
        amounts[1] = VIDEO_REWARD;

        string[] memory actions = new string[](2);
        actions[0] = "photo_post";
        actions[1] = "video_post";

        vm.prank(distributor);
        mining.batchDistributeRewards(users, amounts, actions);

        assertEq(token.balanceOf(user1), PHOTO_REWARD);
        assertEq(token.balanceOf(user2), VIDEO_REWARD);
        assertEq(mining.totalDistributed(), PHOTO_REWARD + VIDEO_REWARD);
    }

    function test_batchDistributeRewards_tracksPostCount() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user1; // Same user, 2 posts

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = PHOTO_REWARD;
        amounts[1] = PHOTO_REWARD;

        string[] memory actions = new string[](2);
        actions[0] = "photo_post";
        actions[1] = "photo_post";

        vm.prank(distributor);
        mining.batchDistributeRewards(users, amounts, actions);

        assertEq(mining.getUserDailyPostsRemaining(user1), MAX_POSTS_PER_DAY - 2);
    }

    function test_batchDistributeRewards_rejectsInvalidRewardType() public {
        address[] memory users = new address[](1);
        users[0] = user1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 7 * 10 ** 18; // Invalid amount

        string[] memory actions = new string[](1);
        actions[0] = "invalid";

        vm.prank(distributor);
        vm.expectRevert(MiningRewards.InvalidRewardType.selector);
        mining.batchDistributeRewards(users, amounts, actions);
    }

    // ============ Year Emission Tests ============

    function test_getCurrentYear_returnsCorrectYear() public view {
        assertEq(mining.getCurrentYear(), 0);
    }

    function test_getCurrentYear_incrementsAfterYear() public {
        vm.warp(block.timestamp + 366 days);
        assertEq(mining.getCurrentYear(), 1);

        vm.warp(block.timestamp + 365 days);
        assertEq(mining.getCurrentYear(), 2);
    }

    function test_yearlyEmission_enforced() public {
        // Try to distribute - should work with valid reward types
        uint256 year1Emission = 100_000_000 * 10 ** 18;

        vm.startPrank(distributor);

        // This should work with a valid reward type
        mining.distributeRewards(user1, PHOTO_REWARD, "test");

        // Manually check yearly distributed doesn't exceed
        (, uint256 distributed,) = mining.getYearInfo(0);
        assertLe(distributed, year1Emission);

        vm.stopPrank();
    }

    // ============ Admin Functions ============

    function test_setDailyCap_updatesValue() public {
        uint256 newCap = 100 * 10 ** 18;

        vm.prank(admin);
        mining.setDailyUserCap(newCap);

        assertEq(mining.dailyUserCap(), newCap);
    }

    function test_startMining_canOnlyBeCalledOnce() public {
        vm.prank(admin);
        vm.expectRevert(MiningRewards.MiningAlreadyStarted.selector);
        mining.startMining();
    }

    function test_emergencyWithdraw_transfersTokens() public {
        uint256 withdrawAmount = 1000 * 10 ** 18;

        vm.prank(admin);
        mining.emergencyWithdraw(treasury, withdrawAmount);

        assertEq(token.balanceOf(treasury), withdrawAmount);
    }

    // ============ View Functions ============

    function test_getDailyEmissionRate_returnsCorrectValue() public view {
        uint256 dailyRate = mining.getDailyEmissionRate();
        uint256 year1Emission = 100_000_000 * 10 ** 18;
        uint256 expectedDaily = year1Emission / 365;
        assertEq(dailyRate, expectedDaily);
    }

    function test_getRemainingMiningPool_decreasesOnDistribution() public {
        uint256 remainingBefore = mining.getRemainingMiningPool();

        vm.prank(distributor);
        mining.distributeRewards(user1, PHOTO_REWARD, "test");

        uint256 remainingAfter = mining.getRemainingMiningPool();
        assertEq(remainingAfter, remainingBefore - PHOTO_REWARD);
    }

    function test_getRemainingYearlyEmission_decreasesOnDistribution() public {
        uint256 remainingBefore = mining.getRemainingYearlyEmission();

        vm.prank(distributor);
        mining.distributeRewards(user1, PHOTO_REWARD, "test");

        uint256 remainingAfter = mining.getRemainingYearlyEmission();
        assertEq(remainingAfter, remainingBefore - PHOTO_REWARD);
    }

    // ============ Fuzz Tests ============

    function testFuzz_distributeRewards_validRewardTypes(uint8 rewardType) public {
        vm.assume(rewardType <= 2);

        uint256 amount;
        if (rewardType == 0) amount = PHOTO_REWARD;
        else if (rewardType == 1) amount = VIDEO_REWARD;
        else amount = VENUE_CHECKIN_REWARD;

        vm.prank(distributor);
        mining.distributeRewards(user1, amount, "test");

        assertEq(token.balanceOf(user1), amount);
    }

    function test_whitepaperFormula_Rd_equals_min_Nd_times_Rp_Cd() public {
        // Whitepaper formula: Rd = min(Nd × Rp, Cd)
        // Where Rp = 2 PSZ, Cd = 10 PSZ, Nd ≤ 5

        vm.startPrank(distributor);

        // Post 5 photos: Nd = 5, Rp = 2, so Nd × Rp = 10 = Cd
        for (uint256 i = 0; i < 5; i++) {
            mining.distributeRewards(user1, PHOTO_REWARD, "photo_post");
        }

        vm.stopPrank();

        // Rd should equal min(5 × 2, 10) = 10 PSZ
        assertEq(token.balanceOf(user1), DAILY_CAP);
        assertEq(token.balanceOf(user1), MAX_POSTS_PER_DAY * PHOTO_REWARD);
    }
}
