### Reserve Policy Modeling

On U→Ox swaps, UCE retains a fraction of the received underlying on-contract as reserves and routes the remainder to a pocket (global or allocator/referral). Reserves support immediate Ox→U settlements without pocket pulls and reduce bridge/pocket dependency.

#### Mechanics
- `reserve_bps(asset)` = per-asset policy (default `RESERVE_BPS = 2_500 = 25%`)
- On inbound U:
  - `actualReceived = balanceAfter − balanceBefore` (handles deflationary tokens)
  - `reserveAmt = actualReceived × reserve_bps / 10_000`
  - `toPocket = actualReceived − reserveAmt`
  - Transfer `toPocket` to pocket; increase `reservedUnderlying(asset)` by `reserveAmt`
- On outbound U (`_pushUnderlying`):
  - Use on-hand first; decrement `reservedUnderlying` by the portion used
  - Pull remainder from selected pocket (allocator’s pocket if present, else global)

#### Effects and Trade-offs
- Higher `reserve_bps` improves redemption responsiveness, reduces pocket allowance dependency, and lowers settlement mismatch risk
- Lower `reserve_bps` increases capital efficiency in pockets/strategies at cost of on-hand liquidity

#### Monitoring
- Track `reservedUnderlying(asset)` trends vs. swap flow
- Alert when repeated pocket pulls approach allowance limits (`InsufficientPocketLiquidity` risk)
- Adjust `reserve_bps` per-asset via `setAssetReserveBps` in response to observed flow and liquidity constraints
