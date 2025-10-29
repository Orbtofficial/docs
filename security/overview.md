### Security Overview

Defense-in-depth controls span access control, pausing, oracle verification, and cross-chain circuit breakers.

- Access control:
  - `ADMIN` on UCE/sOx; `owner` on bridge/strategies; `POCKET` on UPM; governance-only hooks where present

- Pausability:
  - Global `whenNotPaused`; per-asset pause guards on UCE swap/deposit/withdraw; bridge-level pause

- Reentrancy:
  - NonReentrant on UCE external state-changing calls and bridge entry points; strategies guard user-facing calls

- Upgrades (UUPS):
  - Explicit auth hooks (`onlyRole(ADMIN)` / `onlyOwner`); plan upgrades via governance + timelock

- Oracle robustness:
  - Heartbeat freshness enforcement; price normalization; disabled or stale feeds fail closed

- Cross-chain safety:
  - Per-tx and daily caps; explicit route registry; message encoding limited to approve+swap on destination

- Zero-custody strategies:
  - Strategy owner is UPM; no leftover token dust checks after operations; treasury fee skim on realized profit
