### Best Practices

Operational and integration guidance:

- Privileged Roles
  - Multisig + timelock; avoid EOAs; rotate keys periodically

- Parameter Changes
  - Prefer small, measured changes; monitor impact for 48–72h

- Oracles
  - Choose robust feeds; set heartbeat appropriately; enable mint haircut for volatile assets

- Liquidity
  - Maintain pocket allowance headroom; seed reserves during peak redemptions

- Upgrades
  - Minimize frequency; audit diffs; use staged rollouts with pauses available
