// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/PresenzToken.sol";

contract PresenzTokenTest is Test {
    PresenzToken public token;

    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public minter = makeAddr("minter");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    event TokensBurned(address indexed burner, uint256 amount);
    event TokensBurnedWithSplit(address indexed spender, uint256 burnedAmount, uint256 treasuryAmount);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    function setUp() public {
        vm.prank(admin);
        token = new PresenzToken(treasury, admin);
    }

    // ============ Constructor Tests ============

    function test_constructor_setsCorrectName() public view {
        assertEq(token.name(), "PRESENZ");
    }

    function test_constructor_setsCorrectSymbol() public view {
        assertEq(token.symbol(), "PSZ");
    }

    function test_constructor_setsCorrectDecimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_constructor_setsTreasury() public view {
        assertEq(token.treasury(), treasury);
    }

    function test_constructor_setsMaxSupply() public view {
        assertEq(token.MAX_SUPPLY(), MAX_SUPPLY);
    }

    function test_constructor_grantsAdminRole() public view {
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_constructor_grantsMinterRole() public view {
        assertTrue(token.hasRole(token.MINTER_ROLE(), admin));
    }

    function test_constructor_grantsPauserRole() public view {
        assertTrue(token.hasRole(token.PAUSER_ROLE(), admin));
    }

    function test_constructor_grantsTreasuryRole() public view {
        assertTrue(token.hasRole(token.TREASURY_ROLE(), admin));
    }

    function test_constructor_revertsWithZeroTreasury() public {
        vm.expectRevert(PresenzToken.InvalidTreasuryAddress.selector);
        new PresenzToken(address(0), admin);
    }

    // ============ Minting Tests ============

    function test_mint_successfullyMintsTokens() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, amount);

        assertEq(token.balanceOf(user1), amount);
        assertEq(token.totalSupply(), amount);
    }

    function test_mint_revertsWithZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(PresenzToken.ZeroAmount.selector);
        token.mint(user1, 0);
    }

    function test_mint_revertsWhenExceedingMaxSupply() public {
        vm.startPrank(admin);
        token.mint(user1, MAX_SUPPLY);

        vm.expectRevert(abi.encodeWithSelector(PresenzToken.ExceedsMaxSupply.selector, 1, 0));
        token.mint(user1, 1);
        vm.stopPrank();
    }

    function test_mint_revertsWithoutMinterRole() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, 1000 * 10 ** 18);
    }

    function test_mint_worksWithGrantedMinterRole() public {
        vm.startPrank(admin);
        token.grantRole(token.MINTER_ROLE(), minter);
        vm.stopPrank();

        vm.prank(minter);
        token.mint(user1, 1000 * 10 ** 18);

        assertEq(token.balanceOf(user1), 1000 * 10 ** 18);
    }

    // ============ Burning Tests ============

    function test_burn_successfullyBurnsTokens() public {
        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 burnAmount = 400 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, mintAmount);

        vm.prank(user1);
        token.burn(burnAmount);

        assertEq(token.balanceOf(user1), mintAmount - burnAmount);
        assertEq(token.totalBurned(), burnAmount);
    }

    function test_burn_emitsEvent() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, amount);

        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit TokensBurned(user1, amount);
        token.burn(amount);
    }

    function test_burn_revertsWithZeroAmount() public {
        vm.prank(admin);
        token.mint(user1, 1000 * 10 ** 18);

        vm.prank(user1);
        vm.expectRevert(PresenzToken.ZeroAmount.selector);
        token.burn(0);
    }

    function test_burnFrom_successfullyBurnsFromAllowance() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, amount);

        vm.prank(user1);
        token.approve(user2, amount);

        vm.prank(user2);
        token.burnFrom(user1, amount);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.totalBurned(), amount);
    }

    // ============ Burn With Treasury Split Tests ============

    function test_burnWithTreasurySplit_correctlySplits50Percent() public {
        uint256 amount = 1000 * 10 ** 18;
        uint256 burnPercentage = 50;

        vm.prank(admin);
        token.mint(user1, amount);

        vm.prank(user1);
        token.burnWithTreasurySplit(amount, burnPercentage);

        uint256 expectedBurn = 500 * 10 ** 18;
        uint256 expectedTreasury = 500 * 10 ** 18;

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(token.BURN_ADDRESS()), expectedBurn);
        assertEq(token.balanceOf(treasury), expectedTreasury);
        assertEq(token.totalBurned(), expectedBurn);
    }

    function test_burnWithTreasurySplit_correctlySplits100Percent() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, amount);

        vm.prank(user1);
        token.burnWithTreasurySplit(amount, 100);

        assertEq(token.balanceOf(token.BURN_ADDRESS()), amount);
        assertEq(token.balanceOf(treasury), 0);
        assertEq(token.totalBurned(), amount);
    }

    function test_burnWithTreasurySplit_correctlySplits0Percent() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, amount);

        vm.prank(user1);
        token.burnWithTreasurySplit(amount, 0);

        assertEq(token.balanceOf(token.BURN_ADDRESS()), 0);
        assertEq(token.balanceOf(treasury), amount);
        assertEq(token.totalBurned(), 0);
    }

    function test_burnWithTreasurySplit_emitsEvent() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, amount);

        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit TokensBurnedWithSplit(user1, 500 * 10 ** 18, 500 * 10 ** 18);
        token.burnWithTreasurySplit(amount, 50);
    }

    function test_burnWithTreasurySplit_revertsWithZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(PresenzToken.ZeroAmount.selector);
        token.burnWithTreasurySplit(0, 50);
    }

    function test_burnWithTreasurySplit_revertsWithInvalidPercentage() public {
        vm.prank(admin);
        token.mint(user1, 1000 * 10 ** 18);

        vm.prank(user1);
        vm.expectRevert("Invalid burn percentage");
        token.burnWithTreasurySplit(1000 * 10 ** 18, 101);
    }

    // ============ Treasury Tests ============

    function test_setTreasury_updatesAddress() public {
        address newTreasury = makeAddr("newTreasury");

        vm.prank(admin);
        token.setTreasury(newTreasury);

        assertEq(token.treasury(), newTreasury);
    }

    function test_setTreasury_emitsEvent() public {
        address newTreasury = makeAddr("newTreasury");

        vm.prank(admin);
        vm.expectEmit(true, true, false, false);
        emit TreasuryUpdated(treasury, newTreasury);
        token.setTreasury(newTreasury);
    }

    function test_setTreasury_revertsWithZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(PresenzToken.InvalidTreasuryAddress.selector);
        token.setTreasury(address(0));
    }

    function test_setTreasury_revertsWithoutRole() public {
        vm.prank(user1);
        vm.expectRevert();
        token.setTreasury(makeAddr("newTreasury"));
    }

    // ============ Pause Tests ============

    function test_pause_preventsTransfers() public {
        vm.prank(admin);
        token.mint(user1, 1000 * 10 ** 18);

        vm.prank(admin);
        token.pause();

        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 100 * 10 ** 18);
    }

    function test_unpause_allowsTransfers() public {
        vm.prank(admin);
        token.mint(user1, 1000 * 10 ** 18);

        vm.prank(admin);
        token.pause();

        vm.prank(admin);
        token.unpause();

        vm.prank(user1);
        token.transfer(user2, 100 * 10 ** 18);

        assertEq(token.balanceOf(user2), 100 * 10 ** 18);
    }

    function test_pause_revertsWithoutRole() public {
        vm.prank(user1);
        vm.expectRevert();
        token.pause();
    }

    // ============ View Function Tests ============

    function test_circulatingSupply_returnsCorrectValue() public {
        uint256 mintAmount = 1000 * 10 ** 18;
        uint256 burnAmount = 400 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, mintAmount);

        vm.prank(user1);
        token.burnWithTreasurySplit(burnAmount, 100); // 100% burn

        assertEq(token.circulatingSupply(), mintAmount - burnAmount);
    }

    function test_remainingMintableSupply_returnsCorrectValue() public {
        uint256 mintAmount = 100_000_000 * 10 ** 18;

        vm.prank(admin);
        token.mint(user1, mintAmount);

        assertEq(token.remainingMintableSupply(), MAX_SUPPLY - mintAmount);
    }

    // ============ Fuzz Tests ============

    function testFuzz_mint_respectsMaxSupply(uint256 amount) public {
        amount = bound(amount, 1, MAX_SUPPLY);

        vm.prank(admin);
        token.mint(user1, amount);

        assertEq(token.balanceOf(user1), amount);
        assertLe(token.totalSupply(), MAX_SUPPLY);
    }

    function testFuzz_burnWithTreasurySplit_correctCalculation(uint256 amount, uint256 burnPercentage) public {
        amount = bound(amount, 1, 1_000_000 * 10 ** 18);
        burnPercentage = bound(burnPercentage, 0, 100);

        vm.prank(admin);
        token.mint(user1, amount);

        uint256 expectedBurn = (amount * burnPercentage) / 100;
        uint256 expectedTreasury = amount - expectedBurn;

        vm.prank(user1);
        token.burnWithTreasurySplit(amount, burnPercentage);

        assertEq(token.balanceOf(token.BURN_ADDRESS()), expectedBurn);
        assertEq(token.balanceOf(treasury), expectedTreasury);
    }
}
