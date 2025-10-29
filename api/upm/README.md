# UPM: Orbit User Position Manager (API)

Stateless orchestrator that routes single/batch calls from pockets to strategies.

## Surface

- Integration guide: `docs/IntegrationGuide.md`
- Strategies architecture: `docs/OrbtStrategiesGuide.md`
- Events: `docs/events.md`
- Errors: `docs/errors.md`
- Interface: `IOrbitUPM.sol`
- Concepts: `../../concepts/upm.md`

## What it does

- Provides `doCall`, `doBatchCalls`, `doDelegateCall` under the `POCKET` role
- Enforces separation: pockets call UPM; strategies are `onlyUPM`
- Works with strategy adapters (e.g., Money Market) for supply/withdraw/delegation/repay flows

See the Strategies guide for adapter semantics and security invariants.
