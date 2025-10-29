### Incident Response

Standard playbooks for common incidents.

#### Oracle Staleness / Bad Price
- Actions: per-asset pause; disable oracle or increase haircut; switch to fallback feed if configured
- Comms: status page, integrator notification

#### Liquidity Shortage (Pocket Allowance/Balance)
- Actions: raise reserveBps temporarily; increase pocket allowance; seed pockets via `deposit`
- Comms: announce reduced throughput; ETA for restoration

#### Bridge Saturation / Anomaly
- Actions: set caps to zero; pause adapter; coordinate with Across relayers
- Validation: audit recent `depositV3` calls; reconcile handler executions

#### Privileged Key Compromise (suspected)
- Actions: engage timelock cancels (if any), rotate multisig signers, global pause
- For UUPS: freeze upgrades; consider governance-imposed circuit breakers

#### Post-Mortem
- Timeline, impact, root cause, corrective/preventive actions; publish within agreed SLA
