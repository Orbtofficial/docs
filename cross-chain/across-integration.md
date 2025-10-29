### Across Protocol Integration (UCE Bridge)

`AcrossUCEBridge` is a production adapter for bridging UNDERLYINGS via Across and minting/redeeming Ox on the destination chain through UCE. Ox never crosses the bridge.

#### Contract
- `AcrossUCEBridge` (Ownable, Pausable, ReentrancyGuard)
- Immutable: `spokePool`, `uceOnSource`

#### Admin Configuration
- `setRoute(dstChainId, uceOnDestination, underlyingOnDestination, handlerOnDestination, perTxMax, dailyMax)`
  - Defines/overwrites a route; requires all addresses non-zero
- `updateCaps(dstChainId, perTxMax, dailyMax)` updates caps
- `pause` / `unpause` owner-only circuit breaker
- `rescueTokens(token, to, amount)` owner-only safety valve

Caps enforcement (UTC-day rolling bucket):
- Per-tx: revert `TransactionCapExceeded(maxAllowed, requested)`
- Daily: revert `DailyCapExceeded(maxAllowed, usedToday, requested)`

#### Flows

1) Underlying → Ox on destination (`bridgeUnderlyingToChain` / `bridgeUnderlyingToChainWithPermit`)
- Pull `sourceUnderlying` from user (permit variant supports EIP-2612)
- Enforce caps on `inputAmountUnderlying`
- Encode destination message:
  - approve(`underlyingOnDestination`, `uceOnDestination`, type(uint256).max)
  - `UCE_dst.swapExactIn(U_dst → Ox_dst, amountToSpend, receiver=user, referralCode)`
  - Note: many handlers ignore `amountToSpend` and use their actual token balance. UCE must handle both.
- Approve and call `SpokePool.depositV3` with `sourceUnderlying → underlyingOnDestination`
- Emit `UnderlyingBridged`

2) Ox → Underlying on source → Ox on destination (`bridgeOxToChain`)
- Pull `sourceOxAsset`, approve `uceOnSource`, call `UCE_src.swapExactIn(Ox → U, receiver=this)`
- Enforce caps on obtained underlying
- Encode same destination message (approve + UCE_dst.swapExactIn(U → Ox, receiver=user))
- Approve and deposit into SpokePool
- Emit `OxBridged`

#### Permit Support
- `bridgeUnderlyingToChainWithPermit` verifies deadline then calls `IERC20Permit.permit` to skip prior approve

#### Events
- `RouteConfigured(dstChainId, destinationUCE, destinationUnderlying, handler, perTxMax, dailyMax)`
- `CapsUpdated(dstChainId, perTxMax, dailyMax)`
- `UnderlyingBridged(user, dstChainId, sourceUnderlying, destinationUnderlying, inputAmountUnderlying, minOutputAmountUnderlying, referralCode)`
- `OxBridged(user, dstChainId, sourceOx, sourceUnderlying, destinationUnderlying, inputAmountOx, obtainedUnderlyingOnSource, minOutputAmountUnderlying, referralCode)`

#### Errors
- `ZeroAddress()` invalid address configuration
- `RouteMissing(dstChainId)` unknown route
- `InvalidAmount()` zero or invalid amount
- `TransactionCapExceeded(maxAllowed, requested)`
- `DailyCapExceeded(maxAllowed, usedToday, requested)`
- `PermitExpired()` for permit variant

#### Operational Guidance
- Start with conservative `perTxMax` and `dailyMax`; scale with telemetry
- Prefer closed `exclusiveRelayer` during canary; relax later
- Monitor cap utilization, revert rates, and handler failures across chains
- Pause on anomalies; routes are stateful per-destination and must be re-evaluated after incidents
