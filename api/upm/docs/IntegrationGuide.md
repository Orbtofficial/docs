# ORBT Integrator Guide: Pockets, UPM, and Strategies

> This document is purpose-built for integrators/allocators. It explains how to wire your wallets, treasuries, and execution stacks to ORBT’s UPM and strategy interfaces in a production-grade, DeFi-native way.

## Mental Model

- Pocket (Allocator): Your capital account (multisig EOA). Holds funds, signs txs, and owns positions.
- UPM: Your execution router. It sequences arbitrary actions atomically and is the only entry to strategies.
- Strategy: A stateless adapter to an external protocol (e.g., Aave). It never holds funds at end-of-call and applies protocol-level fee sharing on realized PnL.
- Governance: Timelocked change control. It whitelists pockets, tunes fees/treasury, and updates UPM/strategy params.

## Interfaces Snapshot

- UPM (`IOrbitUPM`)
  - `POCKET() → bytes32` role
  - `doCall(address target, bytes data) → bytes result`
  - `doBatchCalls(address[] targets, bytes[] datas) → bytes[] results`
  - `doDelegateCall(address target, bytes data) → bytes result`

- Base Strategy (`IBaseStrategy`)
  - `upm() → address`
  - `treasury() → address`
  - `feeBps() → uint256`
  - `principalOf(aToken, pocket) → uint256`
  - `executeGovernanceAction(actionType, payload) → bool`

- Orbt Money Market (`IOrbtMMStrategy`)
  - `supply(aToken, pocket, amount)`
  - `withdrawFromPocket(aToken, pocket, amount, to) → uint256 withdrawn`
  - `withdrawAllFromPocket(aToken, pocket, to) → uint256 withdrawn`
  - `approveDelegationFromPocketWithSig(debtToken, pocket, delegatee, amount, deadline, v, r, s)`
  - `delegationFromPocketWithSig(debtToken, pocket, delegatee, amount, deadline, v, r, s)`
  - `repay(aToken, pocket, amount) → uint256`
  - `repayWithPermit(aToken, pocket, amount, deadline, v, r, s) → uint256`

## Roles and Access Control

- Grant the `POCKET` role on UPM to your pocket address(es).
- Strategies are `onlyUPM` gated. Pockets never call strategies directly; they always route via UPM.
- Governance whitelists pockets per strategy; calls will revert if the pocket is not whitelisted.

## Core Flows (Step-by-Step)

### 1) Supply Liquidity (Pocket → UPM → OrbtMM)

- Preconditions:
  - Pocket is whitelisted on the strategy.
  - Pocket approves the underlying token to the strategy.
- Call path:
  - Pocket encodes `supply(aToken, pocket, amount)` and sends via `UPM.doCall` to the strategy.
  - Strategy pulls `amount` of underlying from pocket, deposits to the market, and mints aTokens to pocket.
  - Strategy records principal for (pocket, aToken). No residual balances.

### 2) Withdraw Liquidity (with Fee-on-Profit)

- Preconditions:
  - Pocket approves the strategy to transfer its aTokens.
- Call path:
  - Pocket encodes `withdrawFromPocket(aToken, pocket, amount, to)` (or `withdrawAllFromPocket`) via UPM.
  - Strategy pulls aTokens, withdraws underlying, computes realized profit, sends fee to `treasury`, sends net to `to`.
  - Principal is reduced by the principal portion of the withdrawal.

### 3) Credit Delegation (Optional)

- Delegator (pocket) signs a permit for delegation (variant depends on deployment).
- UPM relays signature via strategy’s `approveDelegationFromPocketWithSig` or `delegationFromPocketWithSig`.
- Delegatee borrows using Pool.borrow with `onBehalfOf = pocket`. Debt accrues to pocket; Aave enforces eMode and HF guards.

### 4) Repayment (Anyone)

- Any payer can repay pocket’s variable debt:
  - `repay(aToken, pocket, amount)` pulls underlying from payer, repays Pool, refunds dust.
  - `repayWithPermit(...)`: uses EIP-2612 to avoid a prior approve.

## Fee Mechanics (Profit Share)

- Fee applies only to realized profit at withdrawal, not at supply.
- Let `amountOut` be the withdrawn underlying.
- Split:
  - `principalReduced = min(amountOut, principal[pocket,aToken])`
  - `profit = amountOut - principalReduced`
  - `fee = profit * feeBps / 10_000` (or per-pocket override)
  - `netToPocket = amountOut - fee`
- Fee is transferred to ORBT `treasury`; net goes to the chosen recipient `to`.

## Governance Control Surface

- Governance executes timelocked actions on strategies via `executeGovernanceAction(actionType, payload)`.
- Expected actions:
  - `WHITELIST_POCKET(address)` / `DELIST_POCKET(address)`
  - `SET_GLOBAL_FEE(uint256)`
  - `SET_POCKET_FEE(address,uint256)`
  - `SET_TREASURY(address)`
  - `SET_UPM(address)`
- Governance also manages its own action type registry, thresholds, and timelock.

## Best Practices

- Use multisigs EOAs for pockets; segregate operational keys from treasury keys.
- Simulate every routed call via RPC before sending user transactions.
- Keep approvals minimal; where practical, use EIP-2612 permits to avoid sticky approvals.
- Monitor health factor and eMode limits when using credit delegation to avoid revert or liquidation boundaries.
- Track principal and estimated fee on frontend dashboards to provide accurate withdrawal previews.
- Batch complex flows via `doBatchCalls` to maintain atomicity and reduce gas overhead.

## Failure Modes and Guardrails

- Pocket not whitelisted → strategy reverts.
- Insufficient allowances → transfers fail/revert.
- Aave health/eMode constraints → Pool operations revert; show clear user errors.
- Residual balance on strategy → invariant checks fail; integration must not depend on strategy custody.

## Example Call Shapes (ABI Pseudocode)

- Supply:
  - target: `OrbtMMStrategy`
  - data: `supply(aToken, pocket, amount)`
- Withdraw:
  - target: `OrbtMMStrategy`
  - data: `withdrawFromPocket(aToken, pocket, amount, to)`
- Delegate Credit:
  - target: `OrbtMMStrategy`
  - data: `approveDelegationFromPocketWithSig(debtToken, pocket, delegatee, amount, deadline, v, r, s)`
- Repay:
  - target: `OrbtMMStrategy`
  - data: `repay(aToken, pocket, amount)`

## Security Posture

- Strategies are nonReentrant and UPM-gated; UPM is role-gated.
- Zero-custody invariant on strategies ensures intermediaries cannot trap user funds.
- Governance is EIP-712, signature-thresholded, and timelocked.

## Glossary

- Pocket/Allocator: The owner of funds/positions, granted `POCKET` role.
- UPM: The orchestrator that routes single/batch calls.
- Strategy: An adapter that interacts with an external protocol under ORBT rules.
- Principal: Tracked base amount supplied by a pocket per market.
- Realized Profit: Withdrawal amount beyond remaining principal.
- Treasury Fee: Protocol fee on realized profit at withdrawal time.

---

For questions or integration assistance, contact the ORBT core team or open a discussion in the governance forum.
