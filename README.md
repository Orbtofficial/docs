<div align="center">

<img src="assets/orbt.jpeg" alt="ORBT Logo" width="600"/>

# ORBT Documentation

[![Docs](https://img.shields.io/badge/Docs-Start%20Here-4c9aff)](#start-here)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20%2B-363636?logo=solidity)](#contracts--interfaces)
[![Foundry](https://img.shields.io/badge/Tested%20with-Foundry-2ea44f)](https://book.getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-ff69b4)](#)

</div>

The ORBT protocol is a unified liquidity and asset management system centered around the Unified Collateral Engine (UCE), User Staking Module (USM), and an execution layer (UPM + Strategies). This index helps you navigate concepts, integration guides, and contract surfaces quickly.

> A unified, security‑first liquidity and asset management protocol for 0xAssets.

---

## Table of Contents

- [Start Here](#start-here)
- [Ecosystem & Install](#ecosystem--install)
- [Concepts](#concepts)
- [Architecture Overview](#architecture-overview)
- [ORBT Landscape Diagram](#orbt-landscape-diagram)
- [Integration APIs](#integration-apis)
- [Contracts & Interfaces](#contracts--interfaces)
- [Tutorials](#tutorials)
- [Suggested Journeys by Role](#suggested-journeys-by-role)
- [Module Repositories](#module-repositories)
- [Use Cases](#use-cases)
- [Testing & Development](#testing--development)
- [Security](#security)
- [Benchmarked Against](#benchmarked-against)
- [Links & Resources](#links--resources)
- [Community & Support](#community--support)
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
   - concepts: [UPM](concepts/upm.md), [Strategies](concepts/strategies.md)
4. Allocator & Pocket — roles, economics, operations
   - concepts: [Allocator](concepts/allocator.md), [Pocket](concepts/pocket.md)
5. Rewards — emissions and distribution
   - concepts: [Rewards](concepts/rewards.md)

Then jump into the relevant Integration Guides below.

---

## Quick Links

- Concepts → APIs: [Concepts](#concepts) → [Integration APIs](#integration-apis)
- API index: [api/README.md](api/README.md)
- Module READMEs: [UCE](api/uce/README.md) · [UPM](api/upm/README.md) · [Strategies](api/strategies/README.md) · [USM](api/usm/README.md) · [Staking Rewards](api/rewards/README.md)
- Security: [overview](security/overview.md) · [threat model](security/threat-model.md) · [invariants](security/invariants.md)
- Deployment: [deployment/overview.md](deployment/overview.md)
- Governance: [governance/overview.md](governance/overview.md)

## Ecosystem & Install

- Tooling:
  - Foundry (contracts/testing): see [Foundry Book](https://book.getfoundry.sh/)
  - Node.js (optional scripts), a modern wallet
- Quick setup suggestions (for integrators):
  - Always use preview/read-only calls before sending txs
  - Configure ERC-20 approvals with least privilege; prefer permit flows when available

---

## Concepts

- UCE: Unified Collateral Engine
  - Swaps across U ↔ 0x and 0x ↔ s0x with oracle/pricing, reserves, and dynamic redemption fees.
  - read: [concepts/uce.md](concepts/uce.md)

- USM: User Staking Module (s0x vaults)
  - ERC‑4626 vaults over 0x assets; shares appreciate via exchange rate and optional rewards.
  - read: [concepts/usm.md](concepts/usm.md)

- UPM (User Position Manager)
  - Stateless orchestrator for single/batch calls from pockets; role-gated access.
  - read: [concepts/upm.md](concepts/upm.md)

- Strategies (Money Market & beyond)
  - Zero-custody adapters with fee-on-profit; supply-only and OCH (credit delegation) modes.
  - read: [concepts/strategies.md](concepts/strategies.md)

- Allocator & Pocket
  - Credit issuers and liquidity partners; manage reserved 0x, pockets, and operational allowances.
  - read: [concepts/allocator.md](concepts/allocator.md), [concepts/pocket.md](concepts/pocket.md)

- Rewards
  - Emissions model, revenue distribution, fairness and risk.
  - read: [concepts/rewards.md](concepts/rewards.md)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     ORBT Protocol                       │
├─────────────────────────────────────────────────────────┤
│  Governance (Timelock + Multisig)                       │
│       │                                                 │
│       ├──► UCE (Swap & Credit)                          │
│       │     • U ↔ 0x oracle-priced; dynamic redemption  │
│       │     • Reserve policy & referral attribution     │
│       │                                                 │
│       ├──► USM (ERC-4626 Vaults)                        │
│       │     • Accumulator-based yield + rewards         │
│       │                                                 |
|       ├──► Staking Rewards (ORBT staking)               │
│       │     • Accumulator-based rewards                 │
│       │                                                 │
│       └──► UPM (Orchestrator) ─► Strategies             │
│             • Batch txs, zero-custody adapters          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### ORBT Landscape Diagram

![ORBT Landscape](assets/orbt-landscape.png)

---

## Integration APIs

- UCE Swaps Integration
  - guide: [api/uce/docs/IntegrationGuide.md](api/uce/docs/IntegrationGuide.md)
  - interface: [api/uce/IOrbtUCE.sol](api/uce/IOrbtUCE.sol)

- UPM and Strategies Integration (for allocators/integrators)
  - integrator guide: [api/upm/docs/IntegrationGuide.md](api/upm/docs/IntegrationGuide.md)
  - architecture & details: [api/upm/docs/OrbtStrategiesGuide.md](api/upm/docs/OrbtStrategiesGuide.md)
  - UPM interface: [api/upm/IOrbitUPM.sol](api/upm/IOrbitUPM.sol)
  - Strategies: [api/strategies/docs/IntegrationGuide.md](api/strategies/docs/IntegrationGuide.md), [api/strategies/IBaseStrategy.sol](api/strategies/IBaseStrategy.sol), [api/strategies/IOrbtMMStrategy.sol](api/strategies/IOrbtMMStrategy.sol)

- USM / s0x Vaults
  - integration guide: [api/usm/docs/IntegrationGuide.md](api/usm/docs/IntegrationGuide.md)
  - detailed vault README (s0xAsset): [api/usm/readme.md](api/usm/readme.md)
  - interface: [api/usm/IS0xAsset.sol](api/usm/IS0xAsset.sol)

- Staking Rewards (ORBT)
  - integration guide: [api/rewards/docs/IntegrationGuide.md](api/rewards/docs/IntegrationGuide.md)
  - interface: [api/rewards/IStakingRewards.sol](api/rewards/IStakingRewards.sol)
  - module README: [api/rewards/README.md](api/rewards/README.md)

> API index: [api/README.md](api/README.md)

---

## Interfaces

- UCE: [api/uce/IOrbtUCE.sol](api/uce/IOrbtUCE.sol)
- UPM & Strategies: [api/upm/IOrbitUPM.sol](api/upm/IOrbitUPM.sol), [api/strategies/IBaseStrategy.sol](api/strategies/IBaseStrategy.sol), [api/strategies/IOrbtMMStrategy.sol](api/strategies/IOrbtMMStrategy.sol)
- USM: [api/usm/IS0xAsset.sol](api/usm/IS0xAsset.sol)
- Rewards: [api/rewards/IStakingRewards.sol](api/rewards/IStakingRewards.sol)

See full API summaries: [api/README.md](api/README.md)
---

## API Module READMEs (Deep Links)

- UCE: [api/uce/README.md](api/uce/README.md)
- UPM: [api/upm/README.md](api/upm/README.md)
- Strategies: [api/strategies/README.md](api/strategies/README.md)
- USM: [api/usm/README.md](api/usm/README.md)
- Staking Rewards: [api/rewards/README.md](api/rewards/README.md)

---

## Docs Directory Navigator

- Concepts
  - UCE: [concepts/uce.md](concepts/uce.md)
  - USM: [concepts/usm.md](concepts/usm.md)
  - UPM: [concepts/upm.md](concepts/upm.md)
  - Strategies: [concepts/strategies.md](concepts/strategies.md)
  - Allocator: [concepts/allocator.md](concepts/allocator.md)
  - Pocket: [concepts/pocket.md](concepts/pocket.md)
  - Rewards: [concepts/rewards.md](concepts/rewards.md)

- API
  - Index: [api/README.md](api/README.md)
  - UCE: [api/uce/docs/IntegrationGuide.md](api/uce/docs/IntegrationGuide.md), [Errors](api/uce/docs/errors.md), [Events](api/uce/docs/events.md), [Interface](api/uce/IOrbtUCE.sol)
  - UPM: [api/upm/docs/IntegrationGuide.md](api/upm/docs/IntegrationGuide.md), [OrbtStrategiesGuide](api/upm/docs/OrbtStrategiesGuide.md), [Interface](api/upm/IOrbitUPM.sol)
  - Strategies: [api/strategies/docs/IntegrationGuide.md](api/strategies/docs/IntegrationGuide.md), [Errors](api/strategies/docs/errors.md), [Events](api/strategies/docs/events.md), [Base](api/strategies/IBaseStrategy.sol), [MoneyMarket](api/strategies/IOrbtMMStrategy.sol)
  - USM: [api/usm/docs/IntegrationGuide.md](api/usm/docs/IntegrationGuide.md), [Errors](api/usm/docs/errors.md), [Events](api/usm/docs/events.md), [Interface](api/usm/IS0xAsset.sol)
  - Staking Rewards: [api/rewards/docs/IntegrationGuide.md](api/rewards/docs/IntegrationGuide.md), [Errors](api/rewards/docs/errors.md), [Events](api/rewards/docs/events.md), [Interface](api/rewards/IStakingRewards.sol)

- Cross‑Chain
  - Overview: [cross-chain/overview.md](cross-chain/overview.md)
  - Across integration: [cross-chain/across-integration.md](cross-chain/across-integration.md)
  - Asset flows: [cross-chain/asset-flows.md](cross-chain/asset-flows.md)
  - Bridge mechanics: [cross-chain/bridge-mechanics.md](cross-chain/bridge-mechanics.md)
  - Multi‑chain deployment: [cross-chain/multi-chain-deployment.md](cross-chain/multi-chain-deployment.md)

- Deployment
  - Overview: [deployment/overview.md](deployment/overview.md)
  - Testnet: [deployment/testnet-deployment.md](deployment/testnet-deployment.md)
  - Mainnet: [deployment/mainnet-deployment.md](deployment/mainnet-deployment.md)
  - Initial config: [deployment/initial-configuration.md](deployment/initial-configuration.md)

- Governance
  - Overview: [governance/overview.md](governance/overview.md)
  - Process & voting: [governance/process.md](governance/process.md), [governance/voting.md](governance/voting.md)
  - Action types & EIP‑712: [governance/action-types.md](governance/action-types.md), [governance/eip-712-signatures.md](governance/eip-712-signatures.md)
  - Proposal examples: [governance/proposal-examples.md](governance/proposal-examples.md)

- Operations
  - Monitoring & alerts: [operations/monitoring.md](operations/monitoring.md), [operations/alerts.md](operations/alerts.md)
  - Allocator onboarding: [operations/allocator-onboarding.md](operations/allocator-onboarding.md)
  - Incident response: [operations/incident-response.md](operations/incident-response.md)
  - Parameter adjustment: [operations/parameter-adjustment.md](operations/parameter-adjustment.md)
  - Governance procedures: [operations/governance-procedures.md](operations/governance-procedures.md)

- Security
  - Overview: [security/overview.md](security/overview.md)
  - Threat model: [security/threat-model.md](security/threat-model.md)
  - Invariants: [security/invariants.md](security/invariants.md)
  - Oracle security: [security/oracle-security.md](security/oracle-security.md)
  - Bug bounty: [security/bug-bounty.md](security/bug-bounty.md)
  - Audits: [security/audit-reports/README.md](security/audit-reports/README.md)

- Economics
  - Overview & fee structure: [economics/overview.md](economics/overview.md), [economics/fee-structure.md](economics/fee-structure.md)
  - Revenue distribution: [economics/revenue-distribution.md](economics/revenue-distribution.md)
  - Tokenomics & treasury: [economics/tokenomics.md](economics/tokenomics.md), [economics/treasury-model.md](economics/treasury-model.md)
  - Yield sources: [economics/yield-sources.md](economics/yield-sources.md)

- Quantitative & Risk
  - Capital efficiency: [quantitative/capital-efficiency.md](quantitative/capital-efficiency.md)
  - Reserve policy: [quantitative/reserve-policy.md](quantitative/reserve-policy.md)
  - Credit modeling: [quantitative/credit-modeling.md](quantitative/credit-modeling.md)
  - Yield analysis & fee curves: [quantitative/yield-analysis.md](quantitative/yield-analysis.md), [quantitative/fee-curves.md](quantitative/fee-curves.md)

- Tutorials
  - Quickstart: [tutorials/Quickstart.md](tutorials/Quickstart.md)
  - DeFi Onboarding: [tutorials/DefiOnboarding.md](tutorials/DefiOnboarding.md)

- Misc
  - FAQ: [FAQ.md](FAQ.md)
  - Glossary: [glossary.md](glossary.md)
  - Performance: [performance.md](performance.md)
  - Changelog: [CHANGELOG.md](CHANGELOG.md)
  - Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
  - License: [LICENSE](LICENSE)

## Tutorials

- Quickstart: [tutorials/Quickstart.md](tutorials/Quickstart.md)
- DeFi Onboarding: [tutorials/DefiOnboarding.md](tutorials/DefiOnboarding.md)

---

## Suggested Journeys by Role

- Builders / Integrators
  - Read: [UCE](concepts/uce.md) → [UCE Integration](api/uce/docs/IntegrationGuide.md)
  - If staking: [USM concept](concepts/usm.md) → [USM integration](api/usm/docs/IntegrationGuide.md)
  - If incentives: [Rewards concept](concepts/rewards.md) → [Rewards integration](api/rewards/docs/IntegrationGuide.md)

- Allocators / Liquidity Partners
  - Read: [Allocator & Pocket](concepts/allocator.md) → [UPM concept](concepts/upm.md) → [Strategies concept](concepts/strategies.md) → [UPM Integrator Guide](api/upm/docs/IntegrationGuide.md)

- Smart Contract Engineers
  - Skim: [Contracts & Interfaces](#contracts--interfaces) → open the relevant interfaces
  - Reference: [api/README.md](api/README.md)

---

## Module Repositories

- UCE (Unified Collateral Engine): Core swap engine and credit allocation
  - Repo: https://github.com/Orbtofficial/uce-v1
- USM (User Staking Module): ERC-4626 yield-bearing vaults for 0x assets
  - Repo: https://github.com/Orbtofficial/usm
- Governance: Timelocked multi-sig parameter updates
  - Repo: https://github.com/Orbtofficial/orbt-governance-v1
- Rewards: ORBT token staking rewards distribution
  - Repo: https://github.com/Orbtofficial/rewards
- UPM (User Position Manager): Stateless transaction orchestrator
  - Repo: https://github.com/Orbtofficial/upm
- Strategies (Core): Strategy base + adapters
  - Repo: https://github.com/Orbtofficial/strategy-core

---

## Use Cases

### User: Earn Yield on Bitcoin

```solidity
// 1. Swap WBTC → 0xBTC
uce.swapExactIn(WBTC, OX_BTC, 1e8, user, 0);

// 2. Stake 0xBTC → s0xBTC (ERC-4626)
IERC4626(s0xBTC).deposit(1e18, user);

// ... accrue yield ...

// 3. Unstake back to 0xBTC
IERC4626(s0xBTC).redeem(shares, user, user);

// 4. Redeem 0xBTC → WBTC if desired
uce.swapExactIn(OX_BTC, WBTC, 1.05e18, user, 0);
```

### Allocator: Provide Professional Liquidity

```solidity
// 1. Governance onboards allocator (off-chain process)
// 2. Admin mints allocator credit
uce.allocatorCreditMint(allocator, 500e18);

// 3. Users swap with allocator referral; U flows to pocket

// 4. Deploy U to Aave via UPM → Strategy
bytes memory data = abi.encodeWithSelector(
    OrbtMMStrategy.supply.selector,
    aToken,
    pocket,
    amount
);
IOrbitUPM(upm).doCall(address(orbtMMStrategy), data);

// 5. Repay debt from earnings over time
uce.allocatorRepay(UNDERLYING, repayAmount);
```

### Developer: Integrate ORBT UCE

```solidity
// Example helper using IOrbtUCE
IOrbtUCE uce;

function swapToOx(address u, address ox, uint256 amountU) external returns (uint256) {
    IERC20(u).approve(address(uce), amountU);
    return uce.swapExactIn(u, ox, amountU, msg.sender, 0);
}
```

---

## Testing & Development

- In module repositories (see Module Repositories above):

```bash
# Build
forge build

# Tests
forge test -vv

# Gas report
forge test --gas-report

# Format
forge fmt
```

---

## Security

### Audit Status

| Auditor | Date | Version | Report | Status |
|---------|------|---------|--------|--------|
| [Pending] | TBD | v1.0.0 | [Link] | 🟡 In Progress |

- Security contact: security@orbt.protocol
- Audit status: share reports when available
- Bug bounty: planned; scope and rewards to be published
- Best practices: role-gated entrypoints, nonReentrant strategies, zero-custody invariants

---

## Benchmarked Against

ORBT-UCE follows best practices from leading DeFi protocols:

| Protocol | Pattern Adopted |
|----------|-----------------|
| **SkyMoney & Spark** | PSM mechanics (UCE swaps) |
| **SkyMoney** | Yield  (Pockets) |
| **Prisma** | Dynamic redemption rates (0xUSD redemption rate) |
| **MakerDAO** | DSR accumulator pattern (USM interest accrual) |
| **Synthetix** | StakingRewards (Rewards module) |
| **Compound** | Timelock governance (Governance module) |
| **Aave** | Supply-only and Credit Delegation integration (Strategies module) |
| **Uniswap** | Documentation structure & repository organization |


---

## Links & Resources

- Concepts index: [Concepts](#concepts)
- API index: [api/README.md](api/README.md)
- Tutorials: [tutorials/](tutorials/)
- Module repositories: [Module Repositories](#module-repositories)

---

## ⚠️ Disclaimer

This software is provided "as is", without warranty of any kind. Smart contracts hold financial value and may contain bugs. Users interact at their own risk. Please review our [Security Policy](./SECURITY.md) and conduct your own research before using the protocol.

**Audit Status**: Pre-audit. Do not use with real funds until professionally audited.

---

## Community & Support

- Issues: use the templates under [.github](.github) to report bugs or request docs
- PRs: follow [CONTRIBUTING](.github/CONTRIBUTING.md)
- Security: security@orbt.protocol

---

## 🙏 Acknowledgments

Built with support from:
- OpenZeppelin (security libraries)
- Foundry (development framework)
- The Ethereum community
- Our contributors and advisors

Special thanks to the teams behind MakerDAO, Synthetix, Compound, Aave, and Uniswap for pioneering the patterns and best practices that inspired this protocol.

---

## Contributing

Improvements to docs are welcome. Submit a PR with clear, minimal changes. For larger structure changes, open an issue first to discuss navigation and scope. Please refer to [CONTRIBUTING](.github/CONTRIBUTING.md)

---

## License

Documentation and example interfaces are provided under the MIT license unless noted otherwise.


