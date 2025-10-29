### Bridge Mechanics

This section details the exact call sequence, approvals, and balance movements for both supported flows. Ox never crosses chains; only underlying moves via Across.

#### Underlying → Ox on Destination
1) User → Adapter (source):
   - Pull `sourceUnderlying` from user (or via EIP-2612 permit variant)
2) Adapter:
   - Enforce caps (per-tx, daily) for the route
   - Encode destination message: approve(`underlyingOnDestination`, `uceOnDestination`) → `UCE_dst.swapExactIn(U → Ox, amount, receiver=user, referral)`
   - Approve `SpokePool` and call `depositV3`
3) Across:
   - Lock source underlying, bridge to destination router/handler
4) Destination handler:
   - Execute approve + `UCE_dst.swapExactIn`
   - User receives `Ox_dst` net of tin fee

Observability:
- Source emits `UnderlyingBridged`
- Destination UCE emits `TinFeeTaken` and `Swap`

#### Ox → Underlying on Source → Ox on Destination
1) User → Adapter (source): Pull `sourceOxAsset`
2) Adapter:
   - Approve `uceOnSource`
   - Call `UCE_src.swapExactIn(Ox → U, receiver=this)`; adapter receives underlying
   - Enforce caps with obtained underlying, then encode destination message as above
   - Approve and `depositV3`
3) Destination handler: approve + `UCE_dst.swapExactIn(U → Ox, receiver=user)`

Fees:
- Source leg: dynamic redemption fee applied in underlying on `Ox → U`
- Destination leg: tin fee applied in Ox on `U → Ox`

Failure domains and safeties:
- Route must exist; non-existent route reverts `RouteMissing`
- Caps: `TransactionCapExceeded` / `DailyCapExceeded`
- Pausable adapter (`pause`/`unpause` by owner)
- Permit path enforces `PermitExpired` deadline
