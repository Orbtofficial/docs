<div align="center">

<img src="assets/orbt.jpeg" alt="ORBT Logo" width="600"/>

# ORBT Documentation

[![Docs](https://img.shields.io/badge/Docs-Start%20Here-4c9aff)](#start-here)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20%2B-363636?logo=solidity)](#contracts-index)
[![Foundry](https://img.shields.io/badge/Tested%20with-Foundry-2ea44f)](https://book.getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-ff69b4)](#)

</div>

The ORBT protocol is a unified liquidity and asset management system centered around the Unified Collateral Engine (UCE), User Staking Module (USM), and an execution layer (UPM + Strategies). This index helps you navigate concepts, integration guides, and contract surfaces quickly.

---

## Table of Contents

- [Start Here](#start-here)
- [Concepts](#concepts)
- [Integration APIs](#integration-apis)
- [Contracts Index](#contracts-index)
- [Suggested Journeys by Role](#suggested-journeys-by-role)
- [Contributing](#contributing)
- [License](#license)

---

## Start Here

If you are new to ORBT, read these in order:

1. UCE: Unified Collateral Engine — the core swap and credit system
   - concepts: [UCE](concepts/uce.md)
2. USM: User Staking Module — ERC-4626 staking over 0x assets
   - concepts: [USM](concepts/usm.md)
3. UPM & Strategies — execution layer for yield and delegation
   - concepts: [UPM & Strategies](concepts/upmAndStrategies.md)
4. Allocator & Pocket — roles, economics, operations
   - concepts: [Allocator](concepts/allocator.md)
5. Rewards — emissions and distribution
   - concepts: [Rewards](concepts/rewards.md)

Then jump into the relevant Integration Guides below.

---

## Concepts

- UCE: Unified Collateral Engine
  - Swaps across U ↔ 0x and 0x ↔ s0x with oracle/pricing, reserves, and dynamic redemption fees.
  - read: [concepts/uce.md](concepts/uce.md)

- USM: User Staking Module (s0x vaults)
  - ERC‑4626 vaults over 0x assets; shares appreciate via exchange rate and optional rewards.
  - read: [concepts/usm.md](concepts/usm.md)

- UPM & Strategies
  - Pockets route calls via UPM to strategy adapters (e.g., money markets). Profit‑share on realized PnL.
  - read: [concepts/upmAndStrategies.md](concepts/upmAndStrategies.md)

- Allocator & Pocket
  - Credit issuers and liquidity partners; manage reserved 0x, pockets, and operational allowances.
  - read: [concepts/allocator.md](concepts/allocator.md)

- Rewards
  - Emissions model, revenue distribution, fairness and risk.
  - read: [concepts/rewards.md](concepts/rewards.md)

---

## Integration APIs

- UCE Swaps Integration
  - guide: [api/uce/docs/IntegrationGuide.md](api/uce/docs/IntegrationGuide.md)
  - interface: [api/uce/IOrbtUCE.sol](api/uce/IOrbtUCE.sol)

- UPM and Strategies Integration (for allocators/integrators)
  - integrator guide: [api/upm/docs/IntegrationGuide.md](api/upm/docs/IntegrationGuide.md)
  - architecture & details: [api/upm/docs/OrbtStrategiesGuide.md](api/upm/docs/OrbtStrategiesGuide.md)
  - interfaces: [api/upm/IOrbitUPM.sol](api/upm/IOrbitUPM.sol), [api/upm/IBaseStrategy.sol](api/upm/IBaseStrategy.sol), [api/upm/IOrbtMMStrategy.sol](api/upm/IOrbtMMStrategy.sol)

- USM / s0x Vaults
  - integration guide: [api/usm/docs/IntegrationGuide.md](api/usm/docs/IntegrationGuide.md)
  - detailed vault README (s0xAsset): [api/usm/readme.md](api/usm/readme.md)
  - interface: [api/usm/IS0xAsset.sol](api/usm/IS0xAsset.sol)

- Staking Rewards (ORBT)
  - integration guide: [api/rewards/docs/IntegrationGuide.md](api/rewards/docs/IntegrationGuide.md)
  - interface: [api/rewards/IStakingRewards.sol](api/rewards/IStakingRewards.sol)

> API index: [api/README.md](api/README.md)

---

## Contracts Index

- UCE
  - `IOrbtUCE.sol` — [api/uce/IOrbtUCE.sol](api/uce/IOrbtUCE.sol)

- UPM & Strategies
  - `IOrbitUPM.sol` — [api/upm/IOrbitUPM.sol](api/upm/IOrbitUPM.sol)
  - `IBaseStrategy.sol` — [api/upm/IBaseStrategy.sol](api/upm/IBaseStrategy.sol)
  - `IOrbtMMStrategy.sol` — [api/upm/IOrbtMMStrategy.sol](api/upm/IOrbtMMStrategy.sol)

- USM
  - `IS0xAsset.sol` — [api/usm/IS0xAsset.sol](api/usm/IS0xAsset.sol)

- Rewards
  - `IStakingRewards.sol` — [api/rewards/IStakingRewards.sol](api/rewards/IStakingRewards.sol)

---

## Suggested Journeys by Role

- Builders / Integrators
  - Read: [UCE](concepts/uce.md) → [UCE Integration](api/uce/docs/IntegrationGuide.md)
  - If staking: [USM concept](concepts/usm.md) → [USM integration](api/usm/docs/IntegrationGuide.md)
  - If incentives: [Rewards concept](concepts/rewards.md) → [Rewards integration](api/rewards/docs/IntegrationGuide.md)

- Allocators / Liquidity Partners
  - Read: [Allocator & Pocket](concepts/allocator.md) → [UPM Integrator Guide](api/upm/docs/IntegrationGuide.md) → [Strategies Guide](api/upm/docs/OrbtStrategiesGuide.md)

- Smart Contract Engineers
  - Skim: [Contracts Index](#contracts-index) → open the relevant interfaces
  - Reference: [api/README.md](api/README.md)

---

## Contributing

Improvements to docs are welcome. Submit a PR with clear, minimal changes. For larger structure changes, open an issue first to discuss navigation and scope.

---

## License

Documentation and example interfaces are provided under the MIT license unless noted otherwise.


