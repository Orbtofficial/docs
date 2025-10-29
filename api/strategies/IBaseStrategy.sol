// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBaseStrategy
/// @notice Common interface exposed by ORBT strategy base implementations
interface IBaseStrategy {
    /// @notice UPM operator address authorized to call strategy functions
    function upm() external view returns (address);

    /// @notice ORBT treasury receiving protocol fees
    function treasury() external view returns (address);

    /// @notice Global fee on realized profit in basis points
    function feeBps() external view returns (uint256);

    /// @notice Return tracked principal for a pocket on a given market token
    /// @param aToken Interest-bearing token that identifies the market
    /// @param pocket Allocator address
    /// @return amount Current principal tracked
    function principalOf(address aToken, address pocket) external view returns (uint256 amount);

    /// @notice Governance action hook (see ORBTGovernance)
    /// @param actionType Action type identifier
    /// @param payload ABI-encoded payload for the action
    /// @return success True if the action was executed
    function executeGovernanceAction(bytes32 actionType, bytes calldata payload) external returns (bool success);
}
