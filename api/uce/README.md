# UCE: Unified Collateral Engine (API)

The Unified Collateral Engine (UCE) is the backbone of 0xAsset issuance and solvency. It aggregates and manages collateral deposits that back the protocol’s stablecoin (0xUSD) and synthetic assets (0xBTC, 0xETH). Unlike legacy systems that siloed collateral by asset type or vault, the UCE operates through a unified collateral pool governed by a consistent risk framework.

## Core Properties
Deterministic 1:1 accounting with **peg integrity**: Allocators mint 0xAssets via credit, but these remain in UCE and can only enter circulation when users swap equivalent underlying assets, ensuring all circulating 0xAssets are backed 1:1. Allocator-scoped credit mint/repay, dynamic redemption fee with decay, referral-based inventory attribution, reserve policy on inbound flows, global vs allocator liquidity separation, and formalized pocket migration.

## Components
- Peg Stability Module (PSM)
- 0xAssets (OxUSD/OxETH/OxBTC)
- Staking/Accrual wrapper (sOxAsset, ERC4626)
- User Position Manager (UPM) for arbitrary safe execution
- Pocket
- Allocator
- Strategy adapters (e.g., AaveSupplyOnly)
- StakingRewards for ORBT emissions
- governance with timelock and EIP-712 multisig.

## Surface

- Integration guide: `docs/IntegrationGuide.md`
- Events: `docs/events.md`
- Errors: `docs/errors.md`
- Interface: `IOrbtUCE.sol`
- Concepts: `../../concepts/uce.md`

## What it does

- U ↔ 0x: PSM-style mint/redemption with oracle-priced mints and dynamic redemption fees
- 0x ↔ s0x: ERC‑4626 deposit/redeem (no UCE fee)
- Two-layer liquidity: on-hand reserves + allowance‑bounded pocket pulls
- Referral routing for allocator-owned flow

See the Integration Guide for pricing, sourcing order, previews, and referral semantics.
