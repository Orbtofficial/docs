### Action Types

Modules expose typed governance actions to ensure safe, explicit state changes.

#### OrbtUCE
- `ACT_SET_ALLOCATOR`: `(op, SetAllocatorMemory init, address[] assets, address[] pockets)`
  - `op ∈ { SET_ALLOCATOR, UPDATE_ALLOWED, UPDATE_LINE, UPDATE_BORROW_FEE, UPDATE_POCKET, UPDATE_REFERRAL_CODE }`
- `ACT_SET_ALLOCATOR_POCKETS`: `(allocator, asset, newPocket)`

#### sOxAsset
- `ACT_SET_RATE`: `(uint256 newRateRay ≥ 1e27)`
- `ACT_SET_REWARD_CONFIG`: `(address rewardToken, address rewardVault, uint256 rewardRatePerSecond)`
- `ACT_SET_REWARDS_ONLY_MODE`: `(bool enabled)`
- `ACT_SET_THRESHOLDS`: reserved for future use

#### BaseStrategy / OrbtMMStrategy
- `ACT_WHITELIST_POCKET`: `(address pocket)`
- `ACT_DELIST_POCKET`: `(address pocket)`
- `ACT_SET_GLOBAL_FEE`: `(uint256 feeBps ≤ 10_000)`
- `ACT_SET_POCKET_FEE`: `(address pocket, uint256 feeBps ≤ 10_000)`
- `ACT_SET_TREASURY`: `(address treasury)`
- `ACT_SET_UPM`: `(address upm)`

Notes:
- Actions revert on invalid addresses, fee bounds, or length mismatches
- Some actions emit corresponding events (fee updates, referral set, pocket set)
