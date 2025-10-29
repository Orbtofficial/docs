## ORBT Staking Rewards

Note on scope: This module is ONLY for staking the ORBT governance token. It is separate from USM/s0x vaults and does not stake 0xAssets. Governance may fund StakingRewards from protocol revenues, but accrual and mechanics here are independent of USM.

This guide explains how DeFi protocols can integrate with the ORBT Staking Rewards contract to enable staking ORBT and earning rewards. It documents the on-chain API, roles, flows, caveats, and best practices so your integration is safe and reliable.

### Overview

- **Staking token**: ORBT (ERC-20)
- **Reward token**: Configurable ERC-20 (can be ORBT or a different token)
- **Model**: Synthetix-style rewards streamed linearly over a fixed `rewardsDuration` at `rewardRate`
- **Referral**: Optional 16-bit code emitted in an event for off-chain analytics (no on-chain effect)

### Roles & Permissions

- **Owner**: Can set `rewardsDuration`, update `rewardsDistribution`, and recover non-staking ERC-20s.
- **RewardsDistribution**: Authorized to call `notifyRewardAmount(reward)` to start/extend reward periods.
- **Users/Integrators**: Stake ORBT, withdraw, and claim rewards.

### Token Requirements & Assumptions

- The staking token SHOULD be a standard ERC-20 without transfer fees. Fee-on-transfer tokens can cause accounting mismatches because staking credits the requested `amount`.
- Rewards accrue using a 1e18 scaling factor for precision; staking token decimals do not need to be 18.

### Public API (ABIs) 
source: [IStakingRewards](../IStakingRewards.sol)

All function and event signatures are defined in `IStakingRewards.sol` and available in your build artifacts. Key interfaces:

#### View Functions

- `function rewardsToken() external view returns (IERC20)`
- `function stakingToken() external view returns (IERC20)`
- `function rewardsDistribution() external view returns (address)`
- `function owner() external view returns (address)`
- `function periodFinish() external view returns (uint256)`
- `function rewardRate() external view returns (uint256)`
- `function rewardsDuration() external view returns (uint256)`
- `function lastUpdateTime() external view returns (uint256)`
- `function rewardPerTokenStored() external view returns (uint256)`
- `function userRewardPerTokenPaid(address) external view returns (uint256)`
- `function rewards(address) external view returns (uint256)`
- `function totalSupply() external view returns (uint256)`
- `function balanceOf(address) external view returns (uint256)`
- `function lastTimeRewardApplicable() external view returns (uint256)`
- `function rewardPerToken() external view returns (uint256)`
- `function earned(address) external view returns (uint256)`
- `function getRewardForDuration() external view returns (uint256)`

#### User Actions

- `function stake(uint256 amount) external`
- `function stake(uint256 amount, uint16 referral) external`
- `function withdraw(uint256 amount) external`
- `function getReward() external`
- `function exit() external`

#### Admin/Distributor

- `function notifyRewardAmount(uint256 reward) external` (callable by `rewardsDistribution`)
- `function recoverERC20(address token, uint256 amount) external` (owner)
- `function setRewardsDuration(uint256 duration) external` (owner)
- `function setRewardsDistribution(address distributor) external` (owner)

#### Events

- `event RewardAdded(uint256 reward)`
- `event Staked(address indexed user, uint256 amount)`
- `event Referral(uint16 indexed referral, address indexed user, uint256 amount)`
- `event Withdrawn(address indexed user, uint256 amount)`
- `event RewardPaid(address indexed user, uint256 reward)`
- `event RewardsDurationUpdated(uint256 newDuration)`
- `event RewardsDistributionUpdated(address newRewardsDistribution)`
- `event Recovered(address token, uint256 amount)`

### Integration Flows

#### 1) Staking ORBT

1. Ensure the user/protocol has ORBT and has approved the StakingRewards contract to spend at least `amount`.
2. Call `stake(amount)` or `stake(amount, referral)`.
3. Listen for `Staked` (and `Referral`, if used).

Edge cases:
- `amount == 0` reverts with "Cannot stake 0".
- If the token is fee-on-transfer, staked accounting can be inconsistent. Use standard ERC-20s.

#### 2) Withdrawing Staked ORBT

1. Call `withdraw(amount)`.
2. Listen for `Withdrawn`.

Edge cases:
- `amount == 0` reverts with "Cannot withdraw 0".
- Withdrawing does not automatically claim rewards; call `getReward` or `exit`.

#### 3) Claiming Rewards

1. Call `getReward()` to transfer accrued rewards.
2. Listen for `RewardPaid`.

#### 4) Exit (Withdraw All + Claim)

1. Call `exit()` to withdraw full staked balance and claim rewards in one action.

### Reading Accrual & State

- Use `earned(account)` to display current claimable rewards.
- Use `balanceOf(account)` for staked balance.
- Use `rewardPerToken()` and `lastTimeRewardApplicable()` to compute real-time accrual off-chain if needed.
- `getRewardForDuration()` provides the total reward scheduled for the current period.

### Rewards Scheduling

- `notifyRewardAmount(reward)` sets/extends a reward period. If called mid-period, leftover rewards roll into the new period.
- The implementation enforces `rewardRate <= rewardsToken.balanceOf(this) / rewardsDuration` to ensure solvency.

### Non-Reentrancy

- `stake`, `withdraw`, and `getReward` are non-reentrant in the reference implementation. Do not re-enter them via hooks.

### Access Control & Governance

- Owner responsibilities: set durations, rotate distributor, recover non-staking tokens.
- Distributor responsibilities: fund and notify reward schedules.

### Error Messages (Common)

- `"Cannot stake 0"` — Stake amount was zero.
- `"Cannot withdraw 0"` — Withdraw amount was zero.
- `"Caller is not owner"` — Admin-only function called by non-owner.
- `"Caller is not RewardsDistribution contract"` — Distributor-only function violation.
- `"Provided reward too high"` — Insufficient reward token backing for requested schedule.
- `"Cannot withdraw the staking token"` — Attempted to recover the staking token via `recoverERC20`.

### Example: Solidity (Using the Interface)

```solidity
pragma solidity ^0.8.20;

import {IStakingRewards} from "./IStakingRewards.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StrategyExample {
    IStakingRewards public immutable staking;
    IERC20 public immutable orbt;

    constructor(address staking_, address orbt_) {
        staking = IStakingRewards(staking_);
        orbt = IERC20(orbt_);
    }

    function deposit(uint256 amount, uint16 referral) external {
        orbt.transferFrom(msg.sender, address(this), amount);
        orbt.approve(address(staking), amount);
        staking.stake(amount, referral);
    }

    function claim() external {
        staking.getReward();
    }

    function withdraw(uint256 amount) external {
        staking.withdraw(amount);
        orbt.transfer(msg.sender, amount);
    }
}
```

### Example: TypeScript (ethers)

```ts
import { Contract, parseUnits } from "ethers";

const staking = new Contract(STAKING_REWARDS_ADDRESS, IStakingRewardsABI, signer);
const orbt = new Contract(ORBT_ADDRESS, IERC20_ABI, signer);

// Stake 100 ORBT
const amount = parseUnits("100", 18);
await (await orbt.approve(staking.target, amount)).wait();
await (await staking.stake(amount)).wait();

// Read earned
const earned = await staking.earned(await signer.getAddress());

// Claim
await (await staking.getReward()).wait();
```

### Indexing & Analytics

- Index `Staked`, `Withdrawn`, `RewardPaid`, and `Referral` for dashboards.
- Use `RewardsDurationUpdated` and `RewardsDistributionUpdated` for governance change logs.

### Testing Your Integration

- Unit test stake/withdraw/claim flows.
- Simulate mid-period `notifyRewardAmount` updates.
- Verify behavior when `totalSupply == 0` (no accrual) and around `periodFinish`.

### Security & Best Practices

- Avoid fee-on-transfer staking tokens.
- Never assume rewards are funded until `notifyRewardAmount` succeeds.
- Handle reverts gracefully; surface meaningful messages to users.
- Consider using `exit()` for simple integrations to reduce edge cases.

---

For full ABI, import `IStakingRewards.sol` or consume the compiled artifact from your build system.

See also:
- Module README: `../README.md`
- Rewards concepts and revenue sources: `../../../concepts/rewards.md`


