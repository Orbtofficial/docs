### Parameter Adjustment

Guidelines for safe parameter tuning.

- Tin Bps (U→Ox)
  - Adjust by ≤ 25 bps per change; monitor swap conversion and treasury accruals

- Reserve Bps (U→Ox)
  - Increase during high redemption periods to build on-hand liquidity
  - Decrease when pockets/strategies can absorb inflow

- Credit Lines
  - Daily cap and ceiling changes must respect existing `allocatorDebt`
  - Increase ceilings only after sustained utilization and timely repayments

- Oracles
  - Heartbeat adjustments require monitoring feed stability; set haircut > 0 for volatile assets

- Bridge Caps
  - Raise slowly; ensure destination UCE/handlers are configured and liquid
