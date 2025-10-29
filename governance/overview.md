### Governance Overview

Governance controls parameterization, roles, upgrades, and cross-chain caps. Until on-chain voting is introduced, governance is executed via multisig + timelock and module-specific governance hooks.

- Role Hierarchy
  - Protocol governance (multisig) controlling `ADMIN` and ownership on modules
  - Timelock enforces delay on non-emergency actions

- Execution Paths
  - Direct admin calls (e.g., `setAssetTinBps`)
  - Governance hooks (e.g., `OrbtUCE.executeGovernanceAction`, `sOxAsset.executeGovernanceAction`, strategies’ `executeGovernanceAction`)

- Safety Controls
  - Pauses (global/per-asset), bridge caps, oracle enable/disable, upgrade gates
