### Strategy Errors (typical)

- Gating & permissions:
  - `onlyUPM` required on operational entrypoints
  - Pocket whitelist checks
- Parameter/asset checks:
  - zero address/amount reverts
  - invalid aToken/market references
- Post‑conditions:
  - dust checks on underlying/aToken balances (zero‑custody invariant)
- Repay:
  - permit signature errors bubble from tokens
