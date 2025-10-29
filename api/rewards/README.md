# ORBT Staking Rewards (ORBT Governance Token Staking)

Simple, battle‑tested staking for the ORBT governance token. Users stake ORBT and earn streamed rewards at a fixed rate per period (Synthetix‑style). This module is ONLY for ORBT staking; it does not stake 0xAssets or s0xAssets.

## Architecture (at a glance)

- Staking interface: `stake(amount)`, `withdraw(amount)`, `getReward()`, `exit()`
- Rewards accounting engine:
  - `rewardPerToken()` global accumulator
  - `earned(user)` pending rewards
  - `rewardRate` emissions per second; `rewardPerTokenStored` accumulator
  - `userRewardPerTokenPaid` user checkpoint
- Token management:
  - `stakingToken` (ORBT), `rewardsToken` (ORBT or partner)
  - `_totalSupply` and per‑user `_balances`
- Rewards distribution (guarded):
  - `notifyRewardAmount(reward)` sets `rewardRate` and starts/extends the period

## Roles & Safety

- Owner: set `rewardsDuration`, rotate `rewardsDistribution`, recover non‑staking tokens
- RewardsDistribution: call `notifyRewardAmount`
- Non‑reentrant state‑changing flows; solvency check: `rewardRate <= balance/rewardsDuration`

## What This Is Not

- Not USM staking, not s0x staking
- No locks or ve‑style decay; no ERC‑4626 vaulting

## Quick Links

- Integration guide: `docs/IntegrationGuide.md`
- Events: `docs/events.md`
- Errors: `docs/errors.md`
- Interface: `../IStakingRewards.sol`
- Conceptual overview of rewards in ORBT: `../../concepts/rewards.md`
