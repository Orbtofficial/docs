### Protocol Invariants (to be proven)

This section lists critical invariants and the code-level checks that enforce them. Each should be covered by property tests and formal analysis where feasible.

- Liquidity conservation (U↔Ox↔S):
  - For Ox→U: `u_delivered = fromStd18(ox_in) − u_fee`, where `u_fee = fromStd18(fee_ox)`; settlement emits `RedemptionFeeTaken`; delivery path uses on-hand then pocket pull; final balance delta equals `u_delivered`
  - For U→Ox: `ox_out = toOxAmount(u_in) − fee_ox`; fee minted to treasury if set; `Swap` emitted
- Settlement parity and exactness:
  - Exact-in: delivered amounts calculated pre-state-change and validated (`SettlementMismatch` reverts on deviation)
  - Exact-out: inputs grossed-up; delivered equals target or reverts `SettlementMismatch`
- Pair gating:
  - Only `Ox↔U` and `S↔Ox` supported; `U↔U` and `Ox↔Ox` revert `UnsupportedSwap`
- Pause safety:
  - Global `whenNotPaused` and per-asset `assetPaused(asset)` enforce no state changes when paused
- Credit safety:
  - `allocatorCreditMint` enforces `dailyCap`, `ceiling`; `allocatorRepay` caps debt reduction to current effective debt
  - Pro-rata draw never reduces an allocator’s `reservedOx` below 0; base debt reductions clamp to `baseDebt`
- Oracle safety:
  - `_readFeed` enforces positive price, round validity, and heartbeat ≤ configured; falls back to `baseUsdFeed` when needed; otherwise reverts
- Upgrade auth:
  - UUPS hooks are gated by privileged roles (ADMIN/owner); unauthorized upgrades impossible via runtime paths
- Allowance-limited pocket pulls:
  - `_pullFromPocket` enforces `min(balance, allowance)`; reverts `InsufficientPocketLiquidity` on shortfall
