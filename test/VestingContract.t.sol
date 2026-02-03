// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/PresenzToken.sol";
import "../src/VestingContract.sol";

contract VestingContractTest is Test {
    PresenzToken public token;
    VestingContract public vesting;

    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public teamMember = makeAddr("teamMember");
    address public investor = makeAddr("investor");
    address public advisor = makeAddr("advisor");

    uint256 constant VESTING_AMOUNT = 10_000_000 * 10 ** 18; // 10M tokens

    function setUp() public {
        vm.startPrank(admin);
        token = new PresenzToken(treasury, admin);
        vesting = new VestingContract(address(token), admin);

        // Mint tokens to vesting contract
        token.mint(address(vesting), VESTING_AMOUNT * 3);
        vm.stopPrank();
    }

    // ============ Constructor Tests ============

    function test_constructor_setsToken() public view {
        assertEq(address(vesting.token()), address(token));
    }

    function test_constructor_setsOwner() public view {
        assertEq(vesting.owner(), admin);
    }

    function test_constructor_revertsWithZeroToken() public {
        vm.expectRevert(VestingContract.InvalidAddress.selector);
        new VestingContract(address(0), admin);
    }

    // ============ Team Vesting Tests ============

    function test_createTeamVesting_createsSchedule() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        (
            uint256 totalAmount,
            uint256 claimedAmount,
            uint256 startTime,
            uint256 cliffEnd,
            uint256 vestingEnd,
            bool revocable,
            bool revoked
        ) = vesting.getVestingSchedule(teamMember);

        assertEq(totalAmount, VESTING_AMOUNT);
        assertEq(claimedAmount, 0);
        assertEq(cliffEnd, startTime + 365 days);
        assertEq(vestingEnd, startTime + 365 days + 3 * 365 days);
        assertTrue(revocable);
        assertFalse(revoked);
    }

    function test_createTeamVesting_nothingClaimableBeforeCliff() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        // Warp to just before cliff ends
        vm.warp(block.timestamp + 364 days);

        uint256 claimable = vesting.getClaimableAmount(teamMember);
        assertEq(claimable, 0);
    }

    function test_createTeamVesting_partialClaimAfterCliff() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        // Warp to 1.5 years (cliff + half of vesting)
        vm.warp(block.timestamp + 365 days + 547 days); // ~1.5 years of vesting

        uint256 claimable = vesting.getClaimableAmount(teamMember);
        // Should be approximately 50% vested
        assertGt(claimable, VESTING_AMOUNT * 49 / 100);
        assertLt(claimable, VESTING_AMOUNT * 51 / 100);
    }

    function test_createTeamVesting_fullClaimAfterVesting() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        // Warp to after full vesting (1yr cliff + 3yr vest)
        vm.warp(block.timestamp + 4 * 365 days + 1);

        uint256 claimable = vesting.getClaimableAmount(teamMember);
        assertEq(claimable, VESTING_AMOUNT);
    }

    // ============ Investor Vesting Tests ============

    function test_createInvestorVesting_createsSchedule() public {
        vm.prank(admin);
        vesting.createInvestorVesting(investor, VESTING_AMOUNT);

        (uint256 totalAmount,, uint256 startTime, uint256 cliffEnd, uint256 vestingEnd, bool revocable,) =
            vesting.getVestingSchedule(investor);

        assertEq(totalAmount, VESTING_AMOUNT);
        assertEq(cliffEnd, startTime + 180 days);
        assertEq(vestingEnd, startTime + 180 days + 540 days);
        assertFalse(revocable); // Investor vesting is NOT revocable
    }

    // ============ Advisor Vesting Tests ============

    function test_createAdvisorVesting_createsSchedule() public {
        vm.prank(admin);
        vesting.createAdvisorVesting(advisor, VESTING_AMOUNT);

        (uint256 totalAmount,, uint256 startTime, uint256 cliffEnd, uint256 vestingEnd, bool revocable,) =
            vesting.getVestingSchedule(advisor);

        assertEq(totalAmount, VESTING_AMOUNT);
        assertEq(cliffEnd, startTime + 180 days);
        assertEq(vestingEnd, startTime + 180 days + 2 * 365 days);
        assertTrue(revocable);
    }

    // ============ Claim Tests ============

    function test_claim_transfersTokens() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        // Warp past cliff and some vesting
        vm.warp(block.timestamp + 365 days + 365 days);

        uint256 claimableBefore = vesting.getClaimableAmount(teamMember);

        vm.prank(teamMember);
        vesting.claim();

        assertEq(token.balanceOf(teamMember), claimableBefore);
        assertEq(vesting.getClaimableAmount(teamMember), 0);
    }

    function test_claim_revertsWhenNothingToClaim() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        // Before cliff
        vm.prank(teamMember);
        vm.expectRevert(VestingContract.NothingToClaim.selector);
        vesting.claim();
    }

    function test_claim_revertsForNonBeneficiary() public {
        vm.prank(makeAddr("random"));
        vm.expectRevert(VestingContract.ScheduleNotFound.selector);
        vesting.claim();
    }

    // ============ Revoke Tests ============

    function test_revokeVesting_returnsUnvestedTokens() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        // Warp past cliff to vest some tokens
        vm.warp(block.timestamp + 365 days + 365 days);

        uint256 vested = vesting.getVestedAmount(teamMember);
        uint256 unvested = VESTING_AMOUNT - vested;

        uint256 adminBalanceBefore = token.balanceOf(admin);

        vm.prank(admin);
        vesting.revokeVesting(teamMember);

        assertEq(token.balanceOf(admin), adminBalanceBefore + unvested);
    }

    function test_revokeVesting_revertsForInvestor() public {
        vm.prank(admin);
        vesting.createInvestorVesting(investor, VESTING_AMOUNT);

        vm.prank(admin);
        vm.expectRevert(VestingContract.NotRevocable.selector);
        vesting.revokeVesting(investor);
    }

    function test_revokeVesting_revertsForNonOwner() public {
        vm.prank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        vm.prank(teamMember);
        vm.expectRevert();
        vesting.revokeVesting(teamMember);
    }

    // ============ Edge Cases ============

    function test_cannotCreateDuplicateSchedule() public {
        vm.startPrank(admin);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);

        vm.expectRevert(VestingContract.ScheduleAlreadyExists.selector);
        vesting.createTeamVesting(teamMember, VESTING_AMOUNT);
        vm.stopPrank();
    }

    function test_cannotCreateScheduleWithZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(VestingContract.InvalidAmount.selector);
        vesting.createTeamVesting(teamMember, 0);
    }

    function test_cannotCreateScheduleWithZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(VestingContract.InvalidAddress.selector);
        vesting.createTeamVesting(address(0), VESTING_AMOUNT);
    }
}
