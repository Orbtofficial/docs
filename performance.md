### Performance & Gas

Benchmark the following and publish ranges with compiler/chain settings:

- UCE
  - `swapExactIn` and `swapExactOut` by pair type (Ox→U, U→Ox, S↔Ox)
  - `deposit` and `withdraw` (admin-only custody ops)

- AcrossUCEBridge
  - `bridgeUnderlyingToChain` and `bridgeUnderlyingToChainWithPermit`
  - `bridgeOxToChain`

- Strategies
  - `supply`, `withdrawFromPocket`, `withdrawAllFromPocket`, `repay`, `repayWithPermit`

Optimization notes:
- Cache decimals and use `forceApprove` to avoid allowance issues
- Batch calls via UPM where appropriate to reduce overhead
