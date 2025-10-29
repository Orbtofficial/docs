# UCE: Unified Collateral Engine

**The Unified Collateral Engine (UCE)** is the core liquidity and asset management layer of the ORBT protocol. It functions as a Peg Stability Module (PSM) that enables seamless, low-slippage swaps between underlying collateral assets (e.g., WBTC, cbBTC) and their corresponding synthetic 0x assets (e.g., 0xBTC). The UCE serves as the primary interface for users, allocators, and integrators to interact with the ORBT ecosystem.
Unlike traditional PSMs that simply maintain nearly 1:1 backing, the UCE implements an allocator reserved-inventory model: permissioned allocators can mint 0x into their reserved inventory on UCE. These newly minted 0xAssets never leave UCE unless and until an equivalent amount of underlying collateral is deposited and attributed to that allocator (via referral or self-deposit). This enables capital efficiency while maintaining robust collateralization and risk management.

> Practically it is not advisable to compose a 1:1 backing model for 0xAsset <> Underlying since there can be slight or even major disparity among the family indexed price of each asset. Meaning that, it is true that stETH theoretically stays pegged to ETH generally but there could be instances where stETH might stay at a major delta from ETH price. Considering this, we have introduced oracles to always make sure the output or input of 0xAssets for issuance and redemption is catered using the supported underlying asset's oracle price and converted in terms of the family's index. 

The UCE is built around several key innovations:
1. Multi-Collateral Support: A single UCE instance can manage multiple underlying assets within the same asset family (e.g., WBTC, cbBTC, tBTC for the BTC family) backing a single synthetic asset (e.g., 0xBTC for the BTC family)
2. Allocator Reserved Inventory: Whitelisted allocators may mint 0x into on-contract reserved inventory. This inventory is only releasable to users when matched by equivalent underlying deposits attributed to that allocator (referral/self-deposit). Issuance is bounded by governance-set limits (ceiling/dailyCap) and subject to `borrowFeeBps` on repayment in underlying.
3. Referral Attribution: Users can swap using allocator referral codes, directing underlying collateral to specific allocator pockets.
4. Dynamic Redemption Fees: Fee rates increase with redemption pressure and decay over time, providing economic incentives for balanced liquidity.
5. Lazy Debt Accounting: Proportional obligation reduction across all allocators without iterating through allocator lists, enabling gas-efficient scaling.
6. Reserve Policy: Configurable reserve ratios that keep a percentage of deposited collateral on-hand for instant redemptions.
7. Vault Integration: Integration with s0xAsset which ERC-4626 for yield-bearing collateral management for swaps between 0x <> s0x as per current exchange rate. 


## Purpose
UCE unifies collateral custody, synthetic issuance, allocator reserved inventory accounting, and peg stability in a single control plane. It manages liquidity across **two swap planes**:

* **U ↔ 0x**: Underlying stable/crypto to 0xAssets (mint/redemption)
* **0x ↔ s0x**: ERC-4626 staking share conversions (no oracle; vault exchange-rate based)

Each deployed UCE is **scoped to a Family** (e.g., `USD`, `ETH`, `BTC`) and only routes swaps within that family.

## Key Objects & Flows

* **0xAssets**: 18-dec family units (e.g., `0xUSD`, `0xBTC`) minted/burned by UCE.
* **s0xAssets**: ERC-4626 shares over 0x (e.g., `s0xUSD`). Value accrues via the vault exchange rate.
* **Pockets (Global & Allocator)**: Custody endpoints (EOA/multisig/strategy vaults). UCE pulls from pockets for redemptions; non-reserved inbound is forwarded to pockets after applying **reserveBps**.
* **Allocators**: Permissioned liquidity partners with **reserved 0x inventory on UCE**; supply primary market liquidity and absorb operational risk.
* **Referral Attribution**: User swaps that include a referrer code route U to the referrer’s pocket and **consume the referrer’s reserved 0x first**.

## Financial Architecture

* **Obligation Indexing**: UCE maintains a global `debtIndex` (1e18 scale). Each allocator’s obligation is tracked in base units; **effective obligation = baseDebt × debtIndex / 1e18**. System-level write-downs (if any) socialize proportionally by scaling the index.
* **Issuance Discipline**: Per-allocator **ceiling** (max effective obligation) and **dailyCap** (issuance velocity). Minting increases reserved inventory and the allocator obligation; repayments retire obligation in normalized 0x terms.
* **Reserve Policy**: A per-asset **reserveBps** of inbound U is retained on UCE to fund instant redemptions; the remainder is forwarded to pockets. Outbound U for redemptions **consumes reserve first**, then pulls from pockets by allowance.
* **Peg Stability**:

  * **Mint path (U→0x)**: Oracle-priced with optional mint haircut; **tinBps** fee minted in 0x to treasury.
  * **Redeem path (0x→U)**: Oracle-free; **dynamic redemption fee** (time-varying) is paid by user in U. Rate increases with redemption pressure and decays over time, ensuring preview-execution parity via snapshotting.

## Routing & Settlement (High-Level)

* **U→0x (Issuance)**: Unreserved on-hand 0x → (if referred: referrer’s reserved 0x; else pro-rata across allocators reducing their obligations) → mint remainder.
* **0x→U (Redemption)**: On-hand reserve → pull from selected pocket (referrer pocket if provided; else global) subject to allowance and balance.

## Governance Surface

* **Allocator Onboarding/Updates**: Allowlist, issuance limits (ceiling/dailyCap), `borrowFeeBps`, pockets, referral code.
* **Asset Policy**: Oracle configuration (feeds/heartbeat), mint haircut, per-asset tinBps and reserveBps.
* **Pausing**: Global and per-asset.

## Invariants & Safety

* **Liquidity**: `totalReserved0x ≤ 0x balance on UCE`.
* **Issuance Limits**: For all allocators, `effectiveObligation ≤ ceiling`; daily cap enforced per UTC bucket.
* **Previews match execution**: normalizations, fees, and redemption fee snapshot.
* **Fail-safe**: Reverts on stale/oracle disabled, invalid pairs (U↔U, 0x↔0x), insufficient pocket allowance, or cap violations.
---