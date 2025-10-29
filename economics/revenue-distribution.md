### Revenue Distribution

Revenue sources and their destinations:

- Redemption fees (Ox→U in UCE): collected in underlying; transferred to `treasury` during settlement
- Tin fees (U→Ox in UCE): minted in Ox directly to `treasury`
- Borrow fees (allocator repay): skimmed in underlying to `treasury` before debt reduction
- Strategy performance fees: deducted from realized profit on withdrawals and sent to `treasury`

Accounting notes:
- Ox-denominated fees increase treasury’s Ox balance; underlying fees accrue per asset
- Track realized revenue per source via events: `RedemptionFeeTaken`, `TinFeeTaken`, strategy `Withdrawn` + fee transfer

Examples:
- If `ox_gross = 1,000e18`, `tinBps = 50`, then `fee_ox = 5e18` → minted to `treasury`
- If `ox_in = 1,000e18`, `r = 2e16`, dec(U)=6, then `u_fee = 200,000` → transferred to `treasury`
