### sOxAsset Errors

Reverts are reason-string based. Primary failure cases grouped by function:

#### Initialization / Admin
- `sOxAsset/asset-zero`: underlying must be set
- `sOxAsset/rate-too-low`: `rateRay ≥ 1e27`
- `sOxAsset/governance-zero`, `sOxAsset/governance-already-set`
- `AccessControl`: `onlyRole(ADMIN)` for pause/unpause/upgrade/config

#### ERC4626 Actions
- `sOxAsset/receiver-zero` for deposit/mint/withdraw/redeem and claim
- `sOxAsset/zero-shares` on deposit path if computed shares is zero
- `sOxAsset/unstake-locked` when `minUnstakeDelay` not satisfied
- `sOxAsset/exit-buffer-exceeded` if requested `assets` exceed `exitBufferBps` of total assets

#### Rewards
- `sOxAsset/rewards-unset` when rewardToken/rewardVault unconfigured
- `sOxAsset/no-rewards` when nothing to claim

#### Governance Actions
- Payload validation failures revert per handler; e.g. invalid addresses or rate below RAY
