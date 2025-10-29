# Allocator: Credit Issuer & Liquidity Partner

Permissioned counterparties that run distribution, hold reserved 0x inventory, and provision underlying liquidity via Pockets.

## Role Summary

* **Primary Issuers**: Mint 0x via borrow capacity, warehouse as **reserved 0x**, and serve user demand.
* **Liquidity Managers**: Keep Pockets funded and allowances open so UCE can pull on redemptions.
* **Yield Participants**: Deploy Pocket balances via UPM into strategies; optionally operate as OCHs via credit delegation.
* **Attribution Surface**: Referral codes map user flow to an allocator; referred OX outflow **must** consume the referrer’s inventory.

## Economics

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
