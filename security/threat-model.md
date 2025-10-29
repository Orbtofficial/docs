### Threat Model

- Key risks:
  - Privileged key compromise (ADMIN/owner/POCKET)
  - Oracle manipulation or staleness (UCE)
  - Bridge misconfiguration or cap bypass (AcrossUCEBridge)
  - Reentrancy on external calls (strategies, UCE flows)
  - Upgrades introducing vulnerabilities (UUPS)
- Mitigations:
  - Multisig + timelock on privileged roles
  - Heartbeat checks and feed configuration controls
  - Daily and per-tx bridge caps; pausable bridge
  - ReentrancyGuard usage; per-asset pauses
  - Formal upgrade procedures and audits
