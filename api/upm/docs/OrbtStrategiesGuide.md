# ORBT UPM and Strategies: Architecture and Integration Guide

## Purpose

This guide explains how pockets (allocators), OrbitUPM (UPM), and strategy adapters work together in the ORBT protocol.
## Components

- Pocket (Allocator): An multisig EOA that holds funds and initiates actions through UPM.
- OrbitUPM (UPM): The orchestrator contract that executes arbitrary call(s) on behalf of whitelisted pockets in a single atomic transaction.
- Strategy Adapters: Stateless contracts that interface with external protocols (e.g., money markets) and enforce ORBT-specific rules (whitelisting, fee sharing, zero-custody invariant).
- Governance: ORBTGovernance controls configuration of governed contracts through timelocked, multi-signature actions.

## High-Level Principles

- Non-Custodial: UPM and strategies must not retain user funds after operations. Strategies assert zero residual balances.
- UPM-Gated: Strategies expose operational entrypoints only callable by UPM. Pockets call UPM; UPM calls strategies.
- Multi-Asset: Strategies should accept asset references per call (e.g., aToken address) and derive protocol dependencies dynamically.
- Profit Sharing: On realized profit (typically at withdrawal), a fixed fee share is routed to the ORBT treasury. Principal is tracked per pocket per market.
- Governance-Controlled: Whitelists, fees, treasury, and UPM address are adjustable via governance action types and timelock.

## Roles and Responsibilities

- Pocket (Allocator):
  - Controls funds and approvals to strategies.
  - Initiates supply, withdrawal, and delegation flows by calling UPM.
  - Can be whitelisted per strategy via governance.

- UPM:
  - Validates caller has POCKET role.
  - Forwards single or batched calls to strategies and other targets.
  - Provides a simple, uniform execution surface for frontends.

- Strategy (e.g., OrbtMM):
  - Enforces onlyUPM gating and nonReentrancy.
  - Pulls tokens from pocket, interacts with external protocol, and leaves no balances.
  - Applies treasury fee on profit portion during withdrawal and updates principal.
  - Supports credit delegation (signature-based), and open repayment of pocket debt.

- Governance:
  - Registers governed targets.
  - Queues and executes action types after timelock with signature thresholds.
  - Updates per-strategy configuration (whitelists, fees, treasury, UPM address).

## Core Flows

1) Supply (Pocket → UPM → Strategy):
   - Pocket approves underlying to strategy.
   - Pocket calls UPM to route a supply call to the strategy with (market reference, pocket, amount).
   - Strategy pulls tokens from pocket, deposits into the external protocol on behalf of pocket, updates principal, and asserts no residual balances.

2) Withdraw (Pocket → UPM → Strategy):
   - Pocket approves strategy to transfer their interest-bearing tokens (e.g., aTokens).
   - Pocket calls UPM to route a withdrawal call.
   - Strategy pulls interest-bearing tokens from pocket, withdraws underlying, splits profit fee to treasury, sends net to recipient, and asserts no residual balances.

3) Credit Delegation:
   - Pocket authorizes delegatee via signature (supported methods vary by network).
   - UPM relays signature to the market’s debt token through the strategy.
   - Delegatee borrows on behalf of pocket; debt accrues to pocket subject to protocol risk checks (eMode, health factor).

4) Repayment (Anyone):
   - Any payer can repay the pocket’s debt via the strategy by transferring underlying or using permit.
   - Strategy approves the market and repays on behalf of the pocket, refunding any dust to the payer.

## Profit Sharing Model

- Principal Accounting: Strategy records total supplied principal per (pocket, market).
- Realized Profit: On withdrawal, profit = amountWithdrawn - principalReduction.
- Fee: fee = profit * feeBps (or per-pocket override) / 10_000. Fee is sent to ORBT treasury.
- Net Proceeds: net = amountWithdrawn - fee. Principal is reduced accordingly.

## Governance Integration

- Governed strategies implement a governance execute hook that accepts an action type and payload.
- Supported actions typically include:
  - WHITELIST_POCKET(address pocket)
  - DELIST_POCKET(address pocket)
  - SET_GLOBAL_FEE(uint256 feeBps)
  - SET_POCKET_FEE(address pocket, uint256 feeBps)
  - SET_TREASURY(address treasury)
  - SET_UPM(address upm)
- Governance uses an off-chain EIP-712 signing flow, queues actions with a timelock, and then executes them on-chain when the ETA has passed.

## Integration Checklist

- Access/Permissions:
  - Ensure pocket address is granted POCKET role on UPM.
  - Ensure pocket is whitelisted on target strategies via governance.

- Approvals (ERC-20):
  - Before supply: pocket → strategy (underlying token allowance).
  - Before withdraw: pocket → strategy (interest-bearing token allowance).

- Market References:
  - Provide the correct market token reference (e.g., aToken) to strategies per call.
  - Strategies derive pool and underlying addresses from market token.

- Safety:
  - Strategies assert zero residual balances post-operation; integration should not rely on residuals.
  - All operational entries are nonReentrant and `onlyUPM`.

## Frontend Patterns

- Single Action via UPM:
  - Encode the target strategy selector and arguments.
  - Call UPM’s single-call entry with target + data.

- Batch Actions via UPM:
  - For multi-step workflows (swaps → supply → stake), build arrays of targets and datas and call UPM’s batch entry.
  - Use client-side simulation to preview results and display a transaction plan to the user.

## Error Handling and Monitoring

- Validate whitelists and allowances before sending transactions.
- Surface protocol reverts (health factor, eMode constraints) with user-friendly messages.
- Track fee rates (global and per-pocket) and show estimated fee on withdrawal previews.

## Security Model Summary

- Custody: Pockets retain custody; strategies act as intermediaries only.
- Authorization: UPM restricts callers to the POCKET role; strategies restrict callers to UPM.
- Governance: Timelocked, multi-sig controlled configuration changes with explicit action type IDs.
- Invariants: No residual balances, nonReentrant execution, and explicit input validations.

## Adapting New Strategies

To add a new market adapter:
- Inherit BaseStrategy for shared controls and accounting.
- Keep it multi-asset by passing market references per call and deriving dependencies.
- Enforce whitelisting and onlyUPM on all operational paths.
- Implement protocol-appropriate supply/withdraw/debt delegation/repayment methods while maintaining zero-custody and fee-on-profit at withdrawal.

## Glossary

- Pocket (Allocator): The fund owner's custody multisig wallet that routes actions via UPM.
- UPM: OrbitUPM, the orchestrator that forwards single/batch calls from pockets.
- Strategy: A stateless adapter that interacts with an external protocol under ORBT rules.
- Principal: The amount of underlying supplied by a pocket into a market.
- Realized Profit: Amount withdrawn beyond remaining principal.
- Treasury Fee: Protocol share applied only to realized profit at withdrawal.
- Delegator/Delegatee: In credit delegation, the supplier (pocket) and borrower.

## Contacts and Support

- Security: security@orbt.protocol
- Governance Forum: see ORBT governance resources
- Integrations: reach out to the ORBT core team for best practices
