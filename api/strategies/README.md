# Strategies (Adapters) — API

Zero‑custody adapters that integrate external protocols under ORBT invariants. The primary adapter is the Money Market strategy (Aave‑style).

## Surface

- Integration guide: `docs/IntegrationGuide.md`
- Events: `docs/events.md`
- Errors: `docs/errors.md`
- Interfaces: `IBaseStrategy.sol`, `IOrbtMMStrategy.sol`
- Concepts: `../../concepts/strategies.md`

## What they do

- Supply/withdraw underlying on behalf of pockets
- Fee‑on‑profit at withdrawal routed to treasury
- Credit delegation helpers and open repayment utilities
- Strict `onlyUPM` gating and nonReentrant execution
