### Dynamic Fee Curves

This section formalizes the dynamic redemption fee used by `OrbtUCE` and outlines alternatives.

#### Implemented Curve (Supply-Fraction Bump + Exponential Decay)

State variables:
- `baseRedemptionRate ∈ [0, 5e16]` (5% max), precision 1e18
- `lastRedemptionTime` timestamp of last redemption
- `DECAY_CONSTANT = 0.995e18` (~0.5% hourly decay), capped at 24h per update

On read: `r_current = decay(baseRedemptionRate, hours_since_last)`

On redemption of `ox_redeemed` with total supply `ox_total > 0`:
- `r_decayed = decay(baseRedemptionRate, hours_since_last)`
- `bump = (ox_redeemed × 1e18) / ox_total`
- `baseRedemptionRate := clamp(0, 5e16, r_decayed + bump)` and `lastRedemptionTime = now`

Decay function (fixed-point pow-by-squaring):
- `decay(r, h) = r × (DECAY_CONSTANT^h) / 1e18`, with `h = min(24, floor(Δt / 1h))`

Charged redemption fee for a trade with snapshot rate `r`:
- `fee_ox = ox_in × r / 1e18`
- `fee_u = fromStd18(assetOut, fee_ox)`

#### Properties
- Bounded: rate ∈ [0, 5%]
- Memory: decays over time; recency-weighted responsiveness to volume
- Preview parity: previews use `r_current`; execution snapshots the same rate