### UPM & Strategy Events

OrbitUPM orchestrates strategy calls under the `POCKET` role. Strategies emit detailed lifecycle events.

- OrbitUPM
  - Access-controlled execution; no native events for calls

- BaseStrategy
  - `TreasuryUpdated(address indexed treasury)`
  - `FeeBpsUpdated(uint256 feeBps)`

- OrbtMMStrategy
  - `Supplied(address indexed pocket, uint256 amount)`
  - `Withdrawn(address indexed pocket, address indexed to, uint256 amount)`
  - `Delegated(address indexed pocket, address indexed debtToken, address indexed delegatee, uint256 amount)`
