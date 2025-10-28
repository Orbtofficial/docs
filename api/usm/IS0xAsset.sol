// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "openzeppelin-contracts/contracts/interfaces/IERC4626.sol";

/// @title ISOxAsset
/// @notice Integrator-facing interface for the sOxAsset yield-bearing vault (UUPS upgradeable).
/// @dev Extends ERC20 and ERC4626 semantics and adds sOxAsset-specific views and actions.
///
/// Key concepts for integrators:
/// - Shares (s0X) represent pro-rata claim on underlying assets; exchange rate grows over time.
/// - Exchange rate uses 27-decimal fixed-point (RAY). 1e27 = 1.0x.
/// - Interest accrues lazily; anyone can call `drip()` to synchronize state.
/// - Optional rewards stream (pre-funded) accrues to share holders; claim via `claim()`.
/// - Withdrawals can be rate-limited by `exitBufferBps`; redemptions respect an optional `minUnstakeDelay`.

/// @note Please install dependencies before using this interface using: `forge install OpenZeppelin/openzeppelin-contracts`
interface ISOxAsset is IERC20, IERC4626 {
    // ===== Events =====
    /// @notice Emitted when interest is accrued and, if enabled, underlying is minted to the vault.
    /// @param newExchangeRateRay New assets-per-share rate in RAY after accrual.
    /// @param mintedInterest Amount of underlying minted to the vault as interest (0 in rewards-only mode).
    event Drip(uint256 newExchangeRateRay, uint256 mintedInterest);

    /// @notice Emitted when the per-second interest factor is changed via governance.
    /// @param oldRateRay Previous per-second factor in RAY.
    /// @param newRateRay New per-second factor in RAY.
    event RateSet(uint256 oldRateRay, uint256 newRateRay);

    /// @notice Emitted when streaming rewards are accounted globally.
    /// @param newRewardIndexRay New global rewards-per-share index in RAY.
    /// @param rewards Amount of rewards accounted in this accrual window.
    /// @param dt Seconds elapsed since last rewards accrual.
    event RewardAccrued(uint256 newRewardIndexRay, uint256 rewards, uint256 dt);

    /// @notice Emitted when an account claims rewards.
    /// @param user The account that accrued rewards.
    /// @param to Recipient of the transferred rewards.
    /// @param amount Amount of rewards transferred.
    event RewardClaimed(address indexed user, address indexed to, uint256 amount);

    /// @notice Emitted when reward configuration changes (token, source vault, emission rate).
    event RewardConfigSet(address rewardToken, address rewardVault, uint256 rewardRatePerSecond);

    /// @notice Emitted when rewards-only mode is toggled (interest accrual pauses underlying mint).
    event RewardsOnlyModeSet(bool enabled);

    /// @notice Emitted when the minimum unstake delay is modified.
    event MinUnstakeDelaySet(uint256 oldDelay, uint256 newDelay);

    // ===== Core Views (sOxAsset-specific) =====
    /// @notice Underlying ERC20 token managed by the vault (equivalent to IERC4626::asset()).
    function underlyingAsset() external view returns (address);

    /// @notice Per-second interest growth factor in RAY. When > 1e27, exchangeRateRay grows over time.
    function rateRay() external view returns (uint256);

    /// @notice Current exchange rate (assets per 1 share) in RAY, last-synchronized value.
    function exchangeRateRay() external view returns (uint256);

    /// @notice Last timestamp when `exchangeRateRay` was updated.
    function lastAccrual() external view returns (uint256);

    /// @notice Get the up-to-date exchange rate without modifying state (computed off-chain safe).
    function previewExchangeRateRay() external view returns (uint256);

    // ===== Rewards Views =====
    /// @notice ORBT (or other) reward token address for emissions.
    function rewardToken() external view returns (address);

    /// @notice Pre-funded reward vault address from which rewards are transferred on claim.
    function rewardVault() external view returns (address);

    /// @notice Current reward emission rate in reward token units per second.
    function rewardRatePerSecond() external view returns (uint256);

    /// @notice Cumulative rewards-per-share index in RAY (last synchronized value).
    function rewardIndexRay() external view returns (uint256);

    /// @notice Last timestamp when the rewards index was updated.
    function lastRewardAccrual() external view returns (uint256);

    /// @notice Whether rewards-only mode is enabled (underlying interest minting paused, exchange rate frozen).
    function rewardsOnlyMode() external view returns (bool);

    /// @notice Returns current reward index including time since last accrual (view-only).
    function previewRewardIndexRay() external view returns (uint256);

    /// @notice View claimable rewards for an account if claimed now (includes pending index growth).
    function claimable(address account) external view returns (uint256);

    // ===== User Actions (sOxAsset-specific) =====
    /// @notice Accrue interest/rewards and, if enabled, mint underlying interest to the vault.
    /// @dev Anyone can call; returns the new exchange rate (RAY). Respects pause.
    function drip() external returns (uint256 newExchangeRateRay);

    /// @notice Claim rewards to a recipient. If `amount` is 0, claims full available.
    /// @return claimed The amount of rewards transferred.
    function claim(address to, uint256 amount) external returns (uint256 claimed);

    // ===== Exit Controls =====
    /// @notice Global exit buffer in basis points (1e4 = 100%) limiting per-tx withdrawals vs on-chain liquidity.
    function exitBufferBps() external view returns (uint256);

    /// @notice Minimum time a user must wait after receiving shares before they can withdraw/redeem.
    function minUnstakeDelay() external view returns (uint256);

    /// @notice Per-account earliest timestamp at which withdrawals/redeems are allowed (if delay set).
    function earliestUnstakeTime(address account) external view returns (uint256);
}

