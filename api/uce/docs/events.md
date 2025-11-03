### UCE Events

This section enumerates the primary events and their semantics. Event ordering within a transaction follows execution order; previews do not emit events.

- `OxAssetsSet(address oxUSD)`
  - Ox token for this UCE instance; decimals cached to 18

- `TreasurySet(address indexed treasury)`
  - Treasury recipient for fees (tin and borrow fee, redemption fees in underlying)

- `AllocatorSet(address indexed allocator, bool allowed)`
  - Allocator allowlist toggle

- `CreditMinted(address indexed allocator, uint256 amount)`
  - 0xAssets credit minted to UCE contract and reserved to allocator; increases `baseDebt` by `amount` (debt tracked directly in 0xAsset units)

- `CreditLineUpdated(address indexed allocator, uint128 ceiling, uint128 dailyCap)`
  - Line-of-credit parameters updated

- `AllocatorRepaid(address indexed repayer, address indexed allocator, uint256 amountOx)`
  - Repayment applied (amount in Ox-equivalent after borrow fee); reduces allocator debt

- `AllocatorPocketSet(address indexed allocator, address indexed asset, address indexed oldPocket, address newPocket, uint256 migratedAssets)`
  - Per-allocator pocket change for `asset`; migrates allowance-limited balance

- `AssetReserveBpsSet(address indexed asset, uint256 bps)`
  - Reserve policy changed for U→Ox on `asset`

- `AllocatorBorrowFeeSet(address indexed allocator, uint16 bps)`
  - Per-allocator borrow fee updated

- `AllocatorReferralSet(address indexed allocator, uint256 referralCode)`
  - Referral code rotated or set

- `OracleSet(address indexed asset, address baseFeed, address usdFeed, uint32 heartbeat, uint16 mintHaircutBps, bool enabled)`
  - Oracle configuration for U↔Ox pricing on `asset`

- `BaseUsdFeedSet(address indexed feed, uint32 heartbeat)`
  - Global base/USD feed for non-USD families

- `RedemptionFeeTaken(address indexed payer, address indexed assetOut, uint256 oxIn, uint256 feeRate, uint256 feeInUnderlying, uint256 timestamp)`
  - Emitted for Ox→U swaps; fee computed at snapshot rate

- `TinBpsSet(address indexed asset, uint16 bps)`
  - Tin fee updated for U→Ox on `asset`

- `TinFeeTaken(address indexed payer, address indexed assetIn, uint256 oxGross, uint256 feeBps, uint256 feeInOx, uint256 timestamp)`
  - Emitted for U→Ox swaps (exact-in/out); fee minted to treasury when set

- `AssetPaused(address indexed asset, bool paused)`
  - Per-asset pause state changed

- `PocketSet(address indexed asset, address indexed oldPocket, address indexed newPocket, uint256 migratedAssets)`
  - Global pocket set for `asset`

- `Deposit(address indexed asset, address indexed caller, address indexed receiver, uint256 assets, uint256 oxAssets)`
  - Admin-only custody deposit to pocket; `oxAssets` is always 0 for UCE

- `Withdraw(address indexed asset, address indexed caller, address indexed receiver, uint256 assets, uint256 oxAssets)`
  - Admin-only custody withdraw from pocket; `oxAssets` is always 0 for UCE

- `Swap(address assetIn, address assetOut, address caller, address receiver, uint256 amountIn, uint256 amountOut, uint256 referralCode)`
  - Core swap event across all pair types; amounts reflect net outputs post-fees
