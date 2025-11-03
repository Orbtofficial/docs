### Fee Structure

This section specifies the exact fees charged by `OrbtUCE` and related modules, including precise formulas, variable definitions, and event references. Currency units are noted explicitly. Ox-denominated amounts use 18 decimals by construction; underlying token decimals are respected per token.

#### Notation
- ox: Ox units (18 decimals)
- u: Underlying token units (token-decimals)
- bps: basis points (PERCENTAGE_PRECISION = 10_000)
- r: redemption rate in RATE_PRECISION = 1e18
- dec(asset): decimals of `asset`
- std18(x): convert `x` to 18-decimal standard
- fromStd18(asset, x): convert 18-decimal amount `x` to `asset` units

---

#### 1) Dynamic Redemption Fee (Ox → U)

Applied to user redemptions when swapping Ox to an underlying asset. Calculated at a snapshot of the current dynamic rate and emitted via `RedemptionFeeTaken`.

- Effective gross underlying before fee:
  - u_gross = fromStd18(assetOut, ox_in)

- Fee in Ox units at snapshot rate r:
  - fee_ox = (ox_in × r) / 1e18

- Fee in underlying units:
  - u_fee = fromStd18(assetOut, fee_ox)

- Net underlying out to user:
  - u_net = max(u_gross − u_fee, 0)

- Event: `RedemptionFeeTaken(payer, assetOut, oxIn, feeRate, feeInUnderlying, timestamp)`

Dynamic rate evolution after redemption of `ox_in`:
- Let `ts = totalSupply(Ox)`; if `ts == 0`, no change
- Decay base redemption rate first: r_decayed = decay(baseRedemptionRate, elapsed_hours)
- Bump by fraction of supply redeemed: bump = (ox_in × 1e18) / ts
- New base rate: baseRedemptionRate := clamp(r_floor, r_max, r_decayed + bump)
  - r_floor = 0, r_max = 5e16 (5%)
  - Decay uses `_rpow(DECAY_CONSTANT, hours, 1e18)`, with DECAY_CONSTANT = 0.995e18 (~0.5% hourly), capped at 24h per update

Preview parity:
- Exact-in: preview uses current decayed rate prior to execution; execution charges fee at the same snapshot
- Exact-out: input Ox includes gross + fee_ox computed from snapshot so delivered `u_out` equals target

---

#### 2) Tin Fee (U → Ox)

Tin is a per-asset mint fee in bps applied to U→Ox swaps. It is denominated in Ox and minted to `treasury` if set.

- Gross Ox before tin:
  - ox_gross = toOxAmount(assetIn, u_in)
  - Where `toOxAmount` normalizes to 18 decimals, applies price px1e18, then optional mint haircut bps:
    - std = std18(u_in)
    - px = priceAssetInBase1e18(assetIn)
    - ox_raw = (std × px) / 1e18
    - If haircut h_bps > 0: ox_gross := ox_raw × (10_000 − h_bps) / 10_000

- Tin fee in Ox:
  - fee_ox = (ox_gross × tin_bps(assetIn)) / 10_000

- Net Ox to user:
  - ox_net = ox_gross − fee_ox

- Event: `TinFeeTaken(payer, assetIn, oxGross, feeBps, feeInOx, timestamp)`

Exact-out path gross-up (required pre-tin Ox):
- ox_pre_tin = ceil(ox_net × 10_000 / (10_000 − tin_bps))

---

#### 3) Borrow Fee (Allocator Repay)

Charged in underlying to allocators on repay; fee is sent to `treasury` before debt reduction.

- Given repay `assets` in underlying and `borrowFeeBps`:
  - u_fee = (assets × borrowFeeBps) / 10_000
  - u_principal = assets − u_fee
  - ox_equiv = std18(u_principal)  // decimals normalization only (no oracle)
  - currentDebt = allocatorDebt(allocator) = baseDebt (if debtEpoch ≥ wipeEpoch, else 0)
  - repay_ox = min(ox_equiv, currentDebt)
  - baseRepay = repay_ox (no index scaling; debt is tracked directly in 0xAsset units)
  - Update: `baseDebt(allocator) -= baseRepay`, `baseTotalDebt -= baseRepay` (clamped to prevent underflow)

Events:
- `AllocatorRepaid(repayer, allocator, repay_ox)`
- `AllocatorBorrowFeeSet(allocator, bps)`

---

#### 4) Reserve Policy (U → Ox)

On U→Ox, a portion of the received underlying is retained on-contract as reserve and the remainder is forwarded to the pocket. The retained portion is accounted in `reservedUnderlying` and consumed first on outbound underlyings.

- reserve_bps(asset) = asset.reserveBps (default RESERVE_BPS = 2_500 = 25%)
- reserve_amt = u_received × reserve_bps / 10_000
- to_pocket = u_received − reserve_amt

Admin controls:
- `AssetReserveBpsSet(asset, bps)` updates reserve policy per asset

---

#### 5) Events Reference

- `RedemptionFeeTaken(payer, assetOut, oxIn, feeRate, feeInUnderlying, timestamp)`
- `TinFeeTaken(payer, assetIn, oxGross, feeBps, feeInOx, timestamp)`
- `AllocatorBorrowFeeSet(allocator, bps)`
- `AssetReserveBpsSet(asset, bps)`

---

#### 6) Worked Numerical Examples

Example: Ox→U with r = 2e16 (2%), dec(assetOut) = 6, ox_in = 1,000e18
- u_gross = fromStd18(assetOut, 1,000e18) = 1,000e6
- fee_ox = 1,000e18 × 2e16 / 1e18 = 20e16 = 0.2e18 (0.2 Ox)
- u_fee  = fromStd18(assetOut, 0.2e18) = 0.2e6 = 200,000
- u_net  = 1,000,000 − 200,000 = 800,000 (6 decimals)

Example: U→Ox with tin_bps = 50 (0.5%), haircut = 100 (1%), px = 1e18, u_in = 1,000e6
- std = 1,000e18
- ox_raw = (1,000e18 × 1e18) / 1e18 = 1,000e18
- haircut: ox_gross = 1,000e18 × 9,900 / 10,000 = 990e18
- fee_ox = 990e18 × 50 / 10,000 = 4.95e18
- ox_net = 985.05e18
