# PRESENZ ($PSZ) TOKENOMICS
## Complete Economic Framework

**Version:** 2.0  
**Date:** February 3, 2026  
**Status:** Final (Whitepaper Aligned)

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Token Distribution](#2-token-distribution)
3. [Emission Schedule](#3-emission-schedule)
4. [Earning Mechanics](#4-earning-mechanics)
5. [Spending Sinks](#5-spending-sinks)
6. [Token Flow Architecture](#6-token-flow-architecture)
7. [Burn Mechanics](#7-burn-mechanics)
8. [Staking & Governance](#8-staking--governance)
9. [Anti-Gaming Protections](#9-anti-gaming-protections)
10. [Key Performance Metrics](#10-key-performance-metrics)
11. [Launch Strategy](#11-launch-strategy)
12. [Smart Contract Implementation](#12-smart-contract-implementation)

> **Note:** This document is aligned with the official PRESENZ Whitepaper and reflects the deployed smart contract implementation.

---

## 1. EXECUTIVE SUMMARY

### Overview
$PSZ is the native utility token powering the PRESENZ ecosystem—a hyperlocal, real-time, anonymous heatmap platform. The token creates a circular economy where users earn by contributing valuable content and spend to unlock enhanced features.

### Core Principles
- **Earn by Contributing:** No passive rewards; only quality content generates tokens
- **Spend for Power:** Unlock radius, boost visibility, access premium features
- **Deflationary by Design:** 40-60% of spent tokens are permanently burned
- **Privacy-First:** Token economy operates without compromising user anonymity

### Token Specifications

| Attribute | Value |
|-----------|-------|
| **Token Name** | PRESENZ |
| **Token Symbol** | $PSZ |
| **Total Supply** | 1,000,000,000 (1 Billion) |
| **Token Type** | Utility Token |
| **Blockchain** | Base |
| **Decimal Places** | 18 |
| **Supply Model** | Fixed Cap + Deflationary Burns |

### Why 1 Billion Supply?
- Psychologically accessible price point ($0.001 - $0.10 range)
- Room for micro-transactions (5-100 $PSZ per action)
- Deflationary burns can meaningfully reduce supply over time
- Industry standard for utility tokens in this category

---

## 2. TOKEN DISTRIBUTION

### 2.1 Allocation Breakdown

| Allocation | Percentage | Tokens | Vesting Schedule |
|------------|------------|--------|------------------|
| **Community Mining Rewards** | 40% | 400,000,000 | Released over 7 years via mining emissions |
| **Team & Founders** | 15% | 150,000,000 | 1-year cliff, 3-year linear vesting |
| **Treasury/DAO** | 15% | 150,000,000 | Governance-controlled for future development |
| **Investors (Seed/Private)** | 12% | 120,000,000 | 6-month cliff, 18-month linear vesting |
| **Business Development** | 8% | 80,000,000 | For venue partnerships & integrations |
| **Liquidity & Exchanges** | 5% | 50,000,000 | Initial liquidity pools & CEX listings |
| **Advisors** | 3% | 30,000,000 | 6-month cliff, 2-year linear vesting |
| **Marketing & Airdrops** | 2% | 20,000,000 | User acquisition campaigns |
| **TOTAL** | **100%** | **1,000,000,000** | — |

### 2.2 Visual Distribution

```
Community Mining ████████████████████████████████████████ 40%
Team & Founders  ███████████████                          15%
Treasury/DAO     ███████████████                          15%
Investors        ████████████                             12%
Business Dev     ████████                                  8%
Liquidity        █████                                     5%
Advisors         ███                                       3%
Marketing        ██                                        2%
```

### 2.3 Vesting Rationale

**Team & Founders (15%)**
- 1-year cliff ensures long-term commitment
- 3-year linear vesting aligns incentives with project success
- Prevents early dumps and maintains market confidence

**Investors (12%)**
- 6-month cliff allows initial market stabilization
- 18-month vesting balances investor liquidity needs with market health

**Advisors (3%)**
- 6-month cliff ensures value delivery before tokens unlock
- 2-year vesting maintains ongoing advisory relationship

---

## 3. EMISSION SCHEDULE

### 3.1 Deflationary Emission Curve

The 400M tokens allocated for community mining are released on a decreasing schedule:

| Year | Tokens Released | % of Mining Pool | Daily Average |
|------|-----------------|------------------|---------------|
| Year 1 | 100,000,000 | 25% | ~274,000 $PSZ |
| Year 2 | 80,000,000 | 20% | ~219,000 $PSZ |
| Year 3 | 60,000,000 | 15% | ~164,000 $PSZ |
| Year 4 | 48,000,000 | 12% | ~131,000 $PSZ |
| Year 5 | 40,000,000 | 10% | ~110,000 $PSZ |
| Year 6 | 36,000,000 | 9% | ~99,000 $PSZ |
| Year 7 | 36,000,000 | 9% | ~99,000 $PSZ |
| **TOTAL** | **400,000,000** | **100%** | — |

### 3.2 Emission Curve Visualization

```
Tokens (M)
100 |████
 80 |████████
 60 |████████████
 48 |████████████████
 40 |████████████████████
 36 |████████████████████████
 36 |████████████████████████████
    └────────────────────────────────
      Y1   Y2   Y3   Y4   Y5   Y6   Y7
```

### 3.3 Dynamic Adjustment Mechanism

Emissions are subject to quarterly governance adjustments based on:
- Network growth rate
- Token velocity
- Burn rate vs emission rate
- Market conditions

**Target:** Burn rate exceeds emission rate by Year 2

---

## 4. EARNING MECHANICS

### 4.1 Sustainable Reward Model (Whitepaper)

PRESENZ adopts a controlled and sustainable reward mechanism designed to incentivize meaningful participation while preventing inflation and abuse. Users earn tokens ONLY by contributing valuable content.

### 4.2 Base Reward Structure

| Action | Reward | Description |
|--------|--------|-------------|
| **Photo Post** | 2 $PSZ | Upload a geotagged photo |
| **Video Post** | 2 $PSZ | Upload a video (max 15 seconds) |
| **Venue Check-in Post** | 5 $PSZ | Post from inside a Paid Venue Pin |

### 4.3 Daily Limits (Whitepaper Compliant)

| Mechanism | Value | Purpose |
|-----------|-------|---------|
| **Daily Cap** | 10 $PSZ/user/day | Prevents industrial farming |
| **Max Posts Per Day** | 5 posts | Quality over quantity |
| **Reward Per Post (Rp)** | 2 $PSZ | Uniform reward structure |

### 4.4 Reward Formula

The PRESENZ reward parameters are defined as:
- **Rp** = 2 PSZ (reward per valid post)
- **Cd** = 10 PSZ (daily reward cap per user)
- **Nd** = number of valid posts submitted by a user in a 24-hour period

The daily reward function is:

```
Rd = min(Nd × Rp, Cd)
```

Subject to the constraint: **Nd ≤ 5**

This ensures that no user may earn more than 10 PSZ per day, regardless of posting frequency beyond the maximum rewarded threshold.

### 4.5 Earning Example Scenarios

**Scenario A: Casual User (Photo Only)**
```
Daily Activity:
- 3 Photo Posts: 3 × 2 = 6 $PSZ
Daily Earnings: 6 $PSZ
Monthly Earnings (30 days): ~180 $PSZ
```

**Scenario B: Active Creator (Max Daily)**
```
Daily Activity:
- 5 Photo Posts: 5 × 2 = 10 $PSZ (cap reached)
Daily Earnings: 10 $PSZ (maximum)
Monthly Earnings (30 days): ~300 $PSZ
```

**Scenario C: Venue Visitor**
```
Daily Activity:
- 2 Venue Check-ins: 2 × 5 = 10 $PSZ (cap reached)
Daily Earnings: 10 $PSZ (maximum)
Posts remaining: 3 (but daily cap reached)
```

### 4.6 Anti-Spam & Quality Controls

| Mechanism | Rule | Smart Contract Enforcement |
|-----------|------|----------------------------|
| **Daily Cap** | Max 10 $PSZ/user/day | `dailyUserCap = 10 * 10**18` |
| **Max Posts** | Max 5 rewarded posts/day | `MAX_POSTS_PER_DAY = 5` |
| **Valid Rewards** | Only 2 or 5 PSZ amounts | `InvalidRewardType` error |
| **Quality Gate** | Posts must pass AI moderation | Off-chain verification |
| **Unique Content** | AI similarity check | Off-chain verification |

---

## 5. SPENDING SINKS

### 5.1 Map Visibility Radius (User Utility)

The core monetization feature limiting geographic visibility.

| Tier | Radius | Duration | Cost ($PSZ) |
|------|--------|----------|-------------|
| **Free** | 20 km | Permanent | 0 |
| **Silver** | 30 km | 24 hours | 25 |
| **Gold** | 50 km | 24 hours | 50 |
| **Platinum** | 100 km | 24 hours | 100 |
| **Diamond** | 200 km | 24 hours | 175 |
| **Unlimited Daily** | Global | 24 hours | 250 |
| **Unlimited Weekly** | Global | 7 days | 400 |
| **Unlimited Monthly** | Global | 30 days | 500 |

**Use Cases:**
- Travelers wanting to explore new cities
- Event planners scouting locations
- Journalists monitoring multiple areas
- Curious users exploring the world

### 5.2 Business & Venue Pricing

Revenue-generating features for commercial users.

| Package / Feature | Cost ($PSZ) | Duration | Description |
|-------------------|-------------|----------|-------------|
| **Standard Pin** | FREE | 3 days | Generic pin, basic info only |
| **Premium Pin (Weekly)** | 200 | 7 days | Custom logo, premium frame, analytics |
| **Premium Pin (Monthly)** | 600 | 30 days | Same as weekly |
| **Premium Pin (Quarterly)** | 1,500 | 90 days | Same as weekly |
| **Premium Pin (Yearly)** | 5,000 | 365 days | Same as weekly |
| **Featured Venue Slot** | 400/week | 7 days | Top of search results, suggested place |

**Premium Pin Benefits:**
- Custom brand logo
- Premium pin frame
- Standout color (Gold/Purple)
- Analytics dashboard
- "Open/Closed" status indicator
- Direct link to business info

---

## 6. TOKEN FLOW ARCHITECTURE

### 6.1 System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENZ TOKEN ECONOMY                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌───────────────┐         ┌───────────────┐                       │
│   │   EMISSION    │         │   BUSINESS    │                       │
│   │    POOL       │         │   DEPOSITS    │                       │
│   │  (400M $PSZ)  │         │               │                       │
│   └───────┬───────┘         └───────┬───────┘                       │
│           │                         │                               │
│           ▼                         ▼                               │
│   ┌─────────────────────────────────────────┐                       │
│   │              USER ACTIONS                │                       │
│   ├─────────────────────────────────────────┤                       │
│   │  📸 Post Photo ────────► +5 $PSZ        │                       │
│   │  🎥 Post Video ────────► +10 $PSZ       │                       │
│   │  📍 Venue Check-in ───► +15 $PSZ        │                       │
│   └─────────────────┬───────────────────────┘                       │
│                     │                                               │
│                     ▼                                               │
│           ┌─────────────────┐                                       │
│           │   USER WALLET   │                                       │
│           │   (via Privy)   │                                       │
│           └────────┬────────┘                                       │
│                    │                                                │
│          ┌────────────┴────────────┐                               │
│          ▼                         ▼                               │
│    ┌──────────┐              ┌──────────┐                          │
│    │ RADIUS   │              │ STAKING  │                          │
│    │ UNLOCK   │              │  (v2)    │                          │
│    └────┬─────┘              └────┬─────┘                          │
│         │                         │                                │
│         └────────────┬────────────┘                                │
│                    │                                                │
│         ┌─────────────────────┐                                     │
│         │    TOKEN SPLIT      │                                     │
│         └──────────┬──────────┘                                     │
│                    │                                                │
│         ┌──────────┴──────────┐                                     │
│         ▼                     ▼                                     │
│   ┌──────────┐         ┌──────────┐                                 │
│   │  BURNED  │         │ TREASURY │                                 │
│   │  (50%)   │         │  (50%)   │                                 │
│   │ 🔥🔥🔥   │         │          │                                 │
│   └──────────┘         └──────────┘                                 │
│                              │                                      │
│                              ▼                                      │
│                    ┌─────────────────┐                              │
│                    │   OPERATIONS    │                              │
│                    │  • Development  │                              │
│                    │  • Marketing    │                              │
│                    │  • Team Costs   │                              │
│                    └─────────────────┘                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.2 Token Velocity Management

To prevent excessive velocity (tokens moving too fast without utility):

| Mechanism | Effect |
|-----------|--------|
| **Staking Rewards** | Incentivizes holding |
| **Tiered Benefits** | Higher stakes = better perks |
| **Lock-up Bonuses** | Extra rewards for time-locked tokens |
| **Burn Rate** | Reduces circulating supply |

---

## 7. BURN MECHANICS

### 7.1 Burn Sources & Rates

| Source | Burn Rate | Annual Estimate* |
|--------|-----------|------------------|
| **Radius Unlocks** | 40-50% | 15-25M $PSZ |
| **Business Pins** | 30% | 3-5M $PSZ |
| **Custom Icons** | 100% | 1-2M $PSZ |
| **Premium Features** | 50% | 2-3M $PSZ |
| **Failed Moderation** | 100% | 0.5-1M $PSZ |
| **Spam Penalties** | 100% | 0.5-1M $PSZ |
| **TOTAL ANNUAL BURN** | — | **22-37M $PSZ** |

*Estimates based on 500K DAU at maturity

### 7.2 Burn Mechanism Implementation

```
When user spends tokens:
├── 50% → Burn Address (0x000...dead)
│   └── Permanently removed from circulation
│
└── 50% → Treasury
    ├── 30% → Operations
    ├── 40% → Development
    └── 30% → Marketing/Growth
```

### 7.3 Deflationary Timeline

| Year | Emissions | Estimated Burns | Net Change |
|------|-----------|-----------------|------------|
| Year 1 | +100M | -12M | +88M |
| Year 2 | +80M | -28M | +52M |
| Year 3 | +60M | -45M | +15M |
| Year 4 | +48M | -55M | -7M |
| Year 5 | +40M | -60M | -20M |

**Target:** Net deflationary by Year 4

### 7.4 Burn Transparency

All burns are:
- Publicly verifiable on-chain
- Tracked on dedicated dashboard
- Reported in monthly transparency reports
- Sent to verified burn address

---

## 8. STAKING & GOVERNANCE

### 8.1 Staking Tiers (Phase 2 Feature)

| Tier | Stake Required | Mining Boost | Radius Benefit | Governance |
|------|----------------|--------------|----------------|------------|
| **Explorer** | 100 $PSZ | +5% | — | View proposals |
| **Pioneer** | 1,000 $PSZ | +15% | Free 30km | Vote on proposals |
| **Sentinel** | 10,000 $PSZ | +25% | Free 50km | Vote + delegate |
| **Guardian** | 50,000 $PSZ | +40% | Free unlimited | Submit proposals |
| **Founder** | 100,000 $PSZ | +50% | Free unlimited + early features | Full governance rights |

### 8.2 Staking Mechanics

**Lock Periods:**
| Period | Bonus Multiplier |
|--------|------------------|
| No lock (flexible) | 1.0x |
| 30 days | 1.2x |
| 90 days | 1.5x |
| 180 days | 2.0x |
| 365 days | 3.0x |

**Example:**
- Stake 10,000 $PSZ for 90 days
- Base Sentinel benefits (+25% mining)
- Lock bonus: 1.5x → +37.5% effective mining boost

### 8.3 Governance Rights

**Voting Power:**
- 1 staked $PSZ = 1 vote
- Lock multipliers apply to voting power
- Delegation allowed (vote on behalf of others)

**Governance Scope:**
| Category | Examples |
|----------|----------|
| **Economic** | Emission rates, burn rates, pricing |
| **Features** | New spending sinks, earning mechanisms |
| **Technical** | Chain migrations, protocol upgrades |
| **Treasury** | Fund allocation, grants |

**Proposal Requirements:**
- Guardian tier (50,000 $PSZ staked) minimum
- 100,000 $PSZ total backing to reach vote
- 7-day voting period
- 51% majority + 10% quorum

---

## 9. ANTI-GAMING PROTECTIONS

### 9.1 Threat Matrix & Mitigations

| Threat | Risk Level | Mitigation Strategy |
|--------|------------|---------------------|
| **Bot Farms** | HIGH | Phone OTP + device fingerprinting + behavioral analysis |
| **GPS Spoofing** | HIGH | Network triangulation + AI anomaly detection + movement patterns |
| **Multi-Accounting** | MEDIUM | 1 wallet per phone + KYC for high earners |
| **Spam Posting** | MEDIUM | Daily caps + cooldowns + AI quality gate |
| **Sybil Attacks** | MEDIUM | Social graph analysis + deposit requirements |
| **Content Theft** | LOW | Reverse image search + content fingerprinting |

### 9.2 Detection Systems

**Real-Time Monitoring:**
```
User Action
    │
    ▼
┌─────────────────┐
│ FRAUD DETECTION │
│    PIPELINE     │
├─────────────────┤
│ • Location check│
│ • Device check  │
│ • Behavior AI   │
│ • Content AI    │
│ • Rate limits   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
  PASS      FLAG
    │         │
    ▼         ▼
 REWARD    REVIEW
           │
      ┌────┴────┐
      │         │
      ▼         ▼
   APPROVE   PENALTY
```

### 9.3 Penalty System

| Violation | First Offense | Second Offense | Third Offense |
|-----------|---------------|----------------|---------------|
| **Spam** | Warning | 24hr mining ban | 7-day ban |
| **GPS Spoof** | 7-day ban | 30-day ban | Permanent ban |
| **Bot Activity** | Permanent ban | — | — |
| **Multi-Account** | Account merge | All accounts banned | — |
| **Content Violation** | Post removed | 7-day ban | Permanent ban |

---

## 10. KEY PERFORMANCE METRICS

### 10.1 Primary KPIs

| Metric | Target (Year 1) | Target (Year 3) | Why It Matters |
|--------|-----------------|-----------------|----------------|
| **Daily Active Users (DAU)** | 50,000 | 500,000 | Core engagement |
| **Daily Posts** | 100,000 | 1,000,000 | Content generation |
| **Tokens Earned/Day** | 1M $PSZ | 5M $PSZ | Economy health |
| **Tokens Burned/Day** | 0.1M $PSZ | 1.5M $PSZ | Deflationary pressure |
| **Radius Unlock Rate** | 5% of DAU | 15% of DAU | Monetization |
| **Business Pins** | 500 | 10,000 | B2B revenue |
| **Token Velocity** | <20 | <15 | Holding incentive |

### 10.2 Health Indicators

**Green (Healthy):**
- Burn rate > 50% of emission rate
- DAU growth > 5% month-over-month
- Average session time > 5 minutes
- Content quality score > 80%

**Yellow (Monitor):**
- Burn rate 25-50% of emission rate
- DAU growth 0-5% month-over-month
- Average session time 2-5 minutes
- Content quality score 60-80%

**Red (Action Required):**
- Burn rate < 25% of emission rate
- DAU declining
- Average session time < 2 minutes
- Content quality score < 60%

### 10.3 Reporting Cadence

| Report | Frequency | Content |
|--------|-----------|---------|
| **Dashboard** | Real-time | Live metrics, burn counter |
| **Weekly Update** | Weekly | Key metrics summary |
| **Monthly Report** | Monthly | Full analytics, treasury |
| **Quarterly Review** | Quarterly | Governance report, adjustments |

---

## 11. LAUNCH STRATEGY

### 11.1 Phase 0: Pre-Launch (Months -3 to 0)

**Objectives:**
- Smart contract audit
- Private beta testing
- Initial liquidity secured
- Launch partnerships signed

**Token Activity:**
- No public tokens
- Team tokens locked
- Test tokens on testnet

### 11.2 Phase 1: Soft Launch (Months 1-3)

**Objectives:**
- Acquire initial user base
- Test earning/spending mechanics
- Gather feedback
- Optimize AI moderation

**Token Configuration:**
| Parameter | Setting | Rationale |
|-----------|---------|-----------|
| Mining rewards | 1.5x normal | Incentivize early adopters |
| Daily cap | 75 $PSZ | Higher early rewards |
| Radius unlocks | 50% discount | Encourage feature adoption |
| Business pins | Free (first 100) | Seed venue network |

### 11.3 Phase 2: Economy Activation (Months 4-6)

**Objectives:**
- Enable all spending features
- Activate burn mechanics
- Launch staking
- First governance votes

**Token Configuration:**
| Parameter | Setting | Rationale |
|-----------|---------|-----------|
| Mining rewards | 1.0x normal | Standard rates |
| Daily cap | 50 $PSZ | Standard cap |
| All features | Full price | Economy active |
| Burns | Active | Begin deflation |
| Staking | Launched | Reduce velocity |

### 11.4 Phase 3: Growth (Months 7-12)

**Objectives:**
- DEX listing
- Major marketing push
- International expansion
- Premium features launch

**Token Configuration:**
| Parameter | Setting | Rationale |
|-----------|---------|-----------|
| Mining rewards | Per schedule | Year 1 emissions |
| New features | Premium pricing | Revenue growth |
| Governance | Full activation | Community control |

### 11.5 Phase 4: Maturity (Year 2+)

**Objectives:**
- CEX listings
- API/Enterprise products
- Sustainable token economy
- Net deflationary

---

## 12. FINANCIAL PROJECTIONS

### 12.1 Revenue Streams (Annual Projections)

| Revenue Source | Year 1 | Year 2 | Year 3 |
|----------------|--------|--------|--------|
| **Radius Unlocks** | $500K | $2M | $5M |
| **Business Pins** | $200K | $1M | $3M |
| **Premium Features** | $50K | $300K | $1M |
| **API/Enterprise** | $0 | $200K | $1M |
| **TOTAL** | **$750K** | **$3.5M** | **$10M** |

*Assuming token price stabilizes at $0.01-$0.05 range

### 12.2 Token Price Scenarios

**Conservative:**
- Launch: $0.001
- Year 1: $0.005
- Year 3: $0.02

**Base Case:**
- Launch: $0.005
- Year 1: $0.02
- Year 3: $0.10

**Optimistic:**
- Launch: $0.01
- Year 1: $0.05
- Year 3: $0.50

### 12.3 Circulating Supply Projections

| Timeframe | Circulating Supply | % of Total |
|-----------|-------------------|------------|
| Launch | 70,000,000 | 7% |
| Month 6 | 150,000,000 | 15% |
| Year 1 | 250,000,000 | 25% |
| Year 2 | 350,000,000 | 35% |
| Year 3 | 400,000,000 | 40% |

*Accounting for vesting unlocks and mining emissions, minus burns

---

## APPENDIX A: GLOSSARY

| Term | Definition |
|------|------------|
| **Active Mining** | Earning tokens through content contribution |
| **Burn** | Permanent removal of tokens from circulation |
| **Permanent Pin** | Business venue marker that doesn't expire |
| **Radius Unlock** | Paid feature to expand map visibility |
| **Staking** | Locking tokens for rewards and governance |
| **Treasury** | Community-governed fund for development |
| **Velocity** | Rate at which tokens change hands |

---

## APPENDIX B: SMART CONTRACT IMPLEMENTATION

### Deployed Contracts

| Contract | Purpose | Key Features |
|----------|---------|--------------|
| **PresenzToken.sol** | ERC20 Token | Mint, burn, pause, role-based access |
| **MiningRewards.sol** | Community Rewards | 7-year emission, daily caps, post limits |
| **VestingContract.sol** | Token Vesting | Team, investor, advisor schedules |
| **TokenAllocation.sol** | Pool Management | BizDev, liquidity, marketing |

### MiningRewards Contract Constants

```solidity
// Reward Constants (Whitepaper Compliant)
uint256 public constant PHOTO_REWARD = 2 * 10**18;        // 2 PSZ
uint256 public constant VIDEO_REWARD = 2 * 10**18;        // 2 PSZ
uint256 public constant VENUE_CHECKIN_REWARD = 5 * 10**18; // 5 PSZ

// Daily Limits
uint256 public constant MAX_POSTS_PER_DAY = 5;            // Max 5 posts
uint256 public constant DAILY_CAP = 10 * 10**18;          // 10 PSZ max/day

// Emission Pool
uint256 public constant TOTAL_MINING_POOL = 400_000_000 * 10**18; // 400M
uint256 public constant EMISSION_YEARS = 7;
```

### TokenAllocation Contract Constants

```solidity
// Allocation Pools
uint256 public constant BUSINESS_DEV_ALLOCATION = 80_000_000 * 10**18;  // 80M (8%)
uint256 public constant LIQUIDITY_ALLOCATION = 50_000_000 * 10**18;     // 50M (5%)
uint256 public constant MARKETING_ALLOCATION = 20_000_000 * 10**18;     // 20M (2%)
uint256 public constant TOTAL_ALLOCATION = 150_000_000 * 10**18;        // 150M (15%)
```

### VestingContract Schedules

```solidity
// Team & Founders: 1-year cliff, 3-year vesting
createTeamVesting(beneficiary, amount);
// → cliffDuration: 365 days
// → vestingDuration: 3 * 365 days

// Investors: 6-month cliff, 18-month vesting
createInvestorVesting(beneficiary, amount);
// → cliffDuration: 180 days
// → vestingDuration: 540 days

// Advisors: 6-month cliff, 2-year vesting
createAdvisorVesting(beneficiary, amount);
// → cliffDuration: 180 days
// → vestingDuration: 2 * 365 days
```

### Key View Functions

```solidity
// MiningRewards
function getUserDailyStats(address user) external view returns (
    uint256 postsToday,
    uint256 postsRemaining,
    uint256 tokensEarned,
    uint256 tokensRemaining
);

function getUserDailyPostsRemaining(address user) external view returns (uint256);
function getRemainingMiningPool() external view returns (uint256);
function getCurrentYear() public view returns (uint256);
```

---

## APPENDIX C: RISK FACTORS

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Regulatory changes | Medium | High | Legal compliance team, jurisdiction flexibility |
| Smart contract exploit | Low | Critical | Multiple audits, bug bounty, insurance |
| Market manipulation | Medium | Medium | Liquidity locks, vesting schedules |
| Low adoption | Medium | High | Strong marketing, partnerships |
| Competitor emergence | High | Medium | First-mover advantage, unique features |

---

## DOCUMENT CONTROL

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 14, 2026 | PRESENZ Team | Initial draft |
| 1.1 | January 16, 2026 | PRESENZ Team | Updated to Base blockchain; Removed engagement multiplier system |
| 2.0 | February 3, 2026 | PRESENZ Team | **Whitepaper alignment**: Updated rewards (2 PSZ photo/video, 5 PSZ venue), daily cap (10 PSZ), max posts (5/day); Added smart contract implementation details; Added TokenAllocation contract docs |

---

**DISCLAIMER:** This document is for informational purposes only and does not constitute financial advice. Token economics are subject to change based on market conditions, regulatory requirements, and community governance decisions.

---

*© 2026 PRESENZ. All Rights Reserved.*
