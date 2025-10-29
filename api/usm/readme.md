# USM: s0xAsset Vaults (User Staking Module)

Yield-bearing ERC-4626 vaults over 0x assets. Users deposit 0x tokens and receive s0x shares whose value appreciates over time via a governance-controlled exchange rate. Vaults can optionally stream external reward tokens.

## Key Features

- ERC-4626 compliant: deposit/mint/withdraw/redeem + previews
- Accumulator-based yield: `exchangeRateRay` grows per second by `rateRay` (RAY precision)
- Optional rewards: linear streaming from a pre-funded `rewardVault`
- Risk controls: `exitBufferBps` and optional `minUnstakeDelay`
- Rewards-only mode: freeze exchange rate; continue external rewards
- Governance actions: set rate, configure rewards, toggle rewards-only

## Quick Links

- Integration guide: [docs/IntegrationGuide.md](docs/IntegrationGuide.md)
- Events: [docs/events.md](docs/events.md)
- Errors: [docs/errors.md](docs/errors.md)
- Interface: [IS0xAsset.sol](IS0xAsset.sol)
- Conceptual overview: [../../concepts/usm.md](../../concepts/usm.md)

## Basic Flow

1. Approve the vault for the underlying 0x token
2. Deposit or mint shares using ERC-4626
3. Optionally claim streamed rewards
4. Redeem or withdraw later; previews reflect the current exchange rate

See the integration guide for exact method surfaces, previews, reward accounting, and governance-sensitive parameters.


