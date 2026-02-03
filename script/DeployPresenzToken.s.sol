// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/PresenzToken.sol";
import "../src/VestingContract.sol";
import "../src/MiningRewards.sol";

contract DeployPresenzToken is Script {
    // Token allocations (in tokens, not wei)
    uint256 constant LIQUIDITY_ALLOCATION = 50_000_000; // 5% - 50M
    uint256 constant MARKETING_ALLOCATION = 20_000_000; // 2% - 20M
    uint256 constant TREASURY_ALLOCATION = 150_000_000; // 15% - 150M
    uint256 constant BUSINESS_DEV_ALLOCATION = 80_000_000; // 8% - 80M
    uint256 constant TEAM_ALLOCATION = 150_000_000; // 15% - 150M
    uint256 constant INVESTOR_ALLOCATION = 120_000_000; // 12% - 120M
    uint256 constant ADVISOR_ALLOCATION = 30_000_000; // 3% - 30M
    uint256 constant MINING_ALLOCATION = 400_000_000; // 40% - 400M

    function run() external returns (PresenzToken token, VestingContract vesting, MiningRewards mining) {
        // Load environment variables
        address treasury = vm.envAddress("TREASURY_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address liquidityWallet = vm.envAddress("LIQUIDITY_WALLET");
        address marketingWallet = vm.envAddress("MARKETING_WALLET");
        address businessDevWallet = vm.envAddress("BUSINESS_DEV_WALLET");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Token
        token = new PresenzToken(treasury, admin);

        // 2. Deploy Vesting Contract
        vesting = new VestingContract(address(token), admin);

        // 3. Deploy Mining Rewards Contract
        mining = new MiningRewards(address(token), admin);

        // 4. Mint initial allocations

        // Liquidity & Exchanges (50M) - Available at launch
        token.mint(liquidityWallet, LIQUIDITY_ALLOCATION * 10 ** 18);

        // Marketing & Airdrops (20M) - Available at launch
        token.mint(marketingWallet, MARKETING_ALLOCATION * 10 ** 18);

        // Treasury (150M) - To multisig
        token.mint(treasury, TREASURY_ALLOCATION * 10 ** 18);

        // Business Development (80M) - To multisig
        token.mint(businessDevWallet, BUSINESS_DEV_ALLOCATION * 10 ** 18);

        // Vesting allocations (300M total) - Mint to vesting contract
        uint256 vestingTotal = (TEAM_ALLOCATION + INVESTOR_ALLOCATION + ADVISOR_ALLOCATION) * 10 ** 18;
        token.mint(address(vesting), vestingTotal);

        // Mining rewards (400M) - Mint to mining contract
        token.mint(address(mining), MINING_ALLOCATION * 10 ** 18);

        vm.stopBroadcast();

        // Log deployment info
        console.log("==========================================");
        console.log("       PRESENZ TOKEN DEPLOYMENT           ");
        console.log("==========================================");
        console.log("");
        console.log("Contracts Deployed:");
        console.log("  Token:   ", address(token));
        console.log("  Vesting: ", address(vesting));
        console.log("  Mining:  ", address(mining));
        console.log("");
        console.log("Initial Allocations:");
        console.log("  Liquidity (50M):    ", liquidityWallet);
        console.log("  Marketing (20M):    ", marketingWallet);
        console.log("  Treasury (150M):    ", treasury);
        console.log("  Business Dev (80M): ", businessDevWallet);
        console.log("  Vesting (300M):     ", address(vesting));
        console.log("  Mining (400M):      ", address(mining));
        console.log("");
        console.log("Total Minted:", token.totalSupply() / 10 ** 18, "PSZ");
        console.log("==========================================");

        return (token, vesting, mining);
    }
}

/**
 * @title SetupVestingSchedules
 * @notice Separate script to set up individual vesting schedules
 * @dev Run after deployment with team/investor/advisor addresses
 */
contract SetupVestingSchedules is Script {
    function setupTeamVesting(address vestingContract, address[] calldata addresses, uint256[] calldata amounts)
        external
    {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        VestingContract vesting = VestingContract(vestingContract);
        for (uint256 i = 0; i < addresses.length; i++) {
            vesting.createTeamVesting(addresses[i], amounts[i] * 10 ** 18);
        }

        vm.stopBroadcast();
    }

    function setupInvestorVesting(address vestingContract, address[] calldata addresses, uint256[] calldata amounts)
        external
    {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        VestingContract vesting = VestingContract(vestingContract);
        for (uint256 i = 0; i < addresses.length; i++) {
            vesting.createInvestorVesting(addresses[i], amounts[i] * 10 ** 18);
        }

        vm.stopBroadcast();
    }

    function setupAdvisorVesting(address vestingContract, address[] calldata addresses, uint256[] calldata amounts)
        external
    {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        VestingContract vesting = VestingContract(vestingContract);
        for (uint256 i = 0; i < addresses.length; i++) {
            vesting.createAdvisorVesting(addresses[i], amounts[i] * 10 ** 18);
        }

        vm.stopBroadcast();
    }
}
