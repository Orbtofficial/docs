### Mainnet Deployment

This guide builds on the testnet checklist with production controls and staged rollout.

#### Pre-Deployment
- Audits: final reports signed; criticals resolved; diffs re-reviewed
- Parameter freeze window and public RFC (if applicable)
- Multisig + timelock configured for `ADMIN`/`owner` roles

#### Deployment Stages
1) Stage 0 (Dry run): deploy with pause engaged; verify storage layout and role assignments
2) Stage 1 (Canary < 1% flow):
   - Set minimal `dailyCap`/`perTxMax` on bridge
   - Low `reserveBps` only if pockets are pre-funded; otherwise keep default
   - Tight oracle `heartbeat`; enable haircut for volatile assets
3) Stage 2 (Ramp):
   - Increase `dailyCap`, credit ceilings, and allowances based on telemetry
   - Whitelist limited pockets on strategies; validate dust checks

#### Post-Deployment Validation
- Swap matrix tests (Ox↔U, S↔Ox, exact-in/out) with small amounts
- Governance actions: execute benign payloads (no-ops) to validate wiring
- Monitoring online: alerts armed (oracle, caps, pauses, baseRedemptionRate)

#### Change Management
- All parameter changes via governance; adhere to timelock unless emergency
- Emergency actions: `pause`, per-asset `pauseAsset`, set bridge caps to zero
