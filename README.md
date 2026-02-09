# PRESENZ ($PSZ) Smart Contracts

[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg)](https://book.getfoundry.sh/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Smart contracts for the PRESENZ platform - a decentralized, privacy-first, real-time presence mapping platform that visualizes global human activity without exposing personal identity.

## Overview

PRESENZ is built on the principle of **presence without identity**. The PSZ token powers this ecosystem by incentivizing meaningful contribution, enabling visibility-based utilities, and supporting a sustainable economic flywheel.

### Token Specifications

| Attribute | Value |
|-----------|-------|
| **Token Name** | PRESENZ |
| **Token Symbol** | PSZ |
| **Total Supply** | 1,000,000,000 (1 Billion) |
| **Decimals** | 18 |
| **Blockchain** | Base (Ethereum L2) |
| **Supply Model** | Fixed Cap + Deflationary Burns |

## 🚀 Deployed Contracts

### Base Sepolia Testnet (Chain ID: 84532)

| Contract | Address | Explorer |
|----------|---------|----------|
| **PresenzToken** | `0xf28e5b3656564949a4F085f64b94Ab0B184C6d87` | [View on Basescan](https://sepolia.basescan.org/address/0xf28e5b3656564949a4f085f64b94ab0b184c6d87) |
| **VestingContract** | `0xC638A478010287a60E18f2B9b9961FC3db04142C` | [View on Basescan](https://sepolia.basescan.org/address/0xc638a478010287a60e18f2b9b9961fc3db04142c) |
| **MiningRewards** | `0xb7b1d45D337e6cCA2027a68185aE2F7979f5a2FA` | [View on Basescan](https://sepolia.basescan.org/address/0xb7b1d45d337e6cca2027a68185ae2f7979f5a2fa) |

> 📝 **Note**: Mainnet deployment addresses will be added here after production launch.

## Smart Contracts

### Core Contracts

| Contract | Description |
|----------|-------------|
| [PresenzToken.sol](src/PresenzToken.sol) | ERC20 token with minting, burning, and role-based access control |
| [MiningRewards.sol](src/MiningRewards.sol) | Community mining rewards distribution (400M tokens over 7 years) |
| [VestingContract.sol](src/VestingContract.sol) | Token vesting for Team, Investors, and Advisors |
| [TokenAllocation.sol](src/TokenAllocation.sol) | Manages Business Dev, Liquidity, and Marketing allocations |

### Token Distribution

| Allocation | Percentage | Tokens | Contract |
|------------|------------|--------|----------|
| Community Mining Rewards | 40% | 400,000,000 | `MiningRewards.sol` |
| Team & Founders | 15% | 150,000,000 | `VestingContract.sol` |
| Treasury/DAO | 15% | 150,000,000 | Treasury Wallet |
| Investors (Seed/Private) | 12% | 120,000,000 | `VestingContract.sol` |
| Business Development | 8% | 80,000,000 | `TokenAllocation.sol` |
| Liquidity & Exchanges | 5% | 50,000,000 | `TokenAllocation.sol` |
| Advisors | 3% | 30,000,000 | `VestingContract.sol` |
| Marketing & Partnerships | 2% | 20,000,000 | `TokenAllocation.sol` |

### Reward System (Whitepaper Compliant)

The mining rewards follow the whitepaper specifications:

| Parameter | Value |
|-----------|-------|
| **Photo Post Reward** | 2 PSZ |
| **Video Post Reward** | 2 PSZ |
| **Venue Check-in Reward** | 5 PSZ |
| **Daily Cap per User** | 10 PSZ |
| **Max Posts per Day** | 5 posts |

**Reward Formula:** `Rd = min(Nd × Rp, Cd)` where:
- `Rp` = 2 PSZ (reward per post)
- `Cd` = 10 PSZ (daily cap)
- `Nd` ≤ 5 (max posts per day)

### Vesting Schedules

| Category | Cliff | Vesting Duration |
|----------|-------|------------------|
| Team & Founders | 1 year | 3 years linear |
| Investors | 6 months | 18 months linear |
| Advisors | 6 months | 2 years linear |

### 7-Year Emission Schedule

| Year | Tokens Released | % of Mining Pool |
|------|-----------------|------------------|
| Year 1 | 100,000,000 | 25% |
| Year 2 | 80,000,000 | 20% |
| Year 3 | 60,000,000 | 15% |
| Year 4 | 48,000,000 | 12% |
| Year 5 | 40,000,000 | 10% |
| Year 6 | 36,000,000 | 9% |
| Year 7 | 36,000,000 | 9% |

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/)

### Installation

```bash
# Clone the repository
git clone https://github.com/presenz/presenz-contracts.git
cd presenz-contracts

# Install dependencies
forge install
```

### Build

```bash
forge build
```

### Test

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/MiningRewards.t.sol

# Run with gas report
forge test --gas-report
```

### Test Coverage

```bash
forge coverage
```

### Format

```bash
forge fmt
```

### Deploy

#### Quick Start (Recommended)

```bash
# Use the automated deployment script
chmod +x deploy.sh
./deploy.sh
```

#### Manual Deployment

```bash
# Setup
cp .env.example .env
nano .env  # Configure your settings

# Deploy to Base Sepolia (testnet)
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_sepolia \
    --broadcast \
    --verify \
    -vvvv

# Deploy to Base Mainnet (production)
forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
    --rpc-url base_mainnet \
    --broadcast \
    --verify \
    -vvvv
```

📖 **For complete deployment guide**, see [DEPLOYMENTS.md](DEPLOYMENTS.md)

---

## 📚 Documentation

- **[DEPLOYMENTS.md](DEPLOYMENTS.md)** - Complete deployment guide, addresses, and commands
- **[PRESENZ_TOKENOMICS.md](PRESENZ_TOKENOMICS.md)** - Token economics and distribution
- **[deploy.sh](deploy.sh)** - Interactive deployment script

## Contract Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENZ TOKEN ECONOMY                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────┐         ┌─────────────────┐              │
│   │  PresenzToken   │         │  MiningRewards  │              │
│   │    (ERC20)      │◄────────│   (400M Pool)   │              │
│   │                 │         │                 │              │
│   │  • Mint/Burn    │         │  • 7-yr emission│              │
│   │  • Pausable     │         │  • Daily caps   │              │
│   │  • AccessControl│         │  • Post limits  │              │
│   └────────┬────────┘         └─────────────────┘              │
│            │                                                    │
│   ┌────────┴────────┐         ┌─────────────────┐              │
│   │                 │         │                 │              │
│   ▼                 ▼         ▼                 │              │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │              │
│ │  Vesting    │ │  Token      │ │  Treasury   │ │              │
│ │  Contract   │ │  Allocation │ │  (Wallet)   │ │              │
│ │             │ │             │ │             │ │              │
│ │ • Team 15%  │ │ • BizDev 8% │ │ • DAO 15%   │ │              │
│ │ • Invest 12%│ │ • Liquid 5% │ │             │ │              │
│ │ • Advisor 3%│ │ • Mktg 2%   │ │             │ │              │
│ └─────────────┘ └─────────────┘ └─────────────┘ │              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Security

- Smart contracts follow OpenZeppelin best practices
- Role-based access control for sensitive operations
- Reentrancy guards on all token transfer functions
- Pausable functionality for emergency situations
- All contracts are designed to be audited before mainnet deployment

## License

MIT License - see [LICENSE](LICENSE) for details.


**Disclaimer:** This document is for informational purposes only. The PSZ token is a utility token designed for the PRESENZ ecosystem and does not represent equity, ownership, or investment interest.
