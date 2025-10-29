### Initial Configuration

Set the following parameters immediately after deployment, with change controls.

- Governance and Roles
  - Grant `ADMIN` to multisig; set `governance` where applicable
  - Configure timelock on governance actions

- Treasury and Fees
  - `setTreasury` on UCE and strategies
  - Per-asset `setAssetTinBps`; start small and iterate
  - Allocator `borrowFeeBps` per line-of-credit

- Assets and Pockets
  - `addAsset(asset, family, globalPocket, reserveBps)`
  - Verify pocket allowances and balances

- Oracles
  - `setOracle(asset, baseFeed|usdFeed, heartbeat, mintHaircutBps, enabled)`
  - For non-USD families, `setBaseUsdFeed`

- Allocators
  - `setAllocatorSingleByAdmin(SET_ALLOCATOR)` with `ceiling` and `dailyCap`
  - Optional `UPDATE_POCKET` for per-allocator pockets

- Strategies
  - Strategy `setTreasury`, `setFeeBps` (owner = UPM)
  - Whitelist pockets via governance actions
