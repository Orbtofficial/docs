// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @note Please install dependencies before using this interface using: `forge install OpenZeppelin/openzeppelin-contracts`

/**
 * @title IStakingRewards
 * @notice Interface for the ORBT Staking Rewards contract.
 * @dev This interface exposes the complete on-chain external API for integrators
 *      and other contracts to interact with a StakingRewards implementation.
 *      It intentionally includes all public/external functions and events, along
 *      with view getters for the public state variables that Solidity auto-generates.
 *
 *      Key behaviors of the reference implementation (not enforced by this interface):
 *        - Rewards are streamed linearly at `rewardRate` over `rewardsDuration`.
 *        - Accrual is tracked via `rewardPerToken` scaled by 1e18.
 *        - `stake`, `withdraw`, and `getReward` are non-reentrant in the reference
 *          implementation; batching should account for this.
 *        - Referral support is off-chain analytics only via the `Referral` event; it has
 *          no effect on reward calculation.
 *        - The staking token SHOULD be a standard ERC-20 without transfer fees. Fee-on-
 *          transfer tokens can cause balance/accounting mismatches because the contract
 *          credits stake by the requested `amount`.
 */
interface IStakingRewards {
    /* ========== EVENTS ========== */

    /**
     * @notice Emitted when new rewards are added to the schedule.
     * @param reward The amount of reward tokens added to the new or extended period.
     */
    event RewardAdded(uint256 reward);

    /**
     * @notice Emitted when a user stakes staking tokens.
     * @param user The account that staked.
     * @param amount The amount of staking tokens deposited.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @notice Emitted to record an optional referral when staking.
     * @dev Purely for off-chain analytics; does not change accounting.
     * @param referral A 16-bit referral code supplied by the staker.
     * @param user The account that staked.
     * @param amount The amount of staking tokens deposited.
     */
    event Referral(uint16 indexed referral, address indexed user, uint256 amount);

    /**
     * @notice Emitted when a user withdraws staking tokens.
     * @param user The account that withdrew.
     * @param amount The amount of staking tokens returned.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @notice Emitted when a user claims reward tokens.
     * @param user The account that claimed.
     * @param reward The amount of reward tokens sent to the user.
     */
    event RewardPaid(address indexed user, uint256 reward);

    /**
     * @notice Emitted when the rewards duration is changed by the owner.
     * @param newDuration The new duration in seconds.
     */
    event RewardsDurationUpdated(uint256 newDuration);

    /**
     * @notice Emitted when the rewards distribution address is changed by the owner.
     * @param newRewardsDistribution The new rewards distribution address.
     */
    event RewardsDistributionUpdated(address newRewardsDistribution);

    /**
     * @notice Emitted when the owner recovers an arbitrary ERC-20 token from the contract.
     * @param token The token address recovered (cannot be the staking token).
     * @param amount The amount of tokens recovered.
     */
    event Recovered(address token, uint256 amount);

    /* ========== IMMUTABLES & CORE STATE (GETTERS) ========== */

    /**
     * @notice The token distributed as rewards.
     */
    function rewardsToken() external view returns (IERC20);

    /**
     * @notice The token that users deposit to earn rewards.
     */
    function stakingToken() external view returns (IERC20);

    /**
     * @notice Address authorized to call `notifyRewardAmount`.
     */
    function rewardsDistribution() external view returns (address);

    /**
     * @notice The owner address with admin privileges.
     */
    function owner() external view returns (address);

    /**
     * @notice Timestamp at which the current reward period ends.
     */
    function periodFinish() external view returns (uint256);

    /**
     * @notice Current per-second reward emission rate.
     */
    function rewardRate() external view returns (uint256);

    /**
     * @notice Duration of a reward period, in seconds.
     */
    function rewardsDuration() external view returns (uint256);

    /**
     * @notice Last timestamp the reward accounting was updated.
     */
    function lastUpdateTime() external view returns (uint256);

    /**
     * @notice Stored reward-per-token accumulator (scaled by 1e18).
     */
    function rewardPerTokenStored() external view returns (uint256);

    /**
     * @notice Per-account checkpoint of reward-per-token paid (scaled by 1e18).
     * @param account The account to query.
     */
    function userRewardPerTokenPaid(address account) external view returns (uint256);

    /**
     * @notice Unclaimed reward amount for an account (checkpointed storage).
     * @param account The account to query.
     */
    function rewards(address account) external view returns (uint256);

    /* ========== VIEWS ========== */

    /**
     * @notice Total amount of staking tokens deposited.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Staked balance of a given account.
     * @param account The account to query.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Returns the timestamp used for reward accrual calculation: `min(block.timestamp, periodFinish)`.
     */
    function lastTimeRewardApplicable() external view returns (uint256);

    /**
     * @notice Returns the current reward-per-token accumulator (scaled by 1e18).
     * @dev Increases with time while rewards are active and total supply > 0.
     */
    function rewardPerToken() external view returns (uint256);

    /**
     * @notice Computes the accrued but unclaimed rewards for an account.
     * @param account The account to query.
     */
    function earned(address account) external view returns (uint256);

    /**
     * @notice Returns `rewardRate * rewardsDuration` for the current schedule.
     */
    function getRewardForDuration() external view returns (uint256);

    /* ========== MUTATIVE FUNCTIONS (USER) ========== */

    /**
     * @notice Stake `amount` of staking tokens to start earning rewards.
     * @dev Requires prior ERC-20 approval to this contract for at least `amount`.
     *      Emits {Staked}.
     * @param amount The number of staking tokens to deposit.
     */
    function stake(uint256 amount) external;

    /**
     * @notice Stake `amount` of staking tokens and optionally emit a referral code.
     * @dev Functionally identical to `stake(amount)` but also emits {Referral}.
     *      The referral has no on-chain effect on rewards or balances.
     * @param amount The number of staking tokens to deposit.
     * @param referral A 16-bit referral code for off-chain attribution.
     */
    function stake(uint256 amount, uint16 referral) external;

    /**
     * @notice Withdraw `amount` of previously staked tokens.
     * @dev Emits {Withdrawn}.
     * @param amount The number of staking tokens to withdraw.
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice Claim any accrued reward tokens.
     * @dev Emits {RewardPaid} if a non-zero amount is claimed.
     */
    function getReward() external;

    /**
     * @notice Convenience function to withdraw full staked balance and claim rewards.
     * @dev Effectively `withdraw(balanceOf(msg.sender)); getReward();`.
     */
    function exit() external;

    /* ========== RESTRICTED FUNCTIONS (ADMIN / DISTRIBUTOR) ========== */

    /**
     * @notice Notify the contract about a new reward amount to stream over `rewardsDuration`.
     * @dev Access: SHOULD be restricted to `rewardsDistribution` in the implementation.
     *      Will typically roll leftover rewards into the new schedule if called mid-period.
     *      Emits {RewardAdded}.
     * @param reward The amount of reward tokens to distribute over the next period.
     */
    function notifyRewardAmount(uint256 reward) external;

    /**
     * @notice Recover arbitrary ERC-20 tokens mistakenly sent to the contract (except the staking token).
     * @dev Access: SHOULD be restricted to `owner` in the implementation.
     *      Emits {Recovered}.
     * @param tokenAddress The token to recover.
     * @param tokenAmount The amount of tokens to recover.
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

    /**
     * @notice Set a new rewards duration, optionally re-scheduling the current period.
     * @dev Access: SHOULD be restricted to `owner` in the implementation.
     *      Emits {RewardsDurationUpdated}.
     * @param _rewardsDuration The new duration in seconds.
     */
    function setRewardsDuration(uint256 _rewardsDuration) external;

    /**
     * @notice Set a new rewards distribution address.
     * @dev Access: SHOULD be restricted to `owner` in the implementation.
     *      Emits {RewardsDistributionUpdated}.
     * @param _rewardsDistribution The new distributor address.
     */
    function setRewardsDistribution(address _rewardsDistribution) external;
}


