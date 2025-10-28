# ORBT Quickstart

This guide gets you building against ORBT in minutes. For deeper context, see Concepts and the API Index.

## Prerequisites

- Wallet and test assets
- Foundry (optional for contract testing)
- Node.js (optional for scripting)

## Read First

- UCE overview: ../concepts/uce.md
- USM overview: ../concepts/usm.md
- UPM & Strategies: ../concepts/upmAndStrategies.md

## Common Flows

### 1) Swap U → 0x (mint)
- Guide: ../api/uce/docs/IntegrationGuide.md
- Approve underlying to UCE, preview, then call `swapExactIn`.

### 2) Redeem 0x → U
- Guide: ../api/uce/docs/IntegrationGuide.md
- Approve 0x to UCE, preview redemption, then call `swapExactIn` or exact-out.

### 3) Stake 0x → s0x (ERC-4626)
- Guide: ../api/uce/docs/IntegrationGuide.md
- Preview shares via `previewSwapExactIn`, approve, then `swapExactIn` to S0X.

### 4) Use USM vault directly
- Vault README: ../api/usm/readme.md
- Interface: ../api/usm/IS0xAsset.sol

### 5) Allocator supply via UPM + Strategy
- Guides: ../api/upm/docs/IntegrationGuide.md, ../api/upm/docs/OrbtStrategiesGuide.md
- Flow: Pocket → UPM `doCall` → Strategy `supply/withdraw/repay`.

## API Index

See ../api/README.md for all functions, previews, and events.


