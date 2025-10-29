# ORBT API Index

This page aggregates the on-chain API surfaces for core ORBT components and links to detailed integration guides and conceptual docs. Use it as your jump point while building.

---

## Table of Contents

- [UCE: Unified Collateral Engine](#uce-unified-collateral-engine)
- [USM: s0x Vault (IS0xAsset)](#usm-s0x-vault-isoxasset)
- [UPM: Orchestrator](#upm-orchestrator)
- [Strategies: Money Market Adapter](#strategies-money-market-adapter)
- [Staking Rewards](#staking-rewards)

---

## UCE: Unified Collateral Engine

- Concept: see [../concepts/uce.md](../concepts/uce.md)
- Integration Guide: [uce/docs/IntegrationGuide.md](uce/docs/IntegrationGuide.md)
- Interface: [uce/IOrbtUCE.sol](uce/IOrbtUCE.sol)

Key views:
- `pockets(asset) → address`
- `assetFamilies(asset) → AssetFamily { BTC | ETH | USD }`

Swaps:
- `swapExactIn(assetIn, assetOut, amountIn, receiver, referralCode) → amountOut`
- `swapExactOut(assetIn, assetOut, amountOut, maxAmountIn, receiver, referralCode) → amountIn`
- Previews: `previewSwapExactIn(assetIn, assetOut, amountIn) → amountOut`, `previewSwapExactOut(assetIn, assetOut, amountOut) → amountIn`

Liquidity (direct deposit/withdraw):
- `deposit(asset, receiver, assetsToDeposit) → newOxAssets`
- `withdraw(asset, receiver, maxAssetsToWithdraw) → assetsWithdrawn`
- Previews: `previewDeposit(asset, assets) → oxAssets`, `previewWithdraw(asset, maxAssetsToWithdraw) → (oxAssetsToBurn, assetsWithdrawn)`

Conversions:
- `convertToAssets(asset, numOxAssets) → assets`
- `convertToOxAssets(asset, assets) → oxAssets`

Allocator credit (admin/allocator flows):
- `allocatorCreditMint(allocator, amount)`
- `allocatorRepay(asset, assets)`

Admin (selection):
- `setPocket(asset, newPocket)`
- `addAsset(asset, family, pocket, reserveBps)`

Events (selection): `Swap`, `Deposit`, `Withdraw`, `AssetPaused`, `PocketSet`

---

## USM: s0x Vault (IS0xAsset)

- Concept: see [../concepts/usm.md](../concepts/usm.md)
- Integration Guide: [usm/docs/IntegrationGuide.md](usm/docs/IntegrationGuide.md)
- Detailed Vault README: [usm/readme.md](usm/readme.md)
- Interface: [usm/IS0xAsset.sol](usm/IS0xAsset.sol)

Core ERC-4626 surface (inherits IERC20, IERC4626):
- Standard deposit/mint/withdraw/redeem and preview methods

s0x-specific views:
- `underlyingAsset() → address`, `rateRay()`, `exchangeRateRay()`, `previewExchangeRateRay()`
- Rewards: `rewardToken()`, `rewardVault()`, `rewardRatePerSecond()`, `rewardIndexRay()`, `previewRewardIndexRay()`, `claimable(account)`
- Exit controls: `exitBufferBps()`, `minUnstakeDelay()`, `earliestUnstakeTime(account)`

Actions:
- `drip() → newExchangeRateRay`
- `claim(to, amount) → claimed`

Events (selection): `Drip`, `RateSet`, `RewardAccrued`, `RewardClaimed`, `RewardConfigSet`, `RewardsOnlyModeSet`, `MinUnstakeDelaySet`

---

## UPM: Orchestrator

- Concepts: [../concepts/upmAndStrategies.md](../concepts/upmAndStrategies.md)
- Integration Guide: [upm/docs/IntegrationGuide.md](upm/docs/IntegrationGuide.md)
- Interface: [upm/IOrbitUPM.sol](upm/IOrbitUPM.sol)

Surface:
- `POCKET() → bytes32`
- `doCall(target, data) → bytes`
- `doBatchCalls(targets[], datas[]) → bytes[]`
- `doDelegateCall(target, data) → bytes`

---

## Strategies: Money Market Adapter

- Concepts: [../concepts/upmAndStrategies.md](../concepts/upmAndStrategies.md)
- Strategies Guide: [upm/docs/OrbtStrategiesGuide.md](upm/docs/OrbtStrategiesGuide.md)
- Base Interface: [upm/IBaseStrategy.sol](upm/IBaseStrategy.sol)
- Money Market Interface: [upm/IOrbtMMStrategy.sol](upm/IOrbtMMStrategy.sol)

Base strategy views & governance:
- `upm()`, `treasury()`, `feeBps()`, `principalOf(aToken, pocket) → amount`
- `executeGovernanceAction(actionType, payload) → bool`

Money Market operations:
- Supply/Withdraw: `supply(aToken, pocket, amount)`, `withdrawFromPocket(aToken, pocket, amount, to) → withdrawn`, `withdrawAllFromPocket(aToken, pocket, to) → withdrawn`
- Credit delegation: `approveDelegationFromPocketWithSig(...)`, `delegationFromPocketWithSig(...)`
- Repay: `repay(aToken, pocket, amount) → repaid`, `repayWithPermit(aToken, pocket, amount, deadline, v, r, s) → repaid`

---

## Staking Rewards

- Concepts: [../concepts/rewards.md](../concepts/rewards.md)
- Integration Guide: [rewards/docs/IntegrationGuide.md](rewards/docs/IntegrationGuide.md)
- Interface: [rewards/IStakingRewards.sol](rewards/IStakingRewards.sol)
 - Module README: [rewards/README.md](rewards/README.md)

Views & state:
- Tokens/roles: `rewardsToken()`, `stakingToken()`, `rewardsDistribution()`, `owner()`
- Schedule: `periodFinish()`, `rewardRate()`, `rewardsDuration()`
- Accounting: `lastUpdateTime()`, `rewardPerTokenStored()`, `userRewardPerTokenPaid(account)`, `rewards(account)`
- User views: `totalSupply()`, `balanceOf(account)`, `lastTimeRewardApplicable()`, `rewardPerToken()`, `earned(account)`, `getRewardForDuration()`

User actions:
- `stake(amount)`, `stake(amount, referral)`
- `withdraw(amount)`, `getReward()`, `exit()`

Admin/distributor:
- `notifyRewardAmount(reward)`
- `recoverERC20(token, amount)`
- `setRewardsDuration(duration)`
- `setRewardsDistribution(distributor)`

Events (selection): `RewardAdded`, `Staked`, `Referral`, `Withdrawn`, `RewardPaid`, `RewardsDurationUpdated`, `RewardsDistributionUpdated`, `Recovered`

---

Need deeper context? Start from the home page and concepts:
- Home: [../README.md](../README.md)
- Concepts: [../concepts/](../concepts/)


