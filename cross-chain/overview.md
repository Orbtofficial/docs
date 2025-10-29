### Cross-Chain Overview

Cross-chain transfers are handled by `AcrossUCEBridge`, moving UNDERLYING tokens only. Destination-side UCE performs U→Ox swaps to deliver Ox to users.

Key components:
- `SpokePool` (Across) on source chain
- Route config per destination: destination UCE, destination underlying, generic handler, caps

Safety controls:
- Owner-managed `pause`
- Per-tx and daily caps with UTC-day rolling bucket
- EIP-2612 permit for UX; strict deadline checks
