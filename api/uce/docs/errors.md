### UCE Errors

`Errors.OrbtUCE__*` are descriptive, revert-only codes. Below is the consolidated list observed in the implementation. Grouped by theme.

#### Access / Governance
- `NotGovernance`

#### Assets / Addresses / Configuration
- `InvalidAsset`, `InvalidOxAsset`, `InvalidTreasury`, `InvalidAddress`, `InvalidReceiver`
- `InvalidFamily`, `AssetFamilyMismatch`
- `InvalidBps`, `InvalidAmount`, `InvalidAmountOut`
- `InvalidAssetIn`, `InvalidAssetOut`
- `UnsupportedSwap`
- `NoPocket`, `InvalidPocket`, `AssetNotSupported`, `SamePocket`

#### Pause / State Guards
- `AssetIsPaused`

#### Oracles
- `OracleUnavailable`, `OracleBadPrice`, `OracleStale`

#### Allocators / Credit Lines
- `InvalidAllocator`, `NotAllocator`, `NoCreditLine`
- `DailyCapExceeded`, `CeilingExceeded`
- `InsufficientAllocatorBalance`
- `LengthMismatch`, `ReferralInUse`

#### Liquidity / Settlement
- `InsufficientPocketLiquidity`
- `InsufficientAmountInReceived`
- `SettlementMismatch`

#### Limits / Slippage
- `AmountInTooHigh`

#### Treasury
- `NoTreasury`
