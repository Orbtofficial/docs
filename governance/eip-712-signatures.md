### EIP-712 Signatures

Current usage in the codebase:

- ERC20 Permit (EIP-2612) for approvals without prior transactions:
  - `AcrossUCEBridge.bridgeUnderlyingToChainWithPermit(...)` uses `IERC20Permit.permit`
  - `OrbtMMStrategy.repayWithPermit(...)` uses permit for the underlying asset

- Aave-style EIP-712 debt delegation:
  - `approveDelegationFromPocketWithSig` and `delegationFromPocketWithSig` permit delegation via signatures

Future governance signatures:
- If/when off-chain signed proposals are introduced, document the domain separator and typed data for action payloads, including chainId, verifying contract (governance), and replay protection (nonce/salt)
