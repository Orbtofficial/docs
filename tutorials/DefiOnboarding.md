# DeFi Onboarding: Integrating ORBT

This tutorial walks new protocols through a safe, production-grade integration with ORBT.

## 1) Choose Your Surface
- Swaps: ../api/uce/docs/IntegrationGuide.md
- Staking vaults (USM): ../api/usm/docs/IntegrationGuide.md
- Allocator execution (UPM/Strategies): ../api/upm/docs/IntegrationGuide.md

## 2) Quote Before You Send
- Always use UCE previews for swaps: `previewSwapExactIn/Out`.
- For USM, use ERC-4626 previews and `previewExchangeRateRay()` if needed.

## 3) Allowances & Permits
- Set exact allowances for ERC-20 and ERC-4626 shares.
- Prefer permit flows where available to reduce approval surface.

## 4) Operational Safety
- Monitor pocket allowances and balances for redemptions (referral flows).
- Respect pauses and stale-oracle reverts on UCE.

## 5) Analytics
- Index UCE `Swap` and Rewards events.
- Track USM exchange rate and reward indices.

## 6) Test Locally
- Foundry quickstart: see examples in ../api/usm/readme.md.

## Reference
- API index: [api/README.md](api/README.md)
- Concepts: ../concepts


