# ORBT-UCE: Unified Collateral Engine

<div align="center">

![ORBT Logo](./frontend/public/OxUSD.svg)

**A Professional DeFi Protocol for Unified Collateral Management**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange)](https://getfoundry.sh/)
[![Tests](https://img.shields.io/badge/Tests-Passing-green)]()

[Documentation](./docs) • [Security](./SECURITY.md) • [Contributing](./CONTRIBUTING.md) • [Discord](#) • [Website](#)

</div>

---

## 🚀 What is ORBT-UCE?

ORBT-UCE is a **modular DeFi protocol** that unifies fragmented collateral assets (like WBTC, cbBTC, tBTC) into standardized synthetic tokens (0xBTC) with **1:1 backing**, enabling:

✅ **Seamless Swaps** between any Bitcoin-backed asset  
✅ **Yield Generation** through ERC-4626 compliant staking vaults  
✅ **Capital-Efficient** minting lines for professional liquidity providers (not accessible unless equivalent collateral deposited)
✅ **Governance-Controlled** parameter management with timelock safety  

### The Problem

**Before ORBT-UCE**:
- Users hold fragmented assets (WBTC, cbBTC, tBTC) with separate liquidity pools
- Poor interoperability between similar assets
- No unified yield opportunities
- Capital inefficiency for market makers

**With ORBT-UCE**:
- Single synthetic token (0xBTC) backed by multiple underlying assets
- Seamless 1:1 swaps with automatic decimal normalization
- Unified yield through s0xBTC staking vaults (3-5% APY + rewards)
- Professional allocators provide efficient liquidity

---

## 📚 Quick Links

| Resource | Description |
|----------|-------------|
| [**Project Summary**](./docs/overview/PROJECT_SUMMARY.md) | Quick reference guide (5 min read) |
| [**Architecture**](./docs/overview/ARCHITECTURE.md) | System design and components |
| [**Technical Analysis**](./docs/technical/BASE_ANALYSIS.md) | Deep-dive security and code analysis |
| [**End-to-End Flows**](./docs/END_TO_END_FLOWS.md) | Complete user journey diagrams |
| [**System Diagrams**](./docs/COMPLETE_SYSTEM_DIAGRAM.md) | Visual architecture reference |
| [**Development Guide**](./PROJECT_CONFIGURATION.md) | Coding standards and best practices |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   ORBT-UCE Protocol                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Governance (Multi-sig + Timelock)                      │
│       │                                                  │
│       ├──► UCE (Swap Engine)        ─┐                  │
│       │     • 1:1 asset swaps         │                  │
│       │     • Allocator credit system │                  │
│       │     • Reserve management      │                  │
│       │                               │                  │
│       ├──► USM (Staking Vaults)      ├─► 0x Assets      │
│       │     • ERC-4626 compliance     │   (0xBTC, etc)   │
│       │     • Yield generation        │                  │
│       │     • Dual rewards            │                  │
│       │                               │                  │
│       └──► UPM (Orchestrator)        ─┘                  │
│             • Batch transactions                         │
│             • Multi-protocol routing                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Core Modules

| Module | Purpose | Gas Efficiency | Security |
|--------|---------|----------------|----------|
| **UCE** | Collateral swaps & management | O(1) debt tracking | ✅ High |
| **USM** | Yield-bearing staking vaults | Accumulator pattern | ✅ High |
| **UPM** | Transaction orchestration | Minimal overhead | ✅ High |
| **Governance** | Multi-sig timelock control | One-time cost | ✅ High |
| **Strategies** | External yield generation | Supply-only (safe) | ✅ Medium |
| **Rewards** | ORBT token staking | Time-weighted O(1) | ✅ High |

---

## 🎯 Key Features

### For Users
- 🔄 **Instant Swaps**: Convert between BTC assets at 1:1 ratio (no slippage)
- 💰 **Earn Yield**: 3-5% APY on staked assets + external rewards
- 🚀 **No Lock-ups**: Exit positions anytime (optional delays configurable)
- 🔧 **Composable**: ERC-20, ERC-4626, ERC-2612 standard compliance

### For Allocators (Liquidity Providers)
- 💳 **Minting buckets**: Mint 0x assets against pre-approved limits (Not accessible unless equivalent collateral deposited)
- 📍 **Referral System**: Capture user flow via referral codes
- 💸 **Earn on Deposits**: Deploy user collateral for yield
- 🎚️ **Flexible Management**: Custom pockets, configurable parameters

### For Developers
- 🧩 **Modular**: Independent, well-documented modules
- 🔒 **Secure**: Battle-tested patterns, comprehensive tests
- ⚡ **Gas Efficient**: Optimized for L1 mainnet
- 📖 **Well Documented**: NatSpec, READMEs, integration guides

### For Auditors
- ✅ **Clear Invariants**: Documented and tested
- ✅ **Standard Patterns**: No novel cryptography or algorithms
- ✅ **Comprehensive Tests**: Unit, integration, invariant coverage
- ✅ **Security Focus**: Defense in depth, multiple safety layers

---

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) - Smart contract development framework
- [Git](https://git-scm.com/) - Version control
- [Node.js](https://nodejs.org/) - Optional, for frontend

### Installation

```bash
# Clone the repository
git clone https://github.com/ORBT/ORBT-UCE.git
cd ORBT-UCE

# Initialize submodules
git submodule update --init --recursive

# Install dependencies
forge install

# Build contracts
forge build

# Run tests
forge test -vvv

# Run tests with gas reporting
forge test --gas-report

# Generate coverage report
FOUNDRY_PROFILE=coverage forge coverage --ir-minimum
```

### Project Structure

```
ORBT-UCE/
├── src/                    # Smart contracts
│   ├── core/              # Main protocol (UCE, UPM, USM)
│   ├── governance/        # Multi-sig timelock governance
│   ├── tokens/            # 0x synthetic assets
│   ├── strategies/        # Yield generation strategies
│   ├── rewards/           # ORBT staking rewards
│   └── interfaces/        # Contract interfaces
├── test/                  # Comprehensive test suite
│   ├── unit/             # Function-level tests
│   ├── integration/      # Cross-module tests
│   ├── invariant/        # Property-based tests
│   └── helpers/          # Test utilities
├── script/               # Deployment & operational scripts
│   ├── deploy/          # Deployment sequence
│   ├── setup/           # Post-deployment configuration
│   ├── tasks/           # Operational tasks
│   └── config/          # Network configurations
├── docs/                # Comprehensive documentation
│   ├── overview/       # High-level guides
│   ├── technical/      # Deep-dive analysis
│   └── guides/         # User & developer guides
└── frontend/           # Web application UI
```

---

## 📖 Documentation

### Essential Reading

1. **[Project Summary](./docs/overview/PROJECT_SUMMARY.md)** - 5-minute overview
2. **[Architecture](./docs/overview/ARCHITECTURE.md)** - System design
3. **[End-to-End Flows](./docs/END_TO_END_FLOWS.md)** - Complete user journeys
4. **[System Diagrams](./docs/COMPLETE_SYSTEM_DIAGRAM.md)** - Visual reference

### Module Documentation

Each module has detailed documentation:

- **[UCE Module](./src/core/uce/README.md)** - Collateral engine deep-dive
- **[USM Module](./src/core/usm/README.md)** - Staking vault specifications
- **[UPM Module](./src/core/upm/README.md)** - Transaction orchestration
- **[Governance](./src/governance/README.md)** - Governance system
- **[Tokens](./src/tokens/README.md)** - 0x asset specifications
- **[Strategies](./src/strategies/README.md)** - Yield generation
- **[Rewards](./src/rewards/README.md)** - ORBT staking

### Guides

- **[User Guide](./docs/guides/USER_GUIDE.md)** - How to use the protocol
- **[Allocator Guide](./docs/guides/ALLOCATOR_GUIDE.md)** - For liquidity providers
- **[Developer Guide](./docs/guides/DEVELOPER_GUIDE.md)** - Integration instructions
- **[Governance Guide](./docs/guides/GOVERNANCE_GUIDE.md)** - Participation guide

---

## 🔐 Security

### Audit Status

| Auditor | Date | Version | Report | Status |
|---------|------|---------|--------|--------|
| [Pending] | TBD | v1.0.0 | [Link] | 🟡 In Progress |

### Bug Bounty

Active bug bounty program with rewards up to **$100,000** for critical vulnerabilities.

📧 **Report vulnerabilities**: security@orbt.xyz

See our [Security Policy](./SECURITY.md) for full details.

### Security Features

✅ **Battle-Tested Patterns**: MakerDAO DSR, Synthetix StakingRewards, Compound Timelock  
✅ **OpenZeppelin Contracts**: Industry-standard security library  
✅ **Reentrancy Guards**: All state-changing functions protected  
✅ **Access Control**: Role-based permissions (ADMIN, SIGNER)  
✅ **Pausability**: Emergency circuit breakers  
✅ **Timelock**: 48-hour delay on governance actions  
✅ **Non-Upgradeable**: Immutable contracts (by design)  

---

## 💡 Use Cases

### User: Earn Yield on Bitcoin

```solidity
// 1. Swap WBTC → 0xBTC (1:1, no slippage)
uce.swapExactIn(WBTC, 0xBTC, 1e8, user, 0);

// 2. Stake 0xBTC → s0xBTC (earn 5% APY)
s0xBTC.deposit(1e18, user);

// Wait 1 year...

// 3. Unstake s0xBTC → 0xBTC (receive 1.05 0xBTC)
s0xBTC.redeem(shares, user, user);

// 4. Swap 0xBTC → WBTC (redeem to original)
uce.swapExactIn(0xBTC, WBTC, 1.05e18, user, 0);

// Result: 5% yield + ORBT rewards
```

### Allocator: Provide Professional Liquidity

```solidity
// 1. Governance onboards allocator (via multi-sig)
governance.queueAction(SET_ALLOCATOR, ...);

// 2. Admin mints credit (500 0xBTC)
uce.allocatorCreditMint(allocator, 500e18);

// 3. Users swap with allocator's referral code
// → Their WBTC goes to allocator's pocket
// → They receive 0xBTC from allocator's inventory

// 4. Allocator deploys WBTC to Aave (via UPM)
upm.doCall(aaveStrategy, deployCalldata);

// 5. Earn yield (~3% APY on deployed capital)

// 6. Repay debt from earnings
uce.allocatorRepay(WBTC, repayAmount);

// Result: Profit = Yield - Borrow Fee
```

### Developer: Integrate ORBT-UCE

```solidity
// Use in your DeFi protocol
import {IOrbitUCE} from "src/interfaces/core/IOrbitUCE.sol";

contract MyProtocol {
    IOrbitUCE public immutable uce;
    
    function convertAndStake(uint256 wbtcAmount) external {
        // Swap to 0xBTC
        uint256 oxAmount = uce.swapExactIn(
            WBTC, OxBTC, wbtcAmount, address(this), 0
        );
        
        // Use 0xBTC in your protocol logic
        // (lend, stake, provide liquidity, etc.)
    }
}
```

---

## 🧪 Testing

### Run Tests

```bash
# All tests with verbose output
forge test -vvv

# Specific test file
forge test --match-path test/unit/core/uce/OrbitUCETest.t.sol -vvv

# Specific test function
forge test --match-test test_SwapExactIn_Success -vvv

# Gas report
forge test --gas-report

# Coverage
FOUNDRY_PROFILE=coverage forge coverage --ir-minimum

# Invariant tests
forge test --match-contract Invariant -vvv
```

### Test Structure

- **Unit Tests** (`test/unit/`): Function-level testing
- **Integration Tests** (`test/integration/`): Cross-module interactions
- **Invariant Tests** (`test/invariant/`): Property-based testing
- **Mocks** (`test/mocks/`): External protocol simulations

### Test Coverage Goals

- ✅ Critical paths: 100%
- ✅ State transitions: 100%
- ✅ Access control: 100%
- ✅ Edge cases: 95%+
- ✅ Integration scenarios: Complete coverage

---

## 🌐 Deployment

### Networks

| Network | Status | Contracts |
|---------|--------|-----------|
| **Ethereum Mainnet** | 🟡 Planned | [Addresses](./deployments/mainnet/contracts.json) |
| **Sepolia Testnet** | 🟢 Active | [Addresses](./deployments/sepolia/contracts.json) |
| **Local (Anvil)** | 🟢 Available | [Guide](./docs/deployment/LOCAL.md) |

### Deployment Sequence

```bash
# 1. Deploy governance
forge script script/deploy/01_DeployGovernance.s.sol --broadcast

# 2. Deploy tokens (0xBTC, 0xETH, 0xUSD)
forge script script/deploy/02_DeployTokens.s.sol --broadcast

# 3. Deploy UCE instances (per family)
forge script script/deploy/03_DeployUCE.s.sol --broadcast

# 4. Deploy USM vaults (s0xBTC, etc.)
forge script script/deploy/04_DeployUSM.s.sol --broadcast

# 5. Setup roles and configuration
forge script script/setup/SetupGovernance.s.sol --broadcast
```

See [Deployment Guide](./docs/deployment/DEPLOYMENT_GUIDE.md) for complete instructions.

---

## 🔧 Development

### Build & Compile

```bash
# Compile all contracts
forge build

# Compile with optimization
forge build --optimize

# Compile with detailed output
forge build --force --sizes
```

### Code Quality

```bash
# Format code
forge fmt

# Check formatting
forge fmt --check

# Run linter (if configured)
solhint 'src/**/*.sol'
```

### Gas Profiling

```bash
# Create gas snapshot
forge snapshot

# Compare against baseline
forge snapshot --diff

# Detailed gas report
forge test --gas-report
```

---

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](./CONTRIBUTING.md) before submitting PRs.

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch (`feature/your-feature`)
3. **Follow** our [coding standards](./PROJECT_CONFIGURATION.md)
4. **Write** comprehensive tests
5. **Update** documentation
6. **Submit** a pull request

### Code Standards

- ✅ Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- ✅ Use battle-tested patterns (no novel cryptography)
- ✅ Add NatSpec comments to all functions
- ✅ Maintain > 90% test coverage
- ✅ Include security considerations

---

## 📊 Protocol Statistics

### Smart Contracts

- **Total Lines of Code**: ~2,800 LOC
- **Modules**: 7 (UCE, USM, UPM, Governance, Tokens, Strategies, Rewards)
- **Test Coverage**: Target 95%+
- **Gas Efficiency**: Optimized for L1 mainnet

### Key Metrics (Target at Launch)

| Metric | Target | Current |
|--------|--------|---------|
| TVL | $10-50M | TBD |
| Supported Assets | 9+ (3 per family) | 9 |
| Active Allocators | 5-10 | TBD |
| Staking APY | 3-5% + rewards | TBD |
| 24h Volume | $1-10M | TBD |

---

## 🛣️ Roadmap

### Phase 1: Development (Current)
- ✅ Core protocol implementation
- ✅ Comprehensive testing
- ✅ Documentation complete
- 🟡 Security audit (in progress)

### Phase 2: Testnet (Q1 2024)
- Deploy to Sepolia
- Public testing period (4-6 weeks)
- Bug bounty program launch
- Community feedback integration

### Phase 3: Mainnet Launch (Q2 2024)
- Mainnet deployment
- Initial TVL cap ($10M)
- Gradual scale-up
- Monitoring & optimization

### Phase 4: Expansion (Q3-Q4 2024)
- Additional yield strategies (Compound, Morpho)
- Cross-chain deployment (L2s)
- Governance voting integration
- Protocol revenue optimization

---

## 🏆 Benchmarked Against

ORBT-UCE follows best practices from leading DeFi protocols:

| Protocol | Pattern Adopted |
|----------|-----------------|
| **MakerDAO** | DSR accumulator pattern (USM interest accrual) |
| **Synthetix** | StakingRewards (Rewards module) |
| **Compound** | Timelock governance (Governance module) |
| **Aave** | Supply-only integration (Strategies module) |
| **Uniswap** | Documentation structure & repository organization |

---

## 📜 License

This project is licensed under the [MIT License](./LICENSE).

---

## 🔗 Links & Resources

- **Website**: [orbt.xyz](#)
- **Documentation**: [docs.orbt.xyz](#)
- **Discord**: [discord.gg/orbt](#)
- **Twitter**: [@ORBT_Protocol](#)
- **Forum**: [forum.orbt.xyz](#)
- **GitHub**: [github.com/ORBT/ORBT-UCE](https://github.com/ORBT/ORBT-UCE)

---

## 📞 Contact

- **General Inquiries**: hello@orbt.xyz
- **Security**: security@orbt.xyz
- **Partnerships**: partnerships@orbt.xyz
- **Support**: support@orbt.xyz

---

## ⚠️ Disclaimer

This software is provided "as is", without warranty of any kind. Smart contracts hold financial value and may contain bugs. Users interact at their own risk. Please review our [Security Policy](./SECURITY.md) and conduct your own research before using the protocol.

**Audit Status**: Pre-audit. Do not use with real funds until professionally audited.

---

## 🙏 Acknowledgments

Built with support from:
- OpenZeppelin (security libraries)
- Foundry (development framework)
- The Ethereum community
- Our contributors and advisors

Special thanks to the teams behind MakerDAO, Synthetix, Compound, Aave, and Uniswap for pioneering the patterns and best practices that inspired this protocol.

---

<div align="center">

**Made with ❤️ by the ORBT Core Team**

⭐ Star us on GitHub | 🐦 Follow on Twitter | 💬 Join our Discord

</div>

