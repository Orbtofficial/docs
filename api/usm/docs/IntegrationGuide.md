# sOxAsset: Integration Guide

This document is for integrators (protocols, front-ends, strategy builders, market makers) who want to integrate with the sOxAsset vault. It explains the interface, behaviors, and edge-cases relevant for safe DeFi integrations.

## Summary

- sOxAsset is a UUPS-upgradeable, ERC20 share token and ERC4626-compatible vault over an underlying ERC20 ("0x Asset").
- Share price (exchange rate) grows over time via accumulator math, parameterized by `rateRay` (per-second factor in 1e27 RAY).
- Accrual is lazy: any user can call `drip()` to sync state. In rewards-only mode, the exchange rate is frozen and only rewards accrue.
- Optional rewards streaming pays a secondary token (e.g., ORBT) to share holders; users claim via `claim()`.
- Exit controls include `exitBufferBps` (liquidity-aware cap) and `minUnstakeDelay` (anti-rapid-unstake lock).

## Canonical Interface

See `../IS0xAsset.sol` for the full, documented interface. Key surface:

- ERC20 shares: `totalSupply()`, `balanceOf()`, `transfer()`, `approve()`
- ERC4626 vault: `deposit()`, `mint()`, `withdraw()`, `redeem()`, previews and conversions
- sOxAsset-specific views:
  - `underlyingAsset()`, `rateRay()`, `exchangeRateRay()`, `previewExchangeRateRay()`
  - rewards: `rewardToken()`, `rewardVault()`, `rewardRatePerSecond()`, `rewardIndexRay()`, `previewRewardIndexRay()`, `claimable(account)`
  - exit controls: `exitBufferBps()`, `minUnstakeDelay()`, `earliestUnstakeTime(account)`
- sOxAsset-specific actions:
  - `drip()`: accrue interest/rewards; may mint underlying interest to the vault
  - `claim(to, amount)`: claims streaming rewards to `to` (amount=0 claims all)

## Integration Patterns

### 1) Deposits and Mints

- Use `deposit(assets, receiver)` to provide a known amount of underlying and receive shares.
- Use `mint(shares, receiver)` to target a precise share amount (calibrated by `previewMint(shares)`).
- Pre-check with `previewDeposit`/`previewMint`. These previews reflect time-based exchange rate via `previewExchangeRateRay()`.

Gas and UX tips:
- Consider calling `drip()` before quoting to minimize slippage between preview and execution in volatile `rateRay` regimes.
- Approve the vault for the exact amount (or max) before deposit/mint.

### 2) Withdrawals and Redeems

- `withdraw(assets, receiver, owner)` burns the minimal shares to extract a fixed `assets`.
- `redeem(shares, receiver, owner)` burns exactly `shares` to extract the computed assets.
- Previews: `previewWithdraw(assets)`, `previewRedeem(shares)`.

Constraints:
- `exitBufferBps` caps the maximum withdrawable amount per call relative to current on-chain liquidity; plan multi-tx exits if needed.
- `minUnstakeDelay` may block newly received shares (including via transfer) from being redeemed until the delay elapses. Read `earliestUnstakeTime(owner)`.

### 3) Interest Accrual: `drip()`

- Anyone may call `drip()`; it updates `exchangeRateRay` and mints underlying interest to the vault if rewards-only mode is disabled.
- In rewards-only mode, `drip()` advances time for rewards but keeps `exchangeRateRay` fixed.
- For off-chain pricing, use `previewExchangeRateRay()` to avoid mutation.

### 4) Rewards Streaming and Claiming

- Integrators can surface `claimable(user)` balances and provide a `claim(to, amount)` button.
- Rewards are pulled from a pre-funded `rewardVault` using `transferFrom`; the vault must be approved by the reward vault.
- `amount=0` claims the full available amount.

### 5) Governance-Sensitive Params (Read-only for Integrators)

- `rateRay`: per-second growth factor (RAY). Governance may change via multisig. If set to 1e27, growth is paused (0%).
- `rewardsOnlyMode`: if true, interest minting is disabled; only rewards accrue.
- `rewardRatePerSecond`, `rewardToken`, `rewardVault`: reward stream configuration.
- `minUnstakeDelay`, `exitBufferBps`: exit safety knobs.

Integrators should treat these as dynamic and rely on view reads prior to user flows.

## Risk & Safety Considerations

- Underlying Mint Authority: The vault mints interest in underlying during `drip()`; the underlying must authorize the vault as minter in production. If not, `drip()` will revert when interest > 0.
- Pausable: `deposit`, `withdraw`, `redeem`, `claim`, and `drip` are disabled while paused.
- Rounding: Previews use conservative rounding; `withdraw` may burn slightly more shares due to `mulDivUp` semantics.
- Reentrancy: NonReentrant guards are in place; avoid composing untrusted callbacks around user actions.

## Off-chain Quoting & Indexing

- Use `previewExchangeRateRay()` and `previewRewardIndexRay()` for time-consistent quotes without state mutation.
- To display APY, approximate from `rateRay` using continuous compounding: `apr ≈ (rateRay / 1e27 - 1) * seconds_per_year` (first-order for small deltas), or exponentiate for precision.
- Indexers should update user reward snapshots on `Transfer` and on `RewardAccrued`/`RewardClaimed` events.

## Example Flows

Deposit 1,000 assets:
1. `underlying.approve(vault, 1000e18)`
2. `shares = vault.deposit(1000e18, user)`

Withdraw 500 assets later:
1. `sharesToBurn = vault.previewWithdraw(500e18)`
2. `vault.withdraw(500e18, user, user)`

Claim accrued rewards:
1. `amount = vault.claimable(user)`
2. `vault.claim(user, 0)` // claim full

## Interface Reference

Refer to `../IS0xAsset.sol`. It is intended to be stable for integrator consumption and versioned alongside the contract implementation.

# User Staking Module (USM)

[![Lint](https://img.shields.io/badge/Lint-passing-brightgreen?logo=github)](#)
[![Tests](https://img.shields.io/badge/Tests-passing-brightgreen?logo=github)](#)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20%2B-363636?logo=solidity)](#)
[![Foundry](https://img.shields.io/badge/Tested%20with-Foundry-informational)](https://book.getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

High-yield, ERC-4626-compatible staking vaults for 0x assets with governance-controlled interest and optional external rewards.

— sOxAsset: stake 0x assets, receive appreciating shares, earn native yield + reward tokens.

## Highlights

- **ERC-4626 Vaults**: Standardized deposit/mint/withdraw/redeem and preview flows.
- **Accumulator-Based Yield**: Per-second compounding via `exchangeRateRay` (RAY precision).
- **Dual Rewards**: Native interest + external token emissions (from a pre-funded vault).
- **Governance Controlled**: Multi-sig adjustable rate and reward configuration.
- **Risk Controls**: Exit buffer and optional unstake delay.
- **Upgradeable & Pausable**: UUPS upgrade path and emergency pause.

## Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Contracts](#contracts)
- [Governance](#governance)
- [Security](#security)
- [Quickstart](#quickstart)
- [Local Development](#local-development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Integration Examples](#integration-examples)
- [FAQ](#faq)
- [License](#license)

## Overview

The User Staking Module (USM) provides yield-bearing staking for 0x assets through `sOxAsset` vaults (e.g., s0xBTC, s0xETH, s0xUSD). Users deposit the underlying 0x asset and receive ERC-20 shares that appreciate over time via a global exchange rate controlled by governance. Optionally, vaults can distribute external reward tokens linearly over time.

Key advantages:

1. **Gas-efficient accrual**: Global accumulator avoids per-user interest updates.
2. **Composability**: Full ERC-4626 compliance for seamless DeFi integrations.
3. **Configurable economics**: Governance-managed interest and rewards.
4. **Operational safety**: Exit buffers and unstake delays to manage liquidity risk.

## Architecture

The USM architecture consists of three layers:

### Core Vaults (ERC-4626)

```
┌─────────────────────────────────────────────────────────┐
│                     sOxAsset Contract                   │
├─────────────────────────────────────────────────────────┤
│  ERC-4626: deposit/mint/withdraw/redeem + previews      │
│  Exchange rate accumulator (RAY)                        │
│  Drip-based interest accrual                            │
│  Optional external rewards (global index)               │
└─────────────────────────────────────────────────────────┘
```

### Governance Integration

- Multi-sig timelock sets interest and reward parameters through `executeGovernanceAction`.
- Supported actions: `SET_RATE`, `SET_REWARD_CONFIG`, `SET_REWARDS_ONLY_MODE`.

### Risk & Ops

- Exit buffer caps single-withdraw size vs TVL.
- Unstake delay enforces a minimum holding time before redemptions.
- UUPS upgrades and `Pausable` for emergency response.

## Contracts

- `src/sOxAsset.sol`: Core ERC-4626-like vault with:
  - `exchangeRateRay`, `rateRay`, `drip()` interest minting (requires mintable underlying)
  - Rewards index accounting and `claim()` via pre-funded `rewardVault`
  - Exit buffer and `minUnstakeDelay` enforcement
  - Governance action execution hooks

## Governance

Governance interacts via `executeGovernanceAction(bytes32 actionType, bytes payload)`:

- `SET_RATE(uint256 newRateRay)`
- `SET_REWARD_CONFIG(address rewardToken, address rewardVault, uint256 rewardRatePerSecond)`
- `SET_REWARDS_ONLY_MODE(bool enabled)`

Notes:

- `newRateRay ≥ RAY` (no negative rates). Rate changes `drip()` before applying.
- Rewards config accrues pending rewards before mutation.
- Rewards-only mode freezes exchange rate (sets rate to `RAY`) and continues rewards accrual.

### ERC-4626 Tokenized Vault Standard

The USM implements the full ERC-4626 specification, making it compatible with the broader DeFi ecosystem.

#### Core Functions

**Deposit Functions**:
```solidity
// Deposit exact assets, receive shares
function deposit(uint256 assets, address receiver) external returns (uint256 shares);

// Mint exact shares, deposit required assets
function mint(uint256 shares, address receiver) external returns (uint256 assets);
```

**Withdrawal Functions**:
```solidity
// Withdraw exact assets, burn required shares
function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

// Redeem exact shares, receive assets
function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
```

**Preview Functions**:
```solidity
// Preview share/asset conversions
function previewDeposit(uint256 assets) external view returns (uint256 shares);
function previewMint(uint256 shares) external view returns (uint256 assets);
function previewWithdraw(uint256 assets) external view returns (uint256 shares);
function previewRedeem(uint256 shares) external view returns (uint256 assets);
```

**Accounting Functions**:
```solidity
function totalAssets() external view returns (uint256);
function convertToShares(uint256 assets) external view returns (uint256);
function convertToAssets(uint256 shares) external view returns (uint256);
function maxDeposit(address) external view returns (uint256);
function maxMint(address) external view returns (uint256);
function maxWithdraw(address owner) external view returns (uint256);
function maxRedeem(address owner) external view returns (uint256);
```

#### ERC-4626 Compliance Benefits

1. **Standardized Interface**: Works with any ERC-4626-compatible protocol
2. **Composability**: Can be used as collateral, in yield aggregators, etc.
3. **Tooling Support**: Compatible with existing vault management tools
4. **Auditor Familiarity**: Well-understood standard reduces audit scope
5. **Future-Proof**: New ERC-4626 integrations work automatically

## Security

Threat model and controls:

- **Underlying Minter Rights**: Vault mints interest; ensure minter permissions restricted to vault only.
- **Rate Bounds**: Validate `rateRay` changes off-chain; extremely high values can break assumptions.
- **Reward Vault Solvency**: `claim()` pulls from `rewardVault` allowance; monitor balances and approval.
- **Unstake Delay**: Mitigates flash-loan gaming of rewards/interest.
- **Pausable + UUPS**: Emergency pause and controlled upgrades by `ADMIN`.
- **Math Precision**: RAY math with `Math.mulDiv`; rounding down where safety-critical.

Formal audits and additional reviews are recommended before mainnet deployment.

## Quickstart

Prereqs: Foundry (forge/cast), Git, Node.js (optional for scripts), Python (optional).

```bash
git clone https://github.com/Orbtofficial/usm.git
cd usm
forge --version
```

Build and test:

```bash
forge build
forge test -vv
```

Run a single test file:

```bash
forge test -vvv --match-path test/SOxAsset.t.sol
```

Format and lint (if configured):

```bash
forge fmt
```

## Local Development

Install dependencies and set up remappings (Foundry handles via submodules/vendor libs):

```bash
forge build
```

Useful commands:

```bash
# Run all tests with gas report
forge test --gas-report

# Run a specific test
forge test --match-test test_rewards_single_user_full_claim

# Profile a test
forge test --match-test test_rewards_two_users_proportional -vvv

# Deploy to a local anvil chain (example script)
anvil &
```

Environment variables (if you add deploy scripts):

```bash
export RPC_URL=http://localhost:8545
export PRIVATE_KEY=<hex>
```

Project layout:

```
src/                      # Contracts (e.g., sOxAsset.sol)
test/                     # Unit/integration tests
lib/                      # External libs (OZ, forge-std)
script/                   # Optional deploy/ops scripts
foundry.toml              # Foundry config
```

## Testing

Tests cover ERC-4626 flows, interest accrual, rewards, governance actions, and edge cases.

```bash
forge test -vv
```

Focus examples:

```bash
forge test --match-test test_previewDeposit_and_previewMint_consistent
forge test --match-test test_rewards_two_users_proportional
forge test --match-test test_setRate_requires_multisig
```

## Deployment

High-level guidance (adapt to your tooling):

1. Deploy underlying 0x asset (mintable) and grant MINTER to the vault proxy.
2. Deploy `sOxAsset` implementation and UUPS proxy; call `initialize`.
3. Set governance address via `setGovernance` (one-time) and register actions.
4. Configure rewards via governance; fund `rewardVault` and approve the vault.
5. Optionally set `exitBufferBps` and `minUnstakeDelay` (ADMIN).

Post-deploy checks:

- `exchangeRateRay == RAY`, `rewardsOnlyMode` as intended, reward config set, `totalAssets()` sane.

## Integration Examples

The USM uses an accumulator-based model where interest compounds continuously:

#### Exchange Rate Accumulator

```solidity
// Fixed-point arithmetic with 27 decimals (RAY)
uint256 internal constant RAY = 1e27;

// Global exchange rate: assets per 1 share
uint256 public exchangeRateRay; // Initialized to 1 RAY (1e27)

// Per-second interest factor (RAY)
uint256 public rateRay; // e.g., 1.000000001 RAY for ~3.2% APY

// Last accrual timestamp
uint256 public lastAccrual;
```

#### Drip Mechanism

The `drip()` function updates the exchange rate based on elapsed time:

```solidity
function drip() public {
    uint256 currentTime = block.timestamp;
    uint256 elapsed = currentTime - lastAccrual;
    
    if (elapsed == 0) return; // No time passed
    
    // 1. Calculate compounded rate
    // exchangeRate' = exchangeRate * (rateRay ^ elapsed)
    uint256 compoundFactor = _rpow(rateRay, elapsed);
    uint256 newExchangeRateRay = (exchangeRateRay * compoundFactor) / RAY;
    
    // 2. Calculate interest accrued
    uint256 totalSharesBefore = totalSupply();
    if (totalSharesBefore > 0 && !rewardsOnlyMode) {
        uint256 assetsBefore = (totalSharesBefore * exchangeRateRay) / RAY;
        uint256 assetsAfter = (totalSharesBefore * newExchangeRateRay) / RAY;
        uint256 interestAccrued = assetsAfter - assetsBefore;
        
        // 3. Mint new underlying to vault
        IMintableERC20(address(underlyingAsset)).mint(address(this), interestAccrued);
        
        emit Drip(newExchangeRateRay, interestAccrued);
    }
    
    // 4. Update state
    exchangeRateRay = newExchangeRateRay;
    lastAccrual = currentTime;
}
```

#### Mathematical Foundation

The compound interest formula used:
```
A(t) = P * (1 + r)^t
```

Where:
- `A(t)` = Amount after time t
- `P` = Principal (initial amount)
- `r` = Interest rate per period
- `t` = Number of periods

In RAY precision:
```solidity
// For 3.2% APY:
// rateRay = 1.000000001 RAY (per second)
// After 1 year (31536000 seconds):
// exchangeRateRay = 1 RAY * (1.000000001)^31536000 ≈ 1.032 RAY
```

#### Rate Conversion Examples

**APY to Per-Second Rate**:
```solidity
// Target: 5% APY
// Formula: rateRay = (1 + APY)^(1/secondsPerYear) * RAY
// Result: rateRay ≈ 1.000000001547125 RAY
```

**Rate Setting**:
```solidity
// Set 5% APY
uint256 targetAPY = 0.05e18; // 5% in 18 decimals
uint256 rateRay = _calculateRateFromAPY(targetAPY);
// ... execute via governance
```

### Yield Accrual Mechanics

Users earn yield through two mechanisms:

#### 1. Native Yield (Exchange Rate Appreciation)

**Deposit Time**:
```solidity
// User deposits 100 0xBTC when exchangeRateRay = 1 RAY
assets = 100e18;
shares = (assets * RAY) / exchangeRateRay = 100e18 shares
```

**After 1 Year (5% APY)**:
```solidity
// exchangeRateRay now = 1.05 RAY
assetsNow = (shares * exchangeRateRay) / RAY
         = (100e18 * 1.05e27) / 1e27
         = 105e18 0xBTC

// User can redeem 105 0xBTC (5% gain)
```

#### 2. External Reward Tokens

Additional rewards distributed from a pre-funded vault:

```solidity
// Reward configuration
IERC20 public rewardToken;         // e.g., ORBT token
address public rewardVault;         // Pre-funded vault address
uint256 public rewardRatePerSecond; // e.g., 0.1 ORBT per second
```

**Reward Accrual**:
```solidity
function _accrueRewards() internal {
    if (rewardRatePerSecond == 0) return;
    
    uint256 elapsed = block.timestamp - lastRewardAccrual;
    uint256 totalShares = totalSupply();
    
    if (totalShares == 0) return;
    
    // 1. Calculate total rewards for period
    uint256 totalRewards = rewardRatePerSecond * elapsed;
    
    // 2. Update global reward index (rewards per share)
    // rewardIndex' = rewardIndex + (totalRewards * RAY / totalShares)
    uint256 rewardsPerShare = (totalRewards * RAY) / totalShares;
    rewardIndexRay += rewardsPerShare;
    
    // 3. Update timestamp
    lastRewardAccrual = block.timestamp;
    
    emit RewardAccrued(rewardIndexRay, totalRewards, elapsed);
}
```

**User Reward Tracking**:
```solidity
// Per-user accounting
mapping(address => uint256) public userRewardIndexRay;
mapping(address => uint256) public accruedRewards;

function _updateUserRewards(address user) internal {
    uint256 userShares = balanceOf(user);
    if (userShares == 0) return;
    
    // Calculate rewards earned since last update
    uint256 indexDelta = rewardIndexRay - userRewardIndexRay[user];
    uint256 rewardsEarned = (userShares * indexDelta) / RAY;
    
    // Accumulate
    accruedRewards[user] += rewardsEarned;
    userRewardIndexRay[user] = rewardIndexRay;
}
```

**Claiming Rewards**:
```solidity
function claimRewards(address to) external returns (uint256 claimed) {
    _accrueRewards();
    _updateUserRewards(msg.sender);
    
    claimed = accruedRewards[msg.sender];
    if (claimed > 0) {
        accruedRewards[msg.sender] = 0;
        
        // Pull from pre-funded vault
        IERC20(rewardToken).safeTransferFrom(rewardVault, to, claimed);
        
        emit RewardClaimed(msg.sender, to, claimed);
    }
}
```

### Rewards System

The rewards system enables distribution of external tokens to stakers:

#### Reward Configuration

Set via governance:
```solidity
function executeGovernanceAction(bytes32 actionType, bytes calldata payload) external {
    if (actionType == ACT_SET_REWARD_CONFIG) {
        (address token, address vault, uint256 rate) = abi.decode(
            payload, 
            (address, address, uint256)
        );
        _setRewardConfig(token, vault, rate);
    }
}

function _setRewardConfig(
    address rewardToken_,
    address rewardVault_,
    uint256 rewardRatePerSecond_
) internal {
    // Update configuration
    rewardToken = IERC20(rewardToken_);
    rewardVault = rewardVault_;
    rewardRatePerSecond = rewardRatePerSecond_;
    
    emit RewardConfigSet(rewardToken_, rewardVault_, rewardRatePerSecond_);
}
```

#### Reward Vault Setup

The reward vault must:
1. Hold sufficient reward tokens
2. Grant allowance to s0xAsset contract
3. Maintain buffer for distribution period

**Example Setup**:
```solidity
// 1. Deploy reward vault (can be simple EOA or contract)
address rewardVault = 0x123...;

// 2. Fund with rewards (e.g., 1M ORBT for 1 year)
uint256 totalRewards = 1_000_000e18;
ORBT.transfer(rewardVault, totalRewards);

// 3. Approve s0xBTC to spend
vm.prank(rewardVault);
ORBT.approve(address(s0xBTC), type(uint256).max);

// 4. Configure via governance
uint256 rewardRate = totalRewards / 365 days; // ~0.0317 ORBT/sec
// ... execute SET_REWARD_CONFIG action
```

#### Rewards-Only Mode

Special mode where only external rewards accrue (no underlying minting):

```solidity
bool public rewardsOnlyMode;

function drip() public {
    // ... calculate exchange rate growth
    
    if (!rewardsOnlyMode) {
        // Normal mode: mint underlying interest
        uint256 interestAccrued = calculateInterest();
        IMintableERC20(underlyingAsset).mint(address(this), interestAccrued);
    }
    
    // Always accrue external rewards
    _accrueRewards();
}
```

**Use Cases**:
- **Partnership Rewards**: External protocol rewards s0xAsset holders without USM minting underlying
- **Promotional Campaigns**: Temporary boost to APY via rewards-only mode
- **Yield Optimization**: Combine with other yield sources

#### Reward Economics

**Annual Reward Calculation**:
```solidity
// 0.1 ORBT per second
rewardRatePerSecond = 0.1e18;

// Per year
annualRewards = 0.1 * 31536000 = 3,153,600 ORBT

// With 10M 0xBTC staked:
rewardAPR = (3,153,600 / 10,000,000) * 100 = 31.536%
```

**Combined APY**:
```
Total APY = Native Yield APY + Reward Token APY
          = 5% + 31.536% = 36.536%
```

### Exit Buffer and Withdraw Limits

The exit buffer limits how much can be withdrawn at once, providing stability during stress:

#### Exit Buffer Configuration

```solidity
// Maximum withdrawable as % of total assets
uint256 public exitBufferBps; // e.g., 5000 = 50%
```

#### maxWithdraw Implementation

```solidity
function maxWithdraw(address owner) public view returns (uint256) {
    // 1. Calculate user's maximum withdrawable shares
    uint256 userShares = balanceOf(owner);
    uint256 userAssets = convertToAssets(userShares);
    
    // 2. Calculate protocol's maximum allowed withdrawal
    uint256 totalAssets_ = totalAssets();
    uint256 maxAllowed = (totalAssets_ * exitBufferBps) / BPS;
    
    // 3. Apply unstake delay check
    if (minUnstakeDelay > 0) {
        if (block.timestamp < earliestUnstakeTime[owner]) {
            return 0; // Locked
        }
    }
    
    // 4. Return minimum
    return userAssets < maxAllowed ? userAssets : maxAllowed;
}
```

#### Economic Rationale

**Without Exit Buffer**:
- Large withdrawals could drain vault
- Remaining users bear higher risk
- Potential for bank run dynamics

**With Exit Buffer (50%)**:
- Max single withdrawal = 50% of TVL
- Forces large exits to occur over time
- Provides price discovery period
- Allows governance to respond

### Unstake Delay

Optional time-lock that prevents immediate withdrawals after receiving shares:

#### Delay Configuration

```solidity
uint256 public minUnstakeDelay; // seconds, 0 = disabled
mapping(address => uint256) public earliestUnstakeTime;
```

#### Delay Enforcement

```solidity
function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
    super._afterTokenTransfer(from, to, amount);
    
    if (minUnstakeDelay > 0 && to != address(0) && amount > 0) {
        // Set earliest unstake time for receiver
        uint256 newEarliestTime = block.timestamp + minUnstakeDelay;
        
        // Only update if new time is later (max of existing and new)
        if (newEarliestTime > earliestUnstakeTime[to]) {
            earliestUnstakeTime[to] = newEarliestTime;
        }
    }
}

function withdraw(uint256 assets, address receiver, address owner) public returns (uint256 shares) {
    // Check unstake delay
    if (minUnstakeDelay > 0) {
        require(block.timestamp >= earliestUnstakeTime[owner], "Unstake delay not elapsed");
    }
    
    // ... proceed with withdrawal
}
```

#### Delay Economics

**Purpose**:
- Prevent flash-loan attacks on yield
- Discourage mercenary capital
- Stabilize TVL

**Typical Values**:
- **No Delay (0)**: Maximum liquidity, suitable for mature protocols
- **1 Hour**: Minimal delay, prevents same-block exploits
- **24 Hours**: Standard DeFi delay
- **7 Days**: Conservative, discourages hot money

#### Delay Update

Set via admin (non-governance for operational flexibility):
```solidity
function setMinUnstakeDelay(uint256 newDelay) external onlyRole(ADMIN) {
    uint256 oldDelay = minUnstakeDelay;
    minUnstakeDelay = newDelay;
    emit MinUnstakeDelaySet(oldDelay, newDelay);
}
```

**Important**: Changing delay does NOT affect existing users' timestamps, only future deposits/transfers.

## Governance Integration

The USM integrates with ORBT governance for secure rate management:

### Governance Actions

#### SET_RATE

Update the per-second interest rate:

```solidity
// Governance payload
bytes memory payload = abi.encode(newRateRay);

// Internal handler
function _handleSetRate(uint256 newRateRay) internal {
    require(newRateRay >= RAY, "Rate too low"); // Must be ≥ 1 (no negative rates)
    
    // Drip before changing rate
    drip();
    
    uint256 oldRate = rateRay;
    rateRay = newRateRay;
    
    emit RateSet(oldRate, newRateRay);
}
```

#### SET_REWARD_CONFIG

Configure external reward token emissions:

```solidity
// Governance payload
bytes memory payload = abi.encode(rewardTokenAddress, vaultAddress, ratePerSecond);

// Internal handler
function _handleSetRewardConfig(
    address rewardToken_,
    address vault_,
    uint256 rate_
) internal {
    // Accrue existing rewards before config change
    _accrueRewards();
    
    rewardToken = IERC20(rewardToken_);
    rewardVault = vault_;
    rewardRatePerSecond = rate_;
    
    emit RewardConfigSet(rewardToken_, vault_, rate_);
}
```

#### SET_REWARDS_ONLY_MODE

Toggle between full accrual and rewards-only:

```solidity
// Governance payload
bytes memory payload = abi.encode(enabled);

// Internal handler
function _handleSetRewardsOnlyMode(bool enabled) internal {
    // Drip before mode change
    drip();
    
    rewardsOnlyMode = enabled;
    
    emit RewardsOnlyModeSet(enabled);
}
```

### Execution Flow

```solidity
function executeGovernanceAction(
    bytes32 actionType,
    bytes calldata payload
) external onlyGovernance returns (bool) {
    if (actionType == ACT_SET_RATE) {
        uint256 newRate = abi.decode(payload, (uint256));
        _handleSetRate(newRate);
        return true;
    }
    else if (actionType == ACT_SET_REWARD_CONFIG) {
        (address token, address vault, uint256 rate) = abi.decode(
            payload,
            (address, address, uint256)
        );
        _handleSetRewardConfig(token, vault, rate);
        return true;
    }
    else if (actionType == ACT_SET_REWARDS_ONLY_MODE) {
        bool enabled = abi.decode(payload, (bool));
        _handleSetRewardsOnlyMode(enabled);
        return true;
    }
    
    revert("Unknown action");
}
```

## Integration Examples

### For Users

#### Basic Staking

```solidity
// 1. Approve USM
0xBTC.approve(address(s0xBTC), 100e18);

// 2. Deposit
uint256 shares = s0xBTC.deposit(100e18, msg.sender);

// 3. Wait and accrue yield...

// 4. Redeem (after unstake delay if applicable)
uint256 assets = s0xBTC.redeem(shares, msg.sender, msg.sender);
// Receives original 100 + interest
```

#### With External Rewards

```solidity
// After holding for 1 week
s0xBTC.claimRewards(msg.sender);
// Receives ORBT rewards
```

### For Protocols

#### Collateral Integration

```solidity
// Use s0xBTC as collateral in lending protocol
uint256 collateralValue = s0xBTC.convertToAssets(s0xBTC.balanceOf(user));
```

#### Yield Aggregation

```solidity
// Auto-compound strategy
function harvest() external {
    // 1. Claim rewards
    uint256 rewards = s0xBTC.claimRewards(address(this));
    
    // 2. Swap rewards for underlying
    uint256 underlying = swapORBTFor0xBTC(rewards);
    
    // 3. Re-stake
    s0xBTC.deposit(underlying, address(this));
}
```

## Gas Optimization Tips

- Call `drip()` before any rate-sensitive operation to update state
- Batch reward claims with other operations
- Use `previewRedeem` off-chain to calculate exact amounts before transaction
- Consider delegating reward claims to reduce user gas costs

## Events Reference

```solidity
event Drip(uint256 newExchangeRateRay, uint256 mintedInterest);
event RateSet(uint256 oldRateRay, uint256 newRateRay);
event RewardAccrued(uint256 newRewardIndexRay, uint256 rewards, uint256 dt);
event RewardClaimed(address indexed user, address indexed to, uint256 amount);
event RewardConfigSet(address rewardToken, address rewardVault, uint256 rewardRatePerSecond);
event RewardsOnlyModeSet(bool enabled);
event MinUnstakeDelaySet(uint256 oldDelay, uint256 newDelay);
```

## FAQ

**Q: Can I withdraw immediately after depositing?**
A: Depends on `minUnstakeDelay`. If set to 0, yes. Otherwise, you must wait.

**Q: Do I need to claim rewards to earn them?**
A: No, rewards accrue automatically. Claiming just transfers them to your wallet.

**Q: What happens if the reward vault runs out of tokens?**
A: Reward claims will fail. Monitor vault balance and refill as needed.

**Q: Can the exchange rate decrease?**
A: No, `rateRay` is always ≥ 1 RAY. The exchange rate can only increase or stay flat.

**Q: Is s0xBTC transferable?**
A: Yes, fully transferable like any ERC-20. Receiving tokens may reset your unstake timer.

**Q: Can I use s0xBTC as collateral?**
A: Yes, if integrated protocols accept it. Value is `convertToAssets(balance)`.

## License

MIT © Contributors

