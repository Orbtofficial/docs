### Monitoring

Track the following metrics and define alerts with actionable thresholds.

#### UCE Core
- Per-asset:
  - `assetPaused(asset)` change events
  - `reserveBps(asset)` and `reservedUnderlying(asset)` level and trend
  - Pocket `balance` vs. `allowance` to UCE; headroom for `_pullFromPocket`
- Global:
  - `baseRedemptionRate`, `lastRedemptionTime`; derived `r_current`
  - `totalReservedZeroX`, `baseTotalDebt` (sum of all allocator baseDebt)
  - `wipeEpoch` (for lazy debt wiping)
  - Swap volume by pair type and fees: sum of `RedemptionFeeTaken` and `TinFeeTaken`

Suggested alerts:
- Per-asset pause toggled (critical)
- `baseRedemptionRate` above 2% for > 1h (investigate redemptions)
- Pocket allowance headroom < 20% of 7d avg outflow (risk of `InsufficientPocketLiquidity`)

#### Oracle
- Feed freshness: `block.timestamp − updatedAt ≤ heartbeat`
- Price continuity: deviation vs. moving average

Suggested alerts:
- Any `OracleStale` or `OracleBadPrice` revert spike
- Feed update gaps approaching heartbeat threshold

#### Bridge (Across)
- Per-route utilization: daily usage vs. `dailyMaxUnderlying`, per-tx distribution vs. `perTxMaxUnderlying`
- Revert rate per route

Suggested alerts:
- Daily usage > 80% before 12:00 UTC (tight capacity)
- Repeated `TransactionCapExceeded` / `DailyCapExceeded`

#### Strategies
- aToken balances per pocket; realized fee to treasury
- Repay activity and dust balances checks
