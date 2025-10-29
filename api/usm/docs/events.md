### sOxAsset Events

Implements ERC4626-like accounting plus interest and rewards accrual.

- `Drip(uint256 newExchangeRateRay, uint256 mintedInterest)`
  - Emitted on accrual; `mintedInterest` is newly minted underlying to the vault (0 in rewards-only mode)

- `RateSet(uint256 oldRateRay, uint256 newRateRay)`
  - Per-second interest factor updated via governance

- `RewardAccrued(uint256 newRewardIndexRay, uint256 rewards, uint256 dt)`
  - Rewards index increased by `rewards/supply`; `dt` is time elapsed

- `RewardClaimed(address indexed user, address indexed to, uint256 amount)`
  - User claimed `amount` of rewardToken from rewardVault

- `RewardConfigSet(address rewardToken, address rewardVault, uint256 rewardRatePerSecond)`
  - Rewards stream configured

- `RewardsOnlyModeSet(bool enabled)`
  - When enabled, exchangeRateRay is frozen at 1e27; only rewards accrue

- `MinUnstakeDelaySet(uint256 oldDelay, uint256 newDelay)`
  - Global minimum delay applied to recipients on mints/transfers before redeem/withdraw
