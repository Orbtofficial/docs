# USM: User Staking Module (s0x Vaults)

ERC-4626 layer over 0xAssets that issues **s0x** shares and accumulates value via protocol-level revenues and reinvestment policy.

## Purpose

* Convert 0x into **s0x** shares and back with **no UCE fee**; value accrues through the vault’s **exchange rate**.
* Align long-term holders with protocol revenues (e.g., spreads, fees, curated yields) directed per policy.

## Mechanics

* **Deposit/Withdraw via UCE**: `0x ↔ s0x` swaps call ERC-4626 `deposit/redeem` on the vault. No oracle path; strictly unit conversions.
* **Exchange Rate**: Reflects accrued yield and any revenue distributions to the vault. Integrators should **preview** before swap to obtain correct shares/out.
* **Liquidity & Latency**: Redemptions rely on the vault’s underlying liquidity policy; UCE paths are preview-consistent.

## Policy & Risk

* **Backed 1:1 in family terms** subject to vault asset allocation and risk parameters.
* **Pause/Guardrails**: Governance can pause a vault or adjust deposit caps according to market conditions.

## Integration Notes

* Use UCE’s **preview** functions for quotes.
* Approve **0x or s0x** to UCE before calling swaps.
* Display the **current exchange rate** and any performance/lockup notes in UI.
