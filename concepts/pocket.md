# Pocket: Custody and Execution Unit

Pockets are special-purpose smart contract accounts (or designated addresses) where capital is deployed to execute predefined strategies. Each Pocket functions as an isolated strategy container with its own permissions, operational logic, and lifecycle controls.

## What a Pocket Does

- Custody: Holds just the capital needed for the active strategy; funds are not idle in strategy contracts.
- Execution: Calls strategies via UPM; completes the intent and clears results back to the core system.
- Return Flow: Returns profits or remaining capital to the Money Market or the user’s UPM position after execution.

## Permit Layer and Isolation

Each Pocket includes a permit layer that restricts behavior to pre-approved operations only.
- Whitelisted counterparties and protocols only
- Explicit return destinations (e.g., back to the Money Market or UPM position)
- Prevents unauthorized drains and limits blast radius of failures

Functionally, Pockets act like temporary, bounded vaults:
- Hold only capital required for a strategy
- Exist only for the strategy’s duration
- Clear funds back to core once done

## Composability and Governance

- Composability: Complex intents can coordinate multiple Pockets sequentially or in parallel (e.g., one swaps while another provides liquidity).
- Governance Approval: Pocket templates and strategy logic are approved by ORBT governance (timelocked, multi-sig). Community can propose new Pocket strategies, which facilitators deploy after vetting.

## Clearing and Execution Role (OCH)

The OCH (ORBT Clearing Hub) framing highlights Pocket as a mini on-chain clearing house:
- Settles intents such as swaps, LP provisioning, or borrows
- Interfaces with external protocols atomically
- Clears results back to originating user or module

This mirrors traditional finance settlement accounts and intent settlement systems (e.g., CoW Protocol, UniswapX), with the Pocket as the on-chain executor.

## Secure Strategy Execution

- Limited permissions and pre-approved operations only
- Executes only authorized transactions
- Automatically clears funds back to the core system
- Minimizes exposure and maximizes capital efficiency

## Pocket in the ORBTMM (Money Market)

Pocket is the custody and execution layer that turns UCE into a high-throughput, yield-aware settlement engine.
- Each supported asset (e.g., USDC) has a global pocket; allocator-specific pockets can exist
- Pockets custody underlyings from swaps, invest them in vetted money markets (Aave first)
- Stand ready, via allowances and/or credit delegation, to provide instant liquidity for redemptions and intent settlements

### Key Properties
- Direct custody: Pockets are plain addresses (EOA, multisig, or vault) that hold underlying; UCE pulls via ERC‑20 allowance
- Low-latency settlements: UCE keeps a per-asset reserve; bursts are served by pocket pulls
- Yield routing: Non-reserved balances are supplied to Aave while remaining withdrawable on demand
- Credit delegation: Delegate borrow capacity (Aave v3) to pre-approved settlement actors to enable instant intent settlements
- Attribution & incentives: Referral mapping ties user flow to an allocator’s pocket and consumes that allocator’s reserved 0x first

### Why It’s Necessary
- UX: Instant swaps/redemptions via UCE buffer + pocket pulls
- Economics: Aave yield offsets costs, sustains treasury, and supports allocator carry
- Attribution: Pre-provisioned pockets win order flow and spreads; a competitive surface for allocators

## Money Market Primer (context)

A money market (Aave/Compound-style) is a pooled lending protocol:
- Suppliers deposit and receive interest-bearing tokens (e.g., aTokens)
- Borrowers draw from the pool against collateral; rates float with utilization and risk controls
- aTokens are ERC‑20s; interest accrues via indices (rebasing or scaling)
- Withdrawals succeed subject to pool liquidity

## Aave-Only Pocket Strategy (baseline)

- Objective: Maximize availability for redemptions and intents; earn conservative, direction-light base yield; keep liquidation risk ≈ 0 with strict delegation caps
- Supply policy: Deposit non-reserved balances to Aave; optionally keep a 1–3% hot buffer on-Pocket for micro-settlements
- Withdrawal policy: UCE uses reserve first, then allowance pulls from Pocket; rebalance Pocket/Reserve as needed
- Credit delegation: Maintain per-delegate allowances (caps, tenor, global utilization limits); target HF > 2.0 under stress; enable eMode if safe

### Credit Delegation for Instant Settlements
- Why: Latency reduction, operational simplicity, and deterministic capacity
- Safeguards: Hard caps; time-boxed allowances (e.g., 30–120 min); kill switches; HF discipline; escrowed or bonded repayment flows
- Example: Pocket supplies 10m USDC; governance sets global/per-solver caps and expiries; solver borrows, settles, repays; HF preserved, APY continues

## Operational Checklist (Pocket)

- Maintain UCE allowances for redemptions
- Maintain strategy allowances (underlying → supply; aToken → withdraw)
- For OCH: supply collateral first; then sign and submit credit delegation; monitor HF and utilization
- Monitor principal, aToken balances, reserve utilization, delegated amounts, and fee parameters

## Related Docs

- UPM concept: `concepts/upm.md`
- Strategies concept: `concepts/strategies.md`
- UPM integrator guide: `api/upm/docs/IntegrationGuide.md`
- Strategies architecture guide: `api/upm/docs/OrbtStrategiesGuide.md`
