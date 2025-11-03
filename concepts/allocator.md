# Allocator: Credit Issuer & Liquidity Partner

Permissioned counterparties that run distribution, hold reserved 0x inventory, and provision underlying liquidity via Pockets.

## Role Summary

* **Primary Issuers**: Mint 0xAssets via credit capacity. **Critical**: These minted 0xAssets remain in the UCE contract and cannot leave unless swapped with equivalent underlying assets. This ensures all 0xAssets in circulation are always backed by equivalent underlying in UCE, maintaining the 1:1 peg.
* **Liquidity Managers**: Keep Pockets funded and allowances open so UCE can pull on redemptions.
* **Yield Participants**: Deploy Pocket balances via UPM into strategies; optionally operate as OCHs via credit delegation.
* **Attribution Surface**: Referral codes map user flow to an allocator; referred OX outflow **must** consume the referrer's inventory.

## Economics

* **Credit Minting**: Allocators may mint 0xAssets up to their credit line, but **these 0xAssets remain in the UCE contract**. They are credited as "reserved inventory" and can only be swapped when users provide equivalent underlying assets. This guarantees that every 0xAsset in circulation has equivalent underlying backing in UCE.
* **Borrow Cost**: Governance-tunable `borrowFeeBps` applied on **repay** (on the underlying delivered back).
* **Credit Controls**: `ceiling` (maximum effective debt) and `dailyCap` enforce safe issuance discipline.
* **Debt Mechanics**: Lazy accounting via `debtIndex`; repayments reduce baseDebt in normalized 0x terms.

## Responsibilities

* Maintain **reserved 0x** for smooth fills; monitor **reserveBps** thresholds.
* Keep **pocket allowances** to UCE sufficient for expected bursts.
* Repay regularly in chosen underlyings to manage financing cost and debt.
* If acting as OCH: set and monitor **delegations**, utilization, and counterparty behavior.

## Governance Onboarding (High-Level)

* Approve allocator; set **line (ceiling/dailyCap)**, **borrowFeeBps**, pockets per asset, and generate **referral code**.
* Updates (pause, resize line, rotate referral, adjust fee/pockets) follow timelocked multi-sig workflow.

---

# Pocket — Allocator Custody & Strategy Entry Point

Allocator-controlled multisig/EOA that receives attributed inflows, authorizes UCE pulls, and deploys idle balances via UPM.

## Purpose

* **Custody**: Holds underlyings (USDC/USDT/DAI/…).
* **Settlement**: Grants allowances so UCE can **pull instantly** for redemptions.
* **Deployment**: Uses UPM to supply to Money Markets or delegate credit (OCH mode).

## Flow Semantics

* **Inbound Attribution**: Referred U inflows route here; UCE keeps per-asset **reserveBps** on-hand and forwards the remainder to the Pocket.
* **Outbound Redemptions**: UCE consumes on-hand reserve, then **pulls from this Pocket** (if selected by referral) up to allowance/balance.
* **Strategy Yield**: Pocket calls UPM to operate strategy adapters; earns APY minus protocol fee on realized profit.
* **OCH Delegation**: Pocket may delegate variable debt capacity to a solver to capture intent settlement fees; carries bounded counterparty risk.

## Ops Checklist

* Maintain **allowances** to UCE and strategy.
* Monitor **balances, aTokens, fee bps, delegations**.
* Keep **reserved 0x** topped to serve referred users instantly.
* Respond to governance signals (pauses/haircuts/reserve changes).

## Allocator Lifecycle

1) Onboarding (admin/governance)
- Allowlist allocator, set ceiling/dailyCap/borrowFee, configure referral code
- Set per‑asset pockets (custody addresses) that receive underlying inflows

2) Credit Minting (provision inventory)
- Allocator mints 0xAssets to UCE via `allocatorCreditMint()`. **These 0xAssets stay in the UCE contract** and are credited as reserved inventory
- These reserved 0xAssets can only enter circulation when users swap equivalent underlying assets (U→0x swaps)
- This ensures peg integrity: 0xAssets in circulation = equivalent underlying assets in UCE
- Tracked against ceiling and dailyCap; emits CreditMinted

3) Deployment (earn and serve flow)
- Allocator deploys underlying via UPM→Strategies (e.g., Aave) for yield
- Keeps pockets funded/allowanced for fast UCE pulls on redemptions

4) Repayment (reduce liability; boost reserves)
- Allocator repays in underlying; borrow fee is skimmed to treasury
- Principal increases on‑hand reserves, strengthening immediate 0x→U capacity

## 0xAsset Credit Minting (U→0x supply preparation)

Effect of `allocatorCreditMint(allocator, amount)`:
- **Mints 0xAssets directly to UCE contract** (not to allocator address). These 0xAssets remain in UCE custody
- Increases allocator's reserved 0xAssets inventory by `amount` (this is an accounting entry, not a transfer)
- **Peg Maintenance**: These minted 0xAssets can only leave UCE when users provide equivalent underlying assets via swaps. This ensures that all 0xAssets in circulation are backed 1:1 by underlying assets in UCE, maintaining the peg
- Tracks throughput in UTC‑bucketed daily counters; enforces ceiling/dailyCap
- Reorders allocator priority for pro‑rata draws where applicable

## Allocator Repayment (underlying side)

High‑level flow:
- Pull underlying from allocator to UCE custody (on‑hand)
- Apply borrow fee (in underlying) to treasury; principal remains on UCE
- Convert principal to OX‑equivalent using decimals normalization (no oracle)
- Reduce allocator liability up to current outstanding; emit AllocatorRepaid

Properties:
- Immediately improves redemption depth (on‑hand U increases)
- No oracle dependency on repay path
- Non‑reentrant; pause‑gated

## Referral vs Non‑Referral (behavioral summary)

Referral (user passes allocator code):
- U inflows route to referrer’s pocket
- U→0x must be served from referrer’s reserved OX; insufficient inventory → revert
- 0x→U pulls U from referrer’s pocket first (bounded by allowance/balance), else revert if insufficient

Non‑referral (protocol path):
- U→0x uses unreserved protocol inventory → pro‑rata across allocator inventories → mints shortfall
- 0x→U sources U from on‑hand reserves then global pocket (allowance‑bounded)

## Privileges & Restrictions

Privileges:
- Mint 0xAssets up to credit limits without pre‑posting collateral (minted 0xAssets remain in UCE contract)
- Receive U inflows to pockets on referred swaps; earn yield on deployed capital

Restrictions:
- Cannot redeem OX→U directly (must operate via underlying)
- Must stay within ceiling and daily cap; borrow fee applies on repay

## Integration Tips

- Keep pocket allowances to UCE high enough for expected redemptions
- Monitor balances, aTokens, fee bps, and referral utilization
- For referred flows, pre‑check pocket allowance/balance to avoid reverts
