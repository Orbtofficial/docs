### Access Control Matrix

#### Roles by Module

| Module | Role Model | Privileged Roles | Notes |
|---|---|---|---|
| OrbtUCE | AccessControl | `ADMIN` | UUPS auth; global and per-asset pause; governance hook `onlyGovernance` |
| sOxAsset | AccessControl | `ADMIN` | UUPS auth; pause; governance hook `onlyGovernance` |
| OrbitUPM | AccessControl | `DEFAULT_ADMIN_ROLE`, `POCKET` | Pausable; `POCKET` may perform doCall/batch/delegateCall |
| AcrossUCEBridge | Ownable | `owner` | Pausable; caps management; rescue |
| BaseStrategy | OwnableUpgradeable | `owner = UPM` | UUPS auth; owner is transferred to UPM in init |
| OrbtMMStrategy | Inherits BaseStrategy | `onlyUPM` | Strategy entrypoints gated by `onlyUPM`; fees to treasury |
| StakingRewards | Custom | `owner`, `rewardsDistribution` | Minting schedule mgmt via `rewardsDistribution` |

#### Critical Privileged Operations (non-exhaustive)

- OrbtUCE (ADMIN): `setPocket`, `addAsset`, `setOxAsset`, `setTreasury`, `pauseAsset`, `unpauseAsset`, `setAssetReserveBps`, `setAssetTinBps`, `setGovernance`, `emergencyWithdraw`, `setOracle`, `setBaseUsdFeed`, `setAllocatorSingleByAdmin`, `deposit`, `withdraw`, `pause`, `unpause`, UUPS upgrade
- sOxAsset (ADMIN): `pause`, `unpause`, `setGovernance`, `setMinUnstakeDelay`, UUPS upgrade
- OrbitUPM (POCKET): `doCall`, `doBatchCalls`, `doDelegateCall`
- AcrossUCEBridge (owner): `setRoute`, `updateCaps`, `pause`, `unpause`, `rescueTokens`
- BaseStrategy (owner=UPM): `setTreasury`, `setFeeBps`, UUPS upgrade
- StakingRewards (owner): `setRewardsDuration`, `setRewardsDistribution` (owner), `notifyRewardAmount` (rewardsDistribution)

#### Emergency Controls

- Global pause: `OrbtUCE.pause()` (ADMIN)
- Per-asset pause: `OrbtUCE.pauseAsset(asset)` / `assetPaused(asset)`
- Bridge pause: `AcrossUCEBridge.pause()` (owner)

#### Upgradeability

- UUPSUpgradeable on: `OrbtUCE`, `sOxAsset`, `BaseStrategy`
- Authorization: `onlyRole(ADMIN)` for UCE/sOx; `onlyOwner` for strategies (owner is UPM)

#### Notes and Operational Guidance

- Strategies are zero-custody: ownership transferred to UPM; UPM gates execution and whitelists pockets
- Use multisig + timelock for ADMIN/owner roles on UCE, Bridge, and Governance
- Route allocator-sensitive actions (credit lines, pockets) through governance where feasible
