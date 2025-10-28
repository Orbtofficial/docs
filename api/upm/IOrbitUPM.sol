// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IOrbitUPM
/// @notice Orchestrator interface for routing single and batch calls from whitelisted pockets
interface IOrbitUPM {
    /// @notice Role constant for pocket callers
    /// @return role Keccak-256 hash of "POCKET"
    function POCKET() external view returns (bytes32 role);

    /// @notice Execute a single low-level call
    /// @param target Destination contract to call
    /// @param data ABI-encoded function selector and arguments
    /// @return result ABI-encoded return data from the call
    function doCall(address target, bytes calldata data) external returns (bytes memory result);

    /// @notice Execute multiple low-level calls atomically
    /// @param targets Destination contracts to call
    /// @param datas ABI-encoded function selectors and arguments for each call
    /// @return results ABI-encoded return data for each call
    function doBatchCalls(address[] calldata targets, bytes[] calldata datas) external returns (bytes[] memory results);

    /// @notice Execute a delegatecall to a target contract
    /// @param target Destination contract to delegatecall into
    /// @param data ABI-encoded function selector and arguments
    /// @return result ABI-encoded return data from the delegatecall
    function doDelegateCall(address target, bytes calldata data) external returns (bytes memory result);
}
