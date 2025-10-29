### Oracle Security

`OrbtUCE` prices U↔Ox using Chainlink-style feeds with explicit freshness and normalization rules. The design fails closed on any anomaly.

#### Configuration
- Per-asset config via `setOracle(asset, baseFeed, usdFeed, heartbeat, mintHaircutBps, enabled)`
  - `baseFeed`: price of asset in the family base (e.g., BTC in BTC-family)
  - `usdFeed`: price of asset in USD
  - `heartbeat`: max allowed staleness in seconds
  - `mintHaircutBps`: haircut applied on U→Ox conversions
  - `enabled`: oracle toggle
- Global `setBaseUsdFeed(feed, heartbeat)` for non-USD families when only USD feeds are available.

#### Price Path
- For USD family: require `usdFeed`; px = read(usdFeed)
- For non-USD family:
  - If `baseFeed` set: px = read(baseFeed)
  - Else: require `usdFeed` and `baseUsdFeed`; px = read(usdFeed) / read(baseUsdFeed)
- All reads use `_readFeed`, which enforces:
  - Positive answer and answeredInRound checks
  - Heartbeat freshness: `block.timestamp − updatedAt ≤ heartbeat` when `heartbeat > 0`
  - Decimals normalization to 1e18

#### Failure Modes and Guards
- Revert codes (non-exhaustive):
  - `OracleUnavailable`, `OracleBadPrice`, `OracleStale`
  - Invalid address configurations: `InvalidAddress`
- When oracle is disabled or stale: swaps that need it revert; preview functions mirror the same checks
- Mint haircuts reduce ox_out on U→Ox to mitigate stale/lagging quotes

#### Recommendations
- Set conservative `heartbeat` per feed; monitor staleness events
- Prefer base feeds where possible; otherwise ensure `baseUsdFeed` is reliable
- Keep `mintHaircutBps` > 0 for volatile assets; revisit after monitoring
- Maintain per-asset pause as last-resort control independent of oracle status
