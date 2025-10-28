# Rewards — Emissions & Revenue Distribution

Framework for distributing protocol rewards to stakeholders (e.g., stakers, allocators) sourced from fees, spreads, and strategy profits.

## Sources of Rewards

* **Treasury & Policy Fees**: Mint fees (`tinBps` in 0x), redemption fees (in U), borrow fees (allocator repay path).
* **Strategy Profits**: Money-market profit share routed to treasury; a portion may be streamed to reward programs.
* **Intent Settlement Revenue**: OCH participation can generate net fees; policy may redirect some to stakers.

## Distribution Model (Typical)

* **s0x Staker Rewards**: Periodic distributions to s0x holders or staking participants, pro-rata by **stake × time**.
* **Allocator Incentives**: Optional programs rewarding liquidity reliability (e.g., uptime, allowance levels, fulfillment performance).
* **Program Parameters**: Emission rate, reward asset(s), start/stop times, and eligibility predicates are governed and auditable.

## Accounting & Fairness

* **Snapshot-Consistent**: Rewards are computed against verifiable balances/supply snapshots to prevent manipulation around distribution times.
* **Claim Flows**: Users accrue rewards continuously and can claim at any time (subject to cooldowns/vesting if configured).
* **Transparency**: Events and dashboards surface per-period emissions, unclaimed balances, and program states.

## Risk & Operations

* **Budgeting**: Emissions must not compromise peg or reserves; treasury thresholds enforced by governance.
* **Pausing**: Reward programs can be paused independently from swaps/vaults.
* **Security Posture**: Reward accounting is read-only to core balances; transfers are guarded by standard allowance/role checks.

## Integration Notes

* Index reward **events** for analytics.
* Show **APR/APY estimates** derived from current emission rate and TVL, with caution about variability.
* Surface **unclaimed amounts** and any **vesting** or **cooldown** in the UI.
