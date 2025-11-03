### Glossary

- **ADMIN**: Privileged role in AccessControl for administrative actions
- **POCKET**: Role allowed to execute calls via UPM
- **UPM**: Unified Position Manager; orchestrates strategy calls
- **UCE**: Unified Collateral Engine; product of ORBT Protocol that handles 0x↔U and S↔0x swaps, credit lines
- **0xAssets** (also 0xAssets, 0xBTC, 0xETH, 0xUSD): Synthetic assets issued by ORBT Protocol. Generic term "0xAssets" refers to the family of synthetic assets including 0xBTC, 0xETH, 0xUSD, etc. "0x" is the naming prefix used consistently.
- **s0xAsset**: ERC4626 interest-bearing wrapper for 0xAssets
- **0x** (or **Ox** in code): Protocol 0x asset (18 decimals). The naming convention uses "0x" prefix for synthetic assets (0xBTC, 0xETH, 0xUSD). In code, may appear as "Ox" due to variable naming constraints.
- **OX**: Same as 0x/Ox, refers to synthetic assets. Used interchangeably but "0xAssets" is the preferred documentation term.
- **S-Asset**: ERC4626 wrapper whose `asset()` is a 0xAsset
- **Pocket**: Custody address used for asset routing (global or allocator-specific)
- **Base Debt**: Outstanding debt tracked directly in 0xAsset units per allocator. No index scaling is applied; debt equals the amount of 0xAssets minted via credit (minus repayments).
- **Wipe Epoch**: Global epoch marker for lazy debt wiping. Allocators with `debtEpoch < wipeEpoch` have their debt masked to zero until touched (credit mint/repay operations).
- **Tin**: U→0x mint fee (bps)
- **Redemption Fee**: 0x→U fee (dynamic, 0–5%)
