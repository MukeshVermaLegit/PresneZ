# 📋 Presenz Token - Complete Deployment Guide

This is your one-stop reference for everything related to deploying and managing Presenz Token on Base Layer 2.

**Quick Navigation:**
- [Deployed Addresses](#-deployed-contracts)
- [Quick Start](#-quick-start-deployment)
- [Deployment Guide](#-deployment-guide)
- [Pre-Deployment Checklist](#-pre-deployment-checklist)
- [Integration Guide](#-integration-guide)
- [Command Reference](#-command-reference)

## 🧪 Base Sepolia Testnet

**Network Details:**
- Chain ID: `84532`
- RPC URL: `https://sepolia.base.org`
- Block Explorer: `https://sepolia.basescan.org`
- Deployment Date: February 6, 2026
- Deployment Block: `37303530`

### Contract Addresses

| Contract | Address | Verified |
|----------|---------|----------|
| **PresenzToken** | [`0xf28e5b3656564949a4F085f64b94Ab0B184C6d87`](https://sepolia.basescan.org/address/0xf28e5b3656564949a4f085f64b94ab0b184c6d87) | ✅ |
| **VestingContract** | [`0xC638A478010287a60E18f2B9b9961FC3db04142C`](https://sepolia.basescan.org/address/0xc638a478010287a60e18f2b9b9961fc3db04142c) | ✅ |
| **MiningRewards** | [`0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA`](https://sepolia.basescan.org/address/0xb7b1d45d337e6cca2027a68185ae2f7979f5a2fa) | ✅ |

### Token Distribution (Testnet)

| Allocation | Amount | Recipient Address |
|------------|--------|-------------------|
| Liquidity | 50,000,000 PSZ | `0x49D730c95f70206b49ecC146C30BD4950369F8a9` |
| Marketing | 20,000,000 PSZ | `0x49D730c95f70206b49ecC146C30BD4950369F8a9` |
| Treasury | 150,000,000 PSZ | `0x49D730c95f70206b49ecC146C30BD4950369F8a9` |
| Business Dev | 80,000,000 PSZ | `0x49D730c95f70206b49ecC146C30BD4950369F8a9` |
| Vesting Contract | 300,000,000 PSZ | `0xC638A478010287a60E18f2B9b9961FC3db04142C` |
| Mining Rewards | 400,000,000 PSZ | `0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA` |
| **TOTAL** | **1,000,000,000 PSZ** | |

### Deployment Transaction

- **Transaction Hash**: [`0x292b1c5f14c4de7a53d18a85653def56122cbe555643034fa5f2ae13a55e459b`](https://sepolia.basescan.org/tx/0x292b1c5f14c4de7a53d18a85653def56122cbe555643034fa5f2ae13a55e459b)
- **Gas Used**: 4,570,159
- **Gas Price**: 0.0012 gwei
- **Total Cost**: 0.0000054841908 ETH

### Quick Interaction Commands

```bash
# Token address
export TOKEN_ADDRESS=0xf28e5b3656564949a4F085f64b94Ab0B184C6d87

# Vesting address
export VESTING_ADDRESS=0xC638A478010287a60E18f2B9b9961FC3db04142C

# Mining address
export MINING_ADDRESS=0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA

# Check token balance
cast call $TOKEN_ADDRESS "balanceOf(address)" <YOUR_ADDRESS> --rpc-url base_sepolia

# Check total supply
cast call $TOKEN_ADDRESS "totalSupply()" --rpc-url base_sepolia

# Check token name
cast call $TOKEN_ADDRESS "name()" --rpc-url base_sepolia
```

---

## 🌐 Base Mainnet

**Network Details:**
- Chain ID: `8453`
- RPC URL: `https://mainnet.base.org`
- Block Explorer: `https://basescan.org`
- Deployment Date: _Not yet deployed_

### Contract Addresses

| Contract | Address | Verified |
|----------|---------|----------|
| **PresenzToken** | `TBD` | ⏳ |
| **VestingContract** | `TBD` | ⏳ |
| **MiningRewards** | `TBD` | ⏳ |

> 🚧 **Mainnet deployment pending** - Will be deployed after thorough testing on testnet.

---

## 📝 Deployment History

### Version 1.0.0 - Initial Deployment

**Date**: February 6, 2026  
**Network**: Base Sepolia Testnet  
**Status**: ✅ Successful  
**Deployer**: `0x49D730c95f70206b49ecC146C30BD4950369F8a9`

**Features Deployed:**
- ✅ ERC20 token with fixed supply (1B PSZ)
- ✅ Role-based access control (Admin, Minter, Pauser, Treasury)
- ✅ Vesting schedules for Team, Investors, and Advisors
- ✅ Mining rewards distribution (400M over 7 years)
- ✅ Deflationary burn mechanism with treasury split
- ✅ Emergency pause functionality

**Contracts Verified:**
- ✅ PresenzToken
- ✅ VestingContract
- ✅ MiningRewards

---

## 🔗 Important Links

### Base Sepolia (Testnet)
- **Add Network to MetaMask**: [Base Sepolia](https://chainlist.org/chain/84532)
- **Get Testnet ETH**: [Base Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
- **Bridge**: [Base Bridge](https://bridge.base.org/)

### Base Mainnet
- **Add Network to MetaMask**: [Base Mainnet](https://chainlist.org/chain/8453)
- **Bridge**: [Base Bridge](https://bridge.base.org/)
- **Official Docs**: [Base Documentation](https://docs.base.org/)

---

## 🛠️ Integration Guide

### For Frontend Developers

```javascript
// Base Sepolia Testnet
const PRESENZ_TOKEN_ADDRESS = '0xf28e5b3656564949a4F085f64b94Ab0B184C6d87';
const VESTING_CONTRACT_ADDRESS = '0xC638A478010287a60E18f2B9b9961FC3db04142C';
const MINING_REWARDS_ADDRESS = '0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA';
const CHAIN_ID = 84532; // Base Sepolia

// ABI files location
// - PresenzToken ABI: out/PresenzToken.sol/PresenzToken.json
// - VestingContract ABI: out/VestingContract.sol/VestingContract.json
// - MiningRewards ABI: out/MiningRewards.sol/MiningRewards.json
```

### For Backend Developers

```bash
# Environment variables for Base Sepolia
PRESENZ_TOKEN_ADDRESS=0xf28e5b3656564949a4F085f64b94Ab0B184C6d87
VESTING_CONTRACT_ADDRESS=0xC638A478010287a60E18f2B9b9961FC3db04142C
MINING_REWARDS_ADDRESS=0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
CHAIN_ID=84532
```

---

## 📊 Contract Statistics

### PresenzToken

- **Standard**: ERC20
- **Total Supply**: 1,000,000,000 PSZ (Fixed)
- **Decimals**: 18
- **Features**: Mintable, Burnable, Pausable, Role-based Access Control
- **Max Supply**: 1,000,000,000 PSZ (Hard Cap)

### VestingContract

- **Type**: Token Vesting
- **Total Locked**: 300,000,000 PSZ
- **Vesting Types**: Team (2yr), Investor (1yr), Advisor (1yr)
- **Features**: Cliff periods, Linear vesting, Revocable schedules

### MiningRewards

- **Type**: Mining/Staking Rewards
- **Total Pool**: 400,000,000 PSZ
- **Distribution**: 7 years (decreasing emissions)
- **Daily Cap**: 10 PSZ per user
- **Post Limit**: 5 posts per day

---

## 🔐 Security Notes

- ✅ All contracts verified on Basescan
- ✅ OpenZeppelin contracts used for security
- ✅ Role-based access control implemented
- ✅ Emergency pause mechanism available
- ✅ Reentrancy guards on critical functions
- ⏳ Audit pending (recommended before mainnet)
- ⏳ Multisig wallet recommended for mainnet admin/treasury

---

## 📞 Support

For questions or issues related to these deployments:
- GitHub: [presenz/presenz-contracts](https://github.com/presenz/presenz-contracts)
- Discord: [PRESENZ Community](https://discord.gg/presenz)
- Documentation: [docs.presenz.io](https://docs.presenz.io)

---

## 🚀 Quick Start Deployment

### Using the Interactive Script (Recommended)

```bash
# Make executable (first time only)
chmod +x deploy.sh

# Run deployment wizard
./deploy.sh
```

The script provides:
- ✅ Automated testnet deployment
- ✅ Mainnet deployment with safety checks
- ✅ Balance verification
- ✅ Simulation mode (dry-run)

### Manual Deployment

```bash
# 1. Setup environment
cp .env.example .env
nano .env  # Configure your settings

# 2. Run tests
forge test

# 3. Deploy to Base Sepolia
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_sepolia \
    --broadcast \
    --verify \
    -vvvv

# 4. Deploy to Base Mainnet (when ready)
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_mainnet \
    --broadcast \
    --verify \
    -vvvv
```

---

## 📖 Deployment Guide

### Prerequisites

1. **Install Foundry**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. **Get Testnet ETH**
- [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
- Need ~0.01 ETH for deployment

3. **Get Basescan API Key**
- Visit [Basescan](https://basescan.org/myapikey)
- Required for contract verification

### Configuration

Create `.env` file with these variables:

```bash
PRIVATE_KEY=your_private_key_without_0x
ADMIN_ADDRESS=0x...
TREASURY_ADDRESS=0x...
LIQUIDITY_WALLET=0x...
MARKETING_WALLET=0x...
BUSINESS_DEV_WALLET=0x...
BASE_RPC_URL=https://mainnet.base.org
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=your_api_key
```

### Deployment Steps

#### 1️⃣ Test Locally
```bash
forge test -vv
```

#### 2️⃣ Deploy to Testnet
```bash
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_sepolia \
    --broadcast \
    --verify \
    -vvvv
```

#### 3️⃣ Verify Deployment
- Check contracts on [Basescan](https://sepolia.basescan.org)
- Verify token supply: 1,000,000,000 PSZ
- Test token transfers, vesting, mining rewards

#### 4️⃣ Deploy to Mainnet (After Testing)
```bash
# Simulate first
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_mainnet \
    -vvvv

# Deploy for real
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_mainnet \
    --broadcast \
    --verify \
    -vvvv
```

---

## ✅ Pre-Deployment Checklist

### Environment Setup
- [ ] `.env` file created and configured
- [ ] `PRIVATE_KEY` set (wallet with ETH)
- [ ] All wallet addresses configured
- [ ] `BASESCAN_API_KEY` obtained
- [ ] Deployer wallet has sufficient ETH

### Testnet Validation (Complete ✅)
- [x] Deployed to Base Sepolia
- [x] Contracts verified on Basescan
- [x] Token supply correct (1B PSZ)
- [x] All allocations distributed correctly
- [ ] Token transfers tested
- [ ] Vesting schedules tested
- [ ] Mining rewards tested
- [ ] Emergency pause tested

### Code Quality
- [x] All 107 tests passing
- [x] No compiler warnings
- [x] OpenZeppelin contracts used
- [ ] Code coverage reviewed
- [ ] Security audit (recommended)

### Mainnet Preparation
- [ ] Set up multisig for treasury
- [ ] Set up multisig for admin
- [ ] Hardware wallet for deployer
- [ ] Gas price acceptable
- [ ] Sufficient ETH in deployer wallet (~0.05 ETH)
- [ ] All team/investor addresses ready
- [ ] Marketing plan ready
- [ ] Liquidity provision plan ready

### Post-Deployment
- [ ] Save contract addresses
- [ ] Verify all contracts on Basescan
- [ ] Transfer admin to multisig
- [ ] Create vesting schedules
- [ ] Initialize mining rewards
- [ ] Update frontend/backend with addresses
- [ ] Announce to community

---

## 🔗 Command Reference

### Quick Setup
```bash
# Export addresses (after deployment)
export TOKEN=0xf28e5b3656564949a4F085f64b94Ab0B184C6d87
export VESTING=0xC638A478010287a60E18f2B9b9961FC3db04142C
export MINING=0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA
```

### Token Queries
```bash
# Check balance
cast call $TOKEN "balanceOf(address)" <ADDRESS> --rpc-url base_sepolia

# Check total supply
cast call $TOKEN "totalSupply()" --rpc-url base_sepolia

# Check token info
cast call $TOKEN "name()" --rpc-url base_sepolia
cast call $TOKEN "symbol()" --rpc-url base_sepolia
cast call $TOKEN "decimals()" --rpc-url base_sepolia
```

### Token Transactions
```bash
# Transfer tokens
cast send $TOKEN "transfer(address,uint256)" <TO> <AMOUNT> \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY

# Mint tokens (requires MINTER_ROLE)
cast send $TOKEN "mint(address,uint256)" <TO> <AMOUNT> \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY

# Burn tokens
cast send $TOKEN "burn(uint256)" <AMOUNT> \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY
```

### Vesting Operations
```bash
# Get vesting schedule
cast call $VESTING "getVestingSchedule(address)" <BENEFICIARY> \
    --rpc-url base_sepolia

# Create team vesting (2yr, 1yr cliff)
cast send $VESTING "createTeamVesting(address,uint256)" <BENEFICIARY> <AMOUNT> \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY

# Release vested tokens
cast send $VESTING "releaseVestedTokens()" \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY
```

### Mining Rewards
```bash
# Check user allocation
cast call $MINING "getUserAllocation(address)" <USER> \
    --rpc-url base_sepolia

# Allocate rewards (admin only)
cast send $MINING "allocateRewards(address,uint256)" <USER> <AMOUNT> \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY

# Claim rewards
cast send $MINING "claimRewards()" \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY
```

### Utility Commands
```bash
# Check ETH balance
cast balance <ADDRESS> --rpc-url base_sepolia

# Check gas price
cast gas-price --rpc-url base_sepolia

# Get transaction receipt
cast receipt <TX_HASH> --rpc-url base_sepolia
```

---

## 🔐 Security Best Practices

1. **Never commit `.env`** - Add to `.gitignore`
2. **Use hardware wallets** for mainnet admin/treasury
3. **Set up multisigs** - Use Gnosis Safe for critical roles
4. **Test thoroughly** on testnet before mainnet
5. **Audit contracts** - Recommended before mainnet launch
6. **Monitor contracts** - Set up alerts for critical events
7. **Document everything** - Keep deployment records secure

---

## 🆘 Troubleshooting

### "Insufficient funds for gas"
```bash
# Check balance
cast balance $YOUR_ADDRESS --rpc-url base_sepolia

# Get testnet ETH from faucet
```

### "Nonce too low/high"
```bash
# Check current nonce
cast nonce $YOUR_ADDRESS --rpc-url base_sepolia
```

### "Contract verification failed"
```bash
# Manual verification
forge verify-contract <ADDRESS> \
    src/PresenzToken.sol:PresenzToken \
    --chain-id 84532 \
    --etherscan-api-key $BASESCAN_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address,address)" $TREASURY $ADMIN)
```

### "Transaction reverted"
- Check you have the required role (MINTER_ROLE, PAUSER_ROLE, etc.)
- Verify contract is not paused
- Ensure sufficient token balance
- Check allowances for transferFrom operations

---

**Last Updated**: February 6, 2026
