### Deployment Overview

Environments: testnet and mainnet with identical artifacts but different parameters.

Prerequisites:
- Role addresses (multisigs), timelock deployment, treasury
- Oracle feeds and heartbeats per asset/family
- Pockets and allowances
- Strategy parameters (fees, whitelists)

Safety:
- Staged rollout with canary, caps, and pauses available at every stage
