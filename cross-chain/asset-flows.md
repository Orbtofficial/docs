### Cross-Chain Asset Flows

This section outlines token movements and where balances end up before and after bridging operations.

#### Underlying → Ox (Destination)
- Source chain:
  - User balance of `sourceUnderlying` decreases by `inputAmount`
  - Adapter’s balance temporarily increases then is approved to `SpokePool`
  - `SpokePool` holds/lifecycle-manages the bridged funds
- Destination chain:
  - Handler receives `underlyingOnDestination`
  - Approves and calls `UCE_dst.swapExactIn(U → Ox)`
  - User receives `Ox_dst = ox_gross − fee_ox(tin)`; treasury receives `fee_ox` minted

#### Ox → U (Source) → Ox (Destination)
- Source chain:
  - User `Ox_src` decreases by `inputAmountOx`
  - Adapter receives `Ox`, performs `Ox → U` via `UCE_src`; fee in underlying is routed to treasury
  - Adapter approves and deposits `sourceUnderlying` to `SpokePool`
- Destination chain:
  - Same as above: handler swaps U→Ox, user receives `Ox_dst`

#### Events
- Source: `UnderlyingBridged` or `OxBridged`
- Destination UCE: `TinFeeTaken`, `Swap`
- Source UCE (for Ox→U leg): `RedemptionFeeTaken`, `Swap`
