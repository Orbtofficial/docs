### Allocator Onboarding

This guide covers the end-to-end process to onboard an allocator with pockets and credit lines.

#### 1) Prerequisites
- Legal/ops readiness, KYC if applicable
- Multisig-controlled pocket addresses per supported asset (global and/or allocator-specific)
- Understanding of reserve policy and referral attribution

#### 2) Credit Line Request
- Provide requested `ceiling` (max effective Ox debt) and `dailyCap` (Ox per UTC day)
- Provide desired `borrowFeeBps` (subject to governance)

#### 3) Pocket Provisioning
- For each asset, share pocket address with sufficient allowance to UCE
- Governance/admin executes:
  - `setAllocatorSingleByAdmin(init, [], [], SET_ALLOCATOR)` to register allocator and credit line
  - Optionally: `setAllocatorSingleByAdmin(init, assets[], pockets[], UPDATE_POCKET)` to set pockets and migrate allowance-limited balances
- Referral code is generated and emitted; share with integration partners

#### 4) Minting Inventory
- Allocator may call `allocatorCreditMint(allocator, amount)` (self-call) to mint Ox inventory up to dailyCap/ceiling
- Monitor `reservedOx(allocator)` vs. effective debt

#### 5) Repayment Flow
- Repay in underlying via `allocatorRepay(asset, assets)`; borrow fee is skimmed to treasury then principal reduces debt
- Track `debtIndex` and outstanding effective debt via `allocatorDebt(allocator)`

#### 6) Operations Checklist
- Monitor pocket allowances vs. weekly outflows; keep headroom ≥ 2× 95th percentile daily pulls
- Watch `DailyCapExceeded` and `CeilingExceeded` reverts; request adjustments before saturation
- Respond to per-asset pauses by halting related flows; keep liquidity idle on pause

#### 7) Offboarding / Pocket Rotation
- To rotate a pocket: `UPDATE_POCKET` with new pocket; contract migrates allowance-limited balance automatically
- Verify allowances on the new pocket and resume operations
