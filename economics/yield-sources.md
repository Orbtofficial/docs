### Yield Sources

Primary protocol revenue sources:

- Strategy Yield
  - Aave-based `OrbtMMStrategy` interest; realized upon withdrawals back to pockets
  - Performance fee skimmed to treasury

- Fees
  - Tin fees on U→Ox
  - Redemption fees on Ox→U
  - Borrow fees on allocator repayments

Attribution & Reporting
- Attribute per-asset and per-allocator using on-chain events
- Monthly aggregation recommended: strategy yield vs. fee-based revenue
