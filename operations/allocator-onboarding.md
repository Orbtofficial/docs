### Allocator Onboarding

This guide covers the end-to-end process to onboard an allocator with pockets and credit lines.

#### 1) Prerequisites
- Legal/ops readiness, KYC if applicable
- Multisig-controlled pocket addresses per supported asset (global and/or allocator-specific)
- Understanding of reserve policy and referral attribution

#### 2) Credit Line Request
- Provide requested `ceiling` (max debt in 0xAsset units) and `dailyCap` (0xAssets per UTC day)
- Provide desired `borrowFeeBps` (subject to governance)

#### 3) Pocket Provisioning
- For each asset, share pocket address with sufficient allowance to UCE
- Governance/admin executes:
  - `setAllocatorSingleByAdmin(init, [], [], SET_ALLOCATOR)` to register allocator and credit line
  - Optionally: `setAllocatorSingleByAdmin(init, assets[], pockets[], UPDATE_POCKET)` to set pockets and migrate allowance-limited balances
- Referral code is generated and emitted; share with integration partners

#### 4) Minting Inventory
- Allocator may call `allocatorCreditMint(allocator, amount)` (self-call) to mint 0xAssets inventory up to dailyCap/ceiling
- Monitor `reservedZeroX(allocator)` vs. outstanding debt (`baseDebt`)
- Debt is tracked directly in 0xAsset units; `allocatorDebt(allocator)` returns `baseDebt` (or 0 if `debtEpoch < wipeEpoch`)

#### 5) Repayment Flow
- Repay in underlying via `allocatorRepay(asset, assets)`; borrow fee is skimmed to treasury then principal reduces debt
- Debt reduction: underlying converted to 0x-equivalent via decimals normalization, then `baseDebt` is reduced directly
- Track outstanding debt via `allocatorDebt(allocator)` which returns `baseDebt` (no index scaling)

#### 6) Operations Checklist
- Monitor pocket allowances vs. weekly outflows; keep headroom ≥ 2× 95th percentile daily pulls
- Watch `DailyCapExceeded` and `CeilingExceeded` reverts; request adjustments before saturation
- Respond to per-asset pauses by halting related flows; keep liquidity idle on pause

#### 7) Offboarding / Pocket Rotation
- To rotate a pocket: `UPDATE_POCKET` with new pocket; contract migrates allowance-limited balance automatically
- Verify allowances on the new pocket and resume operations
