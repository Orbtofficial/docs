### UPM & Strategy Errors

UPM
- `UPM/len-mismatch` when batch lengths differ
- `onlyRole(POCKET)` required for `doCall`, `doBatchCalls`, `doDelegateCall`

BaseStrategy / OrbtMMStrategy
- Bounds and address checks:
  - `ORBTMM/upm`, `ORBTMM/treasury`, `ORBTMM/fee-bps`, `ORBTMM/pocket`, `ORBTMM/aToken`, `ORBTMM/to`, `ORBTMM/amount`, `ORBTMM/allowance`, `ORBTMM/no-aToken`
- Post-conditions (dust checks):
  - `ORBTMM/aToken-dust`, `ORBTMM/asset-dust`
- Withdraw math:
  - `withdrawn-mismatch` if lending pool returns unexpected amount

Repay
- Standard `permit` failures (deadline, signature) surface from token contracts
