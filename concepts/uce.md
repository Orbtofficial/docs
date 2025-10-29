# UCE: Unified Collateral Engine

The Unified Collateral Engine (UCE) is the backbone of 0xAsset issuance and solvency. It aggregates and manages collateral deposits backing 0xUSD and family synthetics like 0xBTC/0xETH. Unlike siloed vaults, UCE runs a unified collateral pool with a consistent risk framework and PSM-style mechanics for instant, oracle-free redemptions.

Unified pool advantage: surplus in one collateral can absorb shortfalls in another (within family limits), minimizing idle capital while preserving a hard 1:1 peg via deterministic redemption, PSM semantics, and on-chain oracles for mint pricing.

## Purpose & Role

- Core liquidity hub for users, allocators, and integrators
- Ensures every 0xAsset is fully backed, instantly redeemable, and efficiently utilized via yield routes (UPM/Strategies)
- Bridges classic PSM flows with modern credit and pocket-based liquidity

## How It Works (Lifecycle)

1) Collateral inflow: Users/allocators deposit supported U (e.g., USDC, WBTC).
2) Minting 0xAssets: Users mint U→0x at oracle-priced parity (optional haircut, tin fee).
3) Active liquidity management: A per-asset reserve slice stays on UCE; the remainder forwards to pockets for yield via Strategies.
4) Redemptions & peg: 0x→U settles from reserves first, then allowance‑bounded pocket pulls (referral pocket first when provided).
5) Governance: Adjusts reserve ratios, tin, per-asset oracles, credit ceilings/daily caps, and allocator/pocket config.

## Design Objectives

- Hard-peg redemptions: Oracle-free, decimals‑normalized parity minus a dynamic, decaying redemption fee.
- Elastic minting: Oracle‑priced U→0x with optional mint haircut and tin (0x minted to treasury).
- Capital efficiency: Two-layer liquidity (reserves + pockets) for instant exits and productive idle.
- Predictable sourcing: Outbound U pulls are bounded by on-chain allowances and balances.
- Stability under stress: Fees rise with redemption pressure and decay automatically.

## Peg & Liquidity Model

- Layer 1: On-hand reserves. A configurable portion (e.g., 25%) of U inflow remains on UCE for fast 0x→U.
- Layer 2: Pockets. The remainder routes to global or allocator pockets; redemptions pull from pockets strictly within allowance/balance.
- Redemption determinism: 0x→U uses pure decimals normalization and a snapshotted fee; sourcing order is reserves → referral pocket → global pocket. No underlying is ever “printed”.

## Pricing & Fees

- U→0x (mint): oracle-priced per family; optional mint haircut; tinBps mints 0x to treasury.
- 0x→U (redeem): oracle‑free; dynamic redemption fee (capped; decays hourly) taken in U, preview‑consistent via snapshot.
- 0x↔s0x (ERC‑4626): fee‑free at UCE; vault exchange rate defines pricing.

## Routing & Settlement

- U→0x with referral: U to allocator pocket; 0x must come from referrer’s reserved inventory (else revert).
- U→0x without referral: Unreserved protocol inventory → pro‑rata allocator inventory → mint shortfall.
- 0x→U: Reserves first, then pocket pulls (referrer first if present), all bounded by allowance and balance.

## Oracle Scope & Risk

- Oracles are used only on mint (U→0x). Redemptions are oracle‑free.
- Heartbeats and stale checks enforced; non‑USD families compose USD feeds via base/USD as needed.

## Governance Surface

- Assets: add/rotate pocket, set reserveBps, set oracles and mint haircut, set tinBps, per‑asset pause.
- Allocators: allowlist, ceilings, daily caps, borrow fee, referral mapping, per‑asset pockets.
- Global controls: pause, treasury address.

## Invariants & Safety

- Liquidity bounded: pocket pulls limited by allowance and balance; insufficient liquidity reverts.
- Pair gating: Only U↔0x and 0x↔s0x supported.
- Preview parity: fee snapshot on redemption; consistent decimals normalization and tin application.

## Adding Assets (Admin)

Checklist before `addAsset(asset, family, pocket, reserveBps)`:
- Family fit (USD/ETH/BTC instance)
- Pocket readiness (custody address funded/allowanced)
- Reserve policy per asset (e.g., 25%)
- Oracle plan for U→0x (feeds, heartbeat, optional haircut)
- Optional tinBps

Post‑add operations:
- Attach oracles via `setOracle`
- Tune `setAssetTinBps` and `setAssetReserveBps`
- Pause/unpause per asset as needed
- Rotate pocket with allowance‑bounded migration

Operational implications:
- Redemptions are always bounded by reserves + pocket allowance/balance
- U→0x becomes available only after oracles are healthy

## Allocators (Overview)

Whitelisted entities that provision 0x inventory and custody pockets.
- Lifecycle: onboard → credit mint (OX inventory on UCE) → deploy underlying via Strategies → repay in underlying.
- Referral routing: user U inflows go to the allocator pocket; 0x to the user must be served from the allocator’s reserved inventory (else revert).
- Restrictions: allocators cannot redeem 0x→U directly; they settle via underlying‑side flows.

### Credit Minting (effects)
- Mints OX to UCE and credits allocator’s reserved inventory.
- Tracks issuance against ceiling and daily cap; emits credit events.

### Repayment (effects)
- Pulls underlying to UCE, applies borrow fee to treasury, and reduces allocator liability in OX‑equivalent terms (decimals‑normalized).
- On‑hand U rises, immediately strengthening redemption capacity.

## Referral vs Non‑Referral (At a Glance)

- With referral: U→0x uses referrer pocket for U and referrer inventory for 0x; 0x→U pulls from referrer pocket first.
- Without referral: U→0x uses unreserved → pro‑rata allocator inventory → mint; 0x→U uses reserves → global pocket.

## Swaps Quick Reference

- Allowed: U→0x, 0x→U, 0x↔s0x
- U→0x: oracle‑priced, haircut+tin; reserve split; outbound 0x from inventory then mint
- 0x→U: decimals normalization; dynamic fee; reserves→pockets sourcing
- 0x↔s0x: ERC‑4626 convertToShares/Assets; no UCE fee

---