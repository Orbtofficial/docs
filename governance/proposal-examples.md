### Proposal Examples

Examples of common governance payloads.

#### Set Allocator Line and Borrow Fee
- Target: `OrbtUCE.executeGovernanceAction(ACT_SET_ALLOCATOR, payload)`
- Payload (ABI-encoded): `(op=SET_ALLOCATOR, init={allocator, allowed=true, line={ceiling, dailyCap, mintedToday=0, lastMintDay=now}, borrowFeeBps}, assets=[], pockets=[])`

#### Update Allocator Pocket
- Target: `OrbtUCE.executeGovernanceAction(ACT_SET_ALLOCATOR_POCKETS, payload)`
- Payload: `(allocator, asset, newPocket)`

#### Set sOx Rate
- Target: `sOxAsset.executeGovernanceAction(ACT_SET_RATE, abi.encode(newRateRay))`

#### Configure Rewards Stream
- Target: `sOxAsset.executeGovernanceAction(ACT_SET_REWARD_CONFIG, abi.encode(rewardToken, rewardVault, rewardRatePerSecond))`

#### Strategy Pocket Whitelist
- Target: `OrbtMMStrategy.executeGovernanceAction(ACT_WHITELIST_POCKET, abi.encode(pocket))`

#### Update Global Strategy Fee
- Target: `OrbtMMStrategy.executeGovernanceAction(ACT_SET_GLOBAL_FEE, abi.encode(feeBps))`
