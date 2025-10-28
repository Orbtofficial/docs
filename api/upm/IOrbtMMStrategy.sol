// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IOrbtMMStrategy
/// @notice Public interface for ORBT Money Market strategy adapter
interface IOrbtMMStrategy {
    /// @notice Supply underlying by pulling from pocket and depositing on their behalf
    /// @param aToken Interest-bearing token identifying the market
    /// @param pocket Allocator address (onBehalfOf)
    /// @param amount Amount of underlying to supply
    function supply(address aToken, address pocket, uint256 amount) external;

    /// @notice Withdraw underlying by pulling aTokens from pocket, applying fee on profit
    /// @param aToken Interest-bearing token identifying the market
    /// @param pocket Allocator address
    /// @param amount Underlying amount to withdraw
    /// @param to Recipient of net withdrawn amount
    /// @return withdrawn Actual amount withdrawn from the market
    function withdrawFromPocket(address aToken, address pocket, uint256 amount, address to) external returns (uint256 withdrawn);

    /// @notice Withdraw entire aToken balance from pocket
    /// @param aToken Interest-bearing token identifying the market
    /// @param pocket Allocator address
    /// @param to Recipient of net withdrawn amount
    /// @return withdrawn Actual amount withdrawn
    function withdrawAllFromPocket(address aToken, address pocket, address to) external returns (uint256 withdrawn);

    /// @notice Relay signature to approve credit delegation from pocket to delegatee
    /// @param debtToken Variable debt token for market
    /// @param pocket Delegator address
    /// @param delegatee Borrower address
    /// @param amount Allowance amount
    /// @param deadline Permit deadline
    /// @param v ECDSA v
    /// @param r ECDSA r
    /// @param s ECDSA s
    function approveDelegationFromPocketWithSig(
        address debtToken,
        address pocket,
        address delegatee,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// @notice Relay alternative signature scheme for credit delegation
    function delegationFromPocketWithSig(
        address debtToken,
        address pocket,
        address delegatee,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// @notice Repay variable debt on behalf of pocket using payer funds
    /// @param aToken Interest-bearing token identifying the market
    /// @param pocket Debtor address
    /// @param amount Repay amount in underlying
    /// @return repaid Actual amount repaid
    function repay(address aToken, address pocket, uint256 amount) external returns (uint256 repaid);

    /// @notice Repay variable debt on behalf of pocket using EIP-2612 permit
    /// @param aToken Interest-bearing token identifying the market
    /// @param pocket Debtor address
    /// @param amount Repay amount
    /// @param deadline Permit deadline
    /// @param v ECDSA v
    /// @param r ECDSA r
    /// @param s ECDSA s
    /// @return repaid Actual repaid amount
    function repayWithPermit(
        address aToken,
        address pocket,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 repaid);
}
