### Testnet Deployment

End-to-end checklist with recommended order of operations. Use multisig/timelock addresses where applicable even on testnets.

#### 1) Deploy OrbtUCE (proxy)
- Initialize: `initialize(owner=multisig, family=USD|BTC|ETH)`
- Post-init default: `debtIndex = 1e18`

#### 2) Configure Ox and Treasury
- `setOxAsset(ox)` (cache 18 decimals)
- `setTreasury(treasury)` (non-zero required for fee routing)

#### 3) Add Assets and Pockets
- For each underlying asset `U`:
  - `addAsset(U, family, globalPocket, reserveBps)`; event `PocketSet(U, 0, globalPocket, 0)`
  - `setAssetTinBps(U, tinBps)` (0 allowed)
  - Optional: `setAssetReserveBps(U, reserveBps)` to override default
  - Ensure pocket allowances to UCE are configured sufficiently for anticipated flow

#### 4) Oracles
- If family is USD: `setOracle(U, baseFeed=0, usdFeed, heartbeat, mintHaircutBps, enabled=true)`
- If family is non-USD:
  - Prefer `baseFeed` for direct base pricing; else set `usdFeed` and global `setBaseUsdFeed(feed, heartbeat)`
- Verify quotes via `previewSwapExactIn/Out`

#### 5) Allocators
- For each allocator `A`:
  - Prepare `SetAllocatorMemory` values: `allowed=true`, `line = {ceiling, dailyCap, mintedToday=0, lastMintDay=now_day}`, `borrowFeeBps`
  - `setAllocatorSingleByAdmin(init, [], [], op=SET_ALLOCATOR)`
  - Optionally set per-asset pockets: supply `assets[]` and `pockets[]` with `op=UPDATE_POCKET`
  - Referral code is generated and emitted (`AllocatorReferralSet`)

#### 6) Liquidity Seeding (Optional)
- Use `deposit(U, receiver, assets)` to move custody funds into pockets without minting Ox
- Validate withdraw path with `withdraw(U, receiver, maxAssets)`

#### 7) OrbitUPM and Strategies
- Deploy `OrbitUPM(admin=multisig)`; grant `POCKET` to orchestrators
- Deploy strategy (e.g., `OrbtMMStrategy.initialize(initialOwner=governance, upm=UPM, treasury, feeBps)`)
  - Ownership is transferred to UPM during init; strategy entrypoints are `onlyUPM`
  - Whitelist pockets via strategy governance actions (ACT_WHITELIST_POCKET)

#### 8) sOxAsset (ERC4626 wrapper)
- Deploy `sOxAsset` with underlying `ox`, name/symbol, `initialOwner`, and `rateRay ≥ 1e27`
- Grant `ADMIN` to multisig; set governance via `setGovernance`
- Configure rewards via governance action `SET_REWARD_CONFIG`
- Optional: `setMinUnstakeDelay`, `exitBufferBps`

#### 9) AcrossUCEBridge
- Deploy with `spokePool`, `uceOnSource=UCE_src`, `initialOwner=multisig`
- `setRoute(dstChainId, uceOnDestination, underlyingOnDestination, handlerOnDestination, perTxMax, dailyMax)`
- Validate flows using small amounts; consider `exclusiveRelayer` during canary

#### 10) Final Validation
- Run swap matrix tests: Ox↔U, S↔Ox (exact-in and exact-out)
- Test allocator credit mint/repay
- Exercise pauses (global and per-asset), and ensure reverts
- Verify fees accrue to treasury and events are emitted as expected
