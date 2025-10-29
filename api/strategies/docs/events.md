### Strategy Events (typical)

- `Supplied(address indexed pocket, uint256 amount)`
- `Withdrawn(address indexed pocket, address indexed to, uint256 amount)`
- `Delegated(address indexed pocket, address indexed debtToken, address indexed delegatee, uint256 amount)`
- `TreasuryUpdated(address indexed treasury)` (from base)
- `FeeBpsUpdated(uint256 feeBps)` (from base)
