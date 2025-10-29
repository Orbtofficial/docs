### StakingRewards Errors

Core revert reasons:
- Ownership/permissions:
  - `Caller is not owner` for owner-only functions
  - `Caller is not RewardsDistribution contract` for `notifyRewardAmount`
- Parameter checks:
  - `Rewards and staking tokens must not be the same`
  - `Invalid owner`
  - `Cannot stake 0`, `Cannot withdraw 0`
  - `Provided reward too high` when funding is insufficient for configured rate/duration
