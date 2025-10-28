# UPM & Strategies: Orchestrating Yield and Credit Delegation

Extensible execution layer that lets Pockets deploy liquidity into vetted strategies (e.g., Money Market) and optionally delegate credit to settlement actors.

## Purpose

* **UPM (User Position Manager)** is a broker: only Pockets can instruct it to call strategy adapters.
* **Strategies** are modular adapters (e.g., Aave v3) that accept instructions from UPM to **supply, withdraw, delegate, and repay** on behalf of Pockets.
* **Design Goals**: Keep UCE lean, isolate external protocol risk, and make strategy support **plug-and-play**.

## Roles & Permissions

* **Pocket**: Sole caller authorized to operate its positions via UPM.
* **Strategy**: Whitelists Pockets and charges protocol fee **on realized profit** (bps to treasury).
* **Governance**: Whitelists pockets, sets treasury/fees, and can update adapters.

## Two Canonical Modes

1. **Supply-Only (Conservative Yield)**

   * Pocket supplies idle U balances into a Money Market strategy.
   * Earns base deposit APY; assets remain withdrawable on demand.
2. **OCH — On-Chain Clearing House (Credit Delegation)**

   * Pocket supplies and **delegates borrow power** to a pre-approved solver/settlement actor.
   * The delegate borrows against Pocket’s credit line to settle intents, then repays from flows.
   * Pocket earns **intent fees + APY**; bears counterparty risk up to the delegated cap.

## Accounting & Fees (Strategy Layer)

* Strategies track **principal per pocket** and compute fee only on the **profit portion** at withdrawal.
* Fees route to **ORBT Treasury**; net proceeds return to the Pocket.

## Operational Checklist (Pocket)

* Keep **allowances**: to UCE (redemptions) and to Strategy (for aToken transfers on withdraw paths).
* Monitor **aToken balances, principal, fee bps, delegations**, and money-market health factors.
* Set conservative **delegation caps**; define clear unwind procedures.