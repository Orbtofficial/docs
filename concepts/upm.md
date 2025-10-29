# ORBT UPM (Orbit User Position Manager)

A DeFi-native execution router for allocators (pockets) to compose multi-step flows across protocols and ORBT strategies, atomically and safely.

## Why UPM

- Orchestrate complex strategies in one tx (supply → stake → delegate → hedge).
- Maintain strict custody: pockets keep assets; UPM and strategies are intermediaries only.
- Enforce access via roles while staying generic and protocol-agnostic.

## Core Concepts

- Pocket (Allocator): EOA/multisig that owns funds and initiates flows.
- UPM: Minimal router with single and batched call primitives.
- Targets: Any contract, including ORBT strategies (which are `onlyUPM` gated).

## Interfaces (Surface)

- `POCKET() → bytes32`: role constant.
- `doCall(address target, bytes data) → bytes result`
- `doBatchCalls(address[] targets, bytes[] datas) → bytes[] results`
- `doDelegateCall(address target, bytes data) → bytes result`

Grant the `POCKET` role to allocator addresses.

## Role, Rights & Responsibilities (Pocket)

- Custody: Pocket directly holds underlying assets (USDC/USDT/DAI/…). It is a whitelisted allocator address.
- Attribution: Swaps with your referral code route inflows to your Pocket and consume your reservedOx first.
- Settlement Readiness: Keep ERC-20 allowances from Pocket → UCE sufficiently high for fast redemptions.
- Deployment: Pocket is the only caller authorized to instruct the UPM to operate strategies on its behalf.
- Profit Sharing: Strategy fees (bps on realized profit) are sent to ORBT Treasury; allocators earn net yield + any OCH intent fees.

## Control Plane: UPM Setup Checklist

- Access:
  - [ ] Governance grants `POCKET` role on UPM to your Pocket address.
  - [ ] Strategy contracts whitelist your Pocket (governance on strategy).
- Approvals:
  - [ ] Pocket → UCE: allowances for redemptions/pulls.
  - [ ] Pocket → Strategy: underlying approvals (supply) and aToken approvals (withdraw).
- Execution:
  - [ ] Use `doCall` for single action, `doBatchCalls` for pipelines, `doDelegateCall` for vetted library-style behaviors.

## Execution Patterns

- Single-step: Route one action (e.g., supply into a single market).
- Multi-step: Encode a pipeline (DEX swap → approve → strategy call) in `doBatchCalls`.
- Delegate execution: Use `doDelegateCall` for library-style behaviors when needed.

## Common Flows with Strategies

- Supply: pocket approves underlying to strategy, then routes `supply` via UPM.
- Withdraw: pocket approves aToken to strategy, then routes `withdraw` via UPM.
- Credit Delegation (OCH): pocket signs permit; UPM relays signature to strategy.
- Repay: any payer funds repayment; UPM may batch prior swaps for asset sourcing.

## Error Handling & Observability

- Bubble up revert data to frontends; label known strategy reverts (allowance, whitelist).
- Track per-step results from `doBatchCalls` to present partial diagnostics.

## Analyst KPIs & Monitoring

- Operational:
  - Pocket allowances to UCE and Strategies (threshold alerts).
  - aToken balances and `principalOf(aToken,pocket)` trajectories.
  - Delegation caps, utilization, and Aave health factor for OCH flows.
- Performance:
  - Realized profit vs. principal withdrawn (fee-on-profit share).
  - Batch success/failure rates and step-level revert taxonomy.

## Security Invariants

- Stateless: no persistent user state; each tx is self-contained.
- Non-custodial: assets should land on final recipients (vaults, pockets), not on UPM.
- Explicit permissions: pockets must grant ERC-20 allowances directly to target contracts/strategies.

## Best Practices for Integrators

- Use a dedicated multisig as the pocket; segregate operational and treasury keys.
- Simulate calls (eth_call) pre-execution; fail fast on bad calldata.
- Keep approvals minimal; prefer EIP-2612 `permit` where possible.
- Batch coherently: fewer external calls per batch improves reliability and gas.

## Role and Trust Model

- UPM is role-gated: only addresses with `POCKET` can trigger calls.
- Strategies are UPM-gated: pockets route via UPM; strategies reject direct calls.
- UPM is stateless and non-custodial by design; it doesn’t retain assets between txs.

---

## Architecture Deep Dive

- Minimal Router Core: UPM is intentionally thin to reduce attack surface. All business logic resides in targets (e.g., strategies).
- Call Graph: UPM → Address.functionCall/DelegateCall → Target. The UPM does not modify calldata; it simply forwards.
- Role Boundary: The POCKET role protects the entrypoint; downstream targets (strategies) protect themselves with `onlyUPM`.

### Execution Semantics

- Atomic Batching: `doBatchCalls` executes N calls sequentially; any revert aborts the entire batch (EVM atomicity).
- Return Data: Each call’s raw ABI-encoded return is preserved in `results[i]` for off-chain decoding.
- DelegateCall Caveat: `doDelegateCall` runs target code in UPM context; use only for vetted libraries or meta-programming.

### State & Storage

- UPM maintains roles only. No per-user state. No balances by design.
- ETH Handling: `receive()` is implemented for convenience (e.g., protocol refunds); integrations should forward ETH promptly to intended destinations.

## Governance & Upgrades (Context)

- Strategy configuration changes: via ORBTGovernance action queues and EIP-712 signatures.
- UPM’s role admin: governance or an admin multisig manages POCKET role assignments.
- Operational separation: governance configures; pockets operate.

## Failure Taxonomy

- Revert during batch step i: Entire batch reverts; no partial side effects.
- Target misbehavior: The UPM cannot sanitize arbitrary contracts; rely on auditing and allowlists client-side.
- Insufficient allowance: ERC-20 transferFrom reverts; surface clear UX to prompt approvals.

## Gas and Economic Considerations

- Overhead: UPM routing adds a small constant overhead relative to direct calls; mostly calldata and dispatch cost.
- Batching Economics: Batching amortizes base tx cost; ideal when combining multiple small steps.
- Data Size: Long calldata increases gas; prefer compact selectors and arguments where possible.

## Multi-Protocol Orchestration Patterns

- Swap → Permit → Supply: Swap into underlying, use permit to avoid direct approve, then supply via strategy.
- Claim → Compound → Rebalance: Claim rewards, swap to target asset, rebalance positions via multiple strategies in one batch.
- Hedge: Enter delta-neutral positions by composing DEX, Perp, and MM adapters atomically.
