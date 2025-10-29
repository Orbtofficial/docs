# ORBT Strategies

DeFi-native, stateless adapters that integrate external protocols under ORBT’s security and economics.

## Strategy Stack

- BaseStrategy (shared controls): UUPS upgradeability, UPM gating, nonReentrant, governance hook, fee/treasury config, principal accounting, pocket whitelist.
- Concrete strategies (e.g., OrbtMMStrategy): Implement protocol-specific supply/withdraw/debt/repay while upholding ORBT invariants.

## Design Principles

- Zero Custody: End every call with zero token balances on the strategy.
- UPM Gating: Only UPM may call operational functions; pockets route via UPM.
- Multi-Asset: Pass market/token references per call; derive dependencies dynamically.
- Fee on Realized Profit: Charge treasury fee only when profit is realized at withdrawal.
- Governance First: All knobs (whitelists, fees, treasury, UPM) controlled via timelocked governance.

## Deployment Modes

### A) Supply-Only (Money Market Yield)
- Pocket supplies idle funds into ORBT’s Money Market Strategy (Aave v3 adapter) through UPM.
- Earns baseline deposit yield; liquidity stays withdrawable on demand for settlements.
- Default entrypoint (via UPM): `OrbtMMStrategy.supply(aToken, pocket, amount)`.

### B) OCH — On-Chain Clearing House (Credit Delegation)
- Pocket supplies and delegates variable debt to a partnered solver.
- Delegate borrows against Pocket’s credit line to settle intents; repays from flows.
- Pocket earns intent settlement fees + APY; bears counterparty risk up to the delegated cap.

## OrbtMMStrategy (Money Market)

- Multi-asset Aave-like adapter: pass `aToken`; derive `POOL()` and underlying.
- Flows:
  - Supply: pull underlying from pocket; deposit on behalf of pocket; record principal.
  - Withdraw / WithdrawAll: pull aTokens; withdraw to strategy; split fee→treasury and net→recipient; update principal.
  - Credit Delegation: relay signatures for delegation; borrow occurs `onBehalfOf = pocket`.
  - Repay: anyone can repay pocket’s variable debt with or without permit.
- Invariants: zero residual balances; nonReentrant; input sanity checks; whitelist enforced.

## Interfaces Summary

- IBaseStrategy
  - `upm()`, `treasury()`, `feeBps()`, `principalOf(aToken,pocket)`
  - `executeGovernanceAction(actionType,payload)`
- IOrbtMMStrategy
  - `supply(aToken,pocket,amount)`
  - `withdrawFromPocket(aToken,pocket,amount,to)` / `withdrawAllFromPocket(aToken,pocket,to)`
  - Delegation signature relays
  - `repay(...)`, `repayWithPermit(...)`

## End-to-End Flows (via UPM)

### Supply
- Preconditions:
  - Pocket whitelisted on strategy; Pocket has `POCKET` role on UPM.
  - Approvals: `IERC20(UNDERLYING).approve(orbtMMStrategy, amount)`.
- Call shape:
  - `UPM.doCall(orbtMMStrategy, abi.encodeWithSelector(OrbtMMStrategy.supply.selector, aToken, pocket, amount))`
- Effect:
  - Strategy pulls `amount` underlying → deposits to Aave on behalf of `pocket` → increments principal.

### Withdraw (partial/all)
- Preconditions:
  - Approvals: `aToken.approve(orbtMMStrategy, amount)` (or full balance for withdrawAll).
- Call shape:
  - `UPM.doCall(orbtMMStrategy, abi.encodeWithSelector(OrbtMMStrategy.withdrawFromPocket.selector, aToken, pocket, amount, to))`
- Effect:
  - Strategy pulls aTokens → withdraws underlying → computes profit/fee-on-profit → sends fee→Treasury, net→`to` → updates principal.

### Credit Delegation (OCH)
- Steps:
  - Obtain `debtToken` (variable debt token address for market).
  - Pocket signs delegation permit; relay via `approveDelegationFromPocketWithSig(...)` (or `delegationFromPocketWithSig(...)`).
- Risk:
  - Delegate utilization bounded by signed limit; monitor HF and outstanding variable debt.

### Repay
- Anyone can pay down pocket debt:
  - `repay(aToken,pocket,amount)` or `repayWithPermit(...)`.

## Operational Checklists

- Runtime (Pocket):
  - Maintain UCE allowances for redemptions.
  - Maintain strategy allowances: underlying→supply, aToken→withdraw.
  - For OCH: supply collateral first; then sign and submit delegation; monitor HF/utilization.
- Monitoring:
  - `principalOf(aToken,pocket)` for basis tracking.
  - aToken balances, UCE reserve utilization, delegated amounts (debtToken views), fee parameters (events/governance).
  - Alerts on low allowances, high utilization, or stale governance settings.

## Observability & Events

- Typical events (implementation-dependent):
  - `Supplied(pocket, amount)`
  - `Withdrawn(pocket, to, amount)`
  - `Delegated(pocket, debtToken, delegatee, amount)`
- Metrics to track:
  - Realized profit vs principal, fee share to Treasury, net to Pocket.
  - Time-to-withdraw, revert rates by reason (allowance, whitelist, HF).

---

## Internals and Invariants (Deep Dive)

### Zero-Custody Proof Sketch

For each entrypoint E:
- Strategy pulls tokens (underlying or aTokens) just-in-time.
- Performs protocol action (deposit/withdraw/repay) and immediately forwards net results (fee→treasury, net→recipient).
- Asserts balances of both underlying and interest-bearing tokens are zero at end of E.
Thus, no residual custody can accumulate; any deviation reverts.

### Principal and Fee Mathematics

Let `P = principal[pocket,aToken]` and `W = withdrawal amount in underlying`.
- `principalReduced = min(W, P)`
- `profit = W - principalReduced`
- `feeBpsEffective = feeBpsOverride[pocket] == 0 ? feeBps : feeBpsOverride[pocket]`
- `fee = profit * feeBpsEffective / 10_000`
- `net = W - fee`
- `P' = P - principalReduced`
This ensures fee is assessed only on realized gains; pure principal withdrawals incur zero fee.

### Credit Delegation Semantics

- Delegation creates no debt by itself; it authorizes the delegatee.
- Debt is recorded on the pocket when delegatee borrows with `onBehalfOf = pocket`.
- Aave-level constraints (eMode category compatibility, HF checks) gate borrow feasibility; non-compliant borrows revert upstream.

### Repayment Semantics

- Any payer can repay pocket’s variable debt; strategy facilitates by pulling funds, approving Pool, repaying, and refunding dust.
- This supports operational flows where treasuries or liquidators aid position health without custody transfers.

### Multi-Asset Rationale

- Passing `aToken` per call decouples strategy instances from specific markets.
- Underlying and pool addresses are derived at runtime to avoid stale config and improve composability.

## Governance and Control Plane

- Timelocked Actions: Governance queues updates with EIP-712 signatures, then executes after ETA.
- Explicit Action IDs: Prevents ambiguous interpretation and reduces governance surface risks.
- Separation of Concerns: Governance manages configs; UPM enforces operational gating; strategies enforce invariants.

## Threat Model

- Token Semantics: Non-standard ERC-20s (fee-on-transfer) can cause deltas; zero-custody invariant mitigates accumulation but integrators should prefer standard assets.
- Oracle/Market Risk: External market protocols carry oracle and interest-rate risks; strategies do not mask these.
- Approval Risk: Pockets must manage allowances thoughtfully; per-call permits can reduce risk.

## Gas and Performance Considerations

- Extra approvals are set with forceApprove patterns to handle non-zero allowances; this adds a small constant cost.
- Batching via UPM reduces overall gas compared to discrete txs by amortizing base costs and eliding intermediate approvals when permits are used.

## Composition Patterns

- Cross-Strategy Rebalance: Withdraw from market A, swap, supply into market B—atomically via UPM.
- Looping with Delegation: Supply stablecoin, delegate credit, borrow volatile, hedge via DEX—single batch with clear state transitions.

## Upgradeability Discipline

- UUPS upgrades require owner authorization (governance-controlled). Keep storage gaps and validate initializer flows.
- Favor additive changes; avoid storage layout breaking edits.

## References

- Interfaces: `api/upm/IBaseStrategy.sol`, `api/upm/IOrbtMMStrategy.sol`.
- UPM Concept: `concepts/upm.md`
