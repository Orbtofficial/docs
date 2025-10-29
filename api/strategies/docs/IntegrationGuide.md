# Strategies: Architecture and Integration Guide

This guide explains how pockets (allocators), UPM, and strategy adapters work together. Adapters are non‑custodial and `onlyUPM` gated. The Money Market adapter (OrbtMM) is the canonical example.

## Roles & Principles

- Pocket (Allocator): custody, approvals, initiates flows via UPM
- UPM: routes single/batch calls; enforces `POCKET` role
- Strategy: zero‑custody, nonReentrant, `onlyUPM`; fee‑on‑profit at withdraw
- Governance: whitelists pockets, sets fees/treasury/UPM

## Core Flows

1) Supply (Pocket → UPM → Strategy)
- Approve underlying to strategy; route `supply(aToken, pocket, amount)` via UPM

2) Withdraw (fee‑on‑profit)
- Approve aToken to strategy; route `withdrawFromPocket(aToken, pocket, amount, to)`

3) Credit Delegation
- Pocket signs permit; relay via `approveDelegationFromPocketWithSig` (or variant)

4) Repayment (anyone)
- `repay(aToken, pocket, amount)` or `repayWithPermit(...)`

## Governance Actions (typical)

- `WHITELIST_POCKET`, `DELIST_POCKET`
- `SET_GLOBAL_FEE`, `SET_POCKET_FEE`
- `SET_TREASURY`, `SET_UPM`

## Interfaces

- `IBaseStrategy.sol`: shared views and governance hook
- `IOrbtMMStrategy.sol`: supply/withdraw/delegation/repay surface

See the concepts and UPM docs for security invariants and patterns.
