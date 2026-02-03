// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenAllocation.sol";
import "../src/PresenzToken.sol";

contract TokenAllocationTest is Test {
    TokenAllocation public allocation;
    PresenzToken public token;

    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public businessDev = makeAddr("businessDev");
    address public liquidityManager = makeAddr("liquidityManager");
    address public marketingManager = makeAddr("marketingManager");
    address public recipient = makeAddr("recipient");

    uint256 public constant BUSINESS_DEV_ALLOCATION = 80_000_000 * 10 ** 18;
    uint256 public constant LIQUIDITY_ALLOCATION = 50_000_000 * 10 ** 18;
    uint256 public constant MARKETING_ALLOCATION = 20_000_000 * 10 ** 18;
    uint256 public constant TOTAL_ALLOCATION = 150_000_000 * 10 ** 18;

    event ContractInitialized(uint256 totalTokens);
    event TokensReleased(
        TokenAllocation.AllocationPool indexed pool, address indexed recipient, uint256 amount, string purpose
    );

    function setUp() public {
        vm.startPrank(admin);

        // Deploy token
        token = new PresenzToken(treasury, admin);

        // Deploy allocation contract
        allocation = new TokenAllocation(address(token), admin);

        // Mint tokens to allocation contract
        token.mint(address(allocation), TOTAL_ALLOCATION);

        // Grant roles
        allocation.grantRole(allocation.BUSINESS_DEV_ROLE(), businessDev);
        allocation.grantRole(allocation.LIQUIDITY_ROLE(), liquidityManager);
        allocation.grantRole(allocation.MARKETING_ROLE(), marketingManager);

        vm.stopPrank();
    }

    // ============ Constructor Tests ============

    function test_constructor_setsToken() public view {
        assertEq(address(allocation.token()), address(token));
    }

    function test_constructor_setsAllocations() public view {
        assertEq(allocation.BUSINESS_DEV_ALLOCATION(), BUSINESS_DEV_ALLOCATION);
        assertEq(allocation.LIQUIDITY_ALLOCATION(), LIQUIDITY_ALLOCATION);
        assertEq(allocation.MARKETING_ALLOCATION(), MARKETING_ALLOCATION);
        assertEq(allocation.TOTAL_ALLOCATION(), TOTAL_ALLOCATION);
    }

    function test_constructor_grantsRoles() public view {
        assertTrue(allocation.hasRole(allocation.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(allocation.hasRole(allocation.BUSINESS_DEV_ROLE(), admin));
        assertTrue(allocation.hasRole(allocation.LIQUIDITY_ROLE(), admin));
        assertTrue(allocation.hasRole(allocation.MARKETING_ROLE(), admin));
    }

    function test_constructor_revertsWithZeroToken() public {
        vm.expectRevert(TokenAllocation.InvalidAddress.selector);
        new TokenAllocation(address(0), admin);
    }

    function test_constructor_revertsWithZeroAdmin() public {
        vm.expectRevert(TokenAllocation.InvalidAddress.selector);
        new TokenAllocation(address(token), address(0));
    }

    // ============ Initialization Tests ============

    function test_initialize_success() public {
        vm.prank(admin);
        vm.expectEmit(true, true, true, true);
        emit ContractInitialized(TOTAL_ALLOCATION);
        allocation.initialize();

        assertTrue(allocation.initialized());
    }

    function test_initialize_revertsIfAlreadyInitialized() public {
        vm.startPrank(admin);
        allocation.initialize();

        vm.expectRevert(TokenAllocation.AlreadyInitialized.selector);
        allocation.initialize();
        vm.stopPrank();
    }

    function test_initialize_revertsWithInsufficientTokens() public {
        // Deploy new allocation without tokens
        vm.startPrank(admin);
        TokenAllocation newAllocation = new TokenAllocation(address(token), admin);

        vm.expectRevert("Insufficient tokens deposited");
        newAllocation.initialize();
        vm.stopPrank();
    }

    // ============ Business Dev Release Tests ============

    function test_releaseBusinessDev_success() public {
        vm.prank(admin);
        allocation.initialize();

        uint256 amount = 1_000_000 * 10 ** 18;

        vm.prank(businessDev);
        vm.expectEmit(true, true, true, true);
        emit TokensReleased(TokenAllocation.AllocationPool.BusinessDevelopment, recipient, amount, "Partnership deal");
        allocation.releaseBusinessDev(recipient, amount, "Partnership deal");

        assertEq(token.balanceOf(recipient), amount);
        assertEq(allocation.businessDevReleased(), amount);
    }

    function test_releaseBusinessDev_revertsIfNotInitialized() public {
        vm.prank(businessDev);
        vm.expectRevert(TokenAllocation.NotInitialized.selector);
        allocation.releaseBusinessDev(recipient, 1000 * 10 ** 18, "Test");
    }

    function test_releaseBusinessDev_revertsIfExceedsAllocation() public {
        vm.prank(admin);
        allocation.initialize();

        vm.prank(businessDev);
        vm.expectRevert(TokenAllocation.InsufficientAllocation.selector);
        allocation.releaseBusinessDev(recipient, BUSINESS_DEV_ALLOCATION + 1, "Test");
    }

    function test_releaseBusinessDev_revertsWithoutRole() public {
        vm.prank(admin);
        allocation.initialize();

        vm.prank(recipient);
        vm.expectRevert();
        allocation.releaseBusinessDev(recipient, 1000 * 10 ** 18, "Test");
    }

    // ============ Liquidity Release Tests ============

    function test_releaseLiquidity_success() public {
        vm.prank(admin);
        allocation.initialize();

        uint256 amount = 5_000_000 * 10 ** 18;

        vm.prank(liquidityManager);
        allocation.releaseLiquidity(recipient, amount, "DEX liquidity");

        assertEq(token.balanceOf(recipient), amount);
        assertEq(allocation.liquidityReleased(), amount);
    }

    function test_releaseLiquidity_revertsIfExceedsAllocation() public {
        vm.prank(admin);
        allocation.initialize();

        vm.prank(liquidityManager);
        vm.expectRevert(TokenAllocation.InsufficientAllocation.selector);
        allocation.releaseLiquidity(recipient, LIQUIDITY_ALLOCATION + 1, "Test");
    }

    // ============ Marketing Release Tests ============

    function test_releaseMarketing_success() public {
        vm.prank(admin);
        allocation.initialize();

        uint256 amount = 2_000_000 * 10 ** 18;

        vm.prank(marketingManager);
        allocation.releaseMarketing(recipient, amount, "Airdrop campaign");

        assertEq(token.balanceOf(recipient), amount);
        assertEq(allocation.marketingReleased(), amount);
    }

    function test_releaseMarketing_revertsIfExceedsAllocation() public {
        vm.prank(admin);
        allocation.initialize();

        vm.prank(marketingManager);
        vm.expectRevert(TokenAllocation.InsufficientAllocation.selector);
        allocation.releaseMarketing(recipient, MARKETING_ALLOCATION + 1, "Test");
    }

    // ============ View Function Tests ============

    function test_getRemainingAllocation() public {
        vm.prank(admin);
        allocation.initialize();

        assertEq(
            allocation.getRemainingAllocation(TokenAllocation.AllocationPool.BusinessDevelopment),
            BUSINESS_DEV_ALLOCATION
        );
        assertEq(allocation.getRemainingAllocation(TokenAllocation.AllocationPool.Liquidity), LIQUIDITY_ALLOCATION);
        assertEq(allocation.getRemainingAllocation(TokenAllocation.AllocationPool.Marketing), MARKETING_ALLOCATION);

        // Release some tokens
        uint256 releaseAmount = 10_000_000 * 10 ** 18;
        vm.prank(businessDev);
        allocation.releaseBusinessDev(recipient, releaseAmount, "Test");

        assertEq(
            allocation.getRemainingAllocation(TokenAllocation.AllocationPool.BusinessDevelopment),
            BUSINESS_DEV_ALLOCATION - releaseAmount
        );
    }

    function test_getPoolInfo() public {
        vm.prank(admin);
        allocation.initialize();

        (uint256 total, uint256 released, uint256 remaining) =
            allocation.getPoolInfo(TokenAllocation.AllocationPool.BusinessDevelopment);
        assertEq(total, BUSINESS_DEV_ALLOCATION);
        assertEq(released, 0);
        assertEq(remaining, BUSINESS_DEV_ALLOCATION);
    }

    function test_getAllocationSummary() public {
        vm.prank(admin);
        allocation.initialize();

        (uint256 totalManaged, uint256 totalReleased, uint256 totalRemaining, uint256 currentBalance) =
            allocation.getAllocationSummary();

        assertEq(totalManaged, TOTAL_ALLOCATION);
        assertEq(totalReleased, 0);
        assertEq(totalRemaining, TOTAL_ALLOCATION);
        assertEq(currentBalance, TOTAL_ALLOCATION);
    }

    // ============ Emergency Withdraw Tests ============

    function test_emergencyWithdraw() public {
        vm.prank(admin);
        allocation.initialize();

        uint256 amount = 1_000_000 * 10 ** 18;

        vm.prank(admin);
        allocation.emergencyWithdraw(recipient, amount);

        assertEq(token.balanceOf(recipient), amount);
    }

    function test_emergencyWithdraw_revertsWithZeroAddress() public {
        vm.prank(admin);
        allocation.initialize();

        vm.prank(admin);
        vm.expectRevert(TokenAllocation.InvalidAddress.selector);
        allocation.emergencyWithdraw(address(0), 1000);
    }

    // ============ Multiple Release Tests ============

    function test_multipleReleases_trackCorrectly() public {
        vm.prank(admin);
        allocation.initialize();

        // Release from each pool
        vm.prank(businessDev);
        allocation.releaseBusinessDev(recipient, 10_000_000 * 10 ** 18, "Deal 1");

        vm.prank(liquidityManager);
        allocation.releaseLiquidity(recipient, 5_000_000 * 10 ** 18, "DEX 1");

        vm.prank(marketingManager);
        allocation.releaseMarketing(recipient, 2_000_000 * 10 ** 18, "Campaign 1");

        // Check totals
        (, uint256 totalReleased,,) = allocation.getAllocationSummary();
        assertEq(totalReleased, 17_000_000 * 10 ** 18);

        assertEq(allocation.businessDevReleased(), 10_000_000 * 10 ** 18);
        assertEq(allocation.liquidityReleased(), 5_000_000 * 10 ** 18);
        assertEq(allocation.marketingReleased(), 2_000_000 * 10 ** 18);
    }

    function test_canReleaseFullAllocation() public {
        vm.prank(admin);
        allocation.initialize();

        // Release full business dev allocation
        vm.prank(businessDev);
        allocation.releaseBusinessDev(recipient, BUSINESS_DEV_ALLOCATION, "Full release");

        assertEq(allocation.getRemainingAllocation(TokenAllocation.AllocationPool.BusinessDevelopment), 0);

        // Should revert on additional release
        vm.prank(businessDev);
        vm.expectRevert(TokenAllocation.InsufficientAllocation.selector);
        allocation.releaseBusinessDev(recipient, 1, "Extra");
    }
}
