### FAQ

Q: How do pauses work?
- Global `pause` blocks state-changing flows; per-asset `pauseAsset` blocks swaps/deposits/withdraws for that asset

Q: Which swaps are allowed?
- Only `Ox↔U` and `S↔Ox`; `U↔U` and `Ox↔Ox` are rejected

Q: How are fees applied?
- Ox→U: dynamic redemption fee in underlying
- U→Ox: tin fee in Ox, minted to treasury
- Allocator repay: fee skim in underlying

Q: How do allocators mint and repay?
- Mint Ox inventory up to daily cap/ceiling; repay in underlying to reduce debt

Q: What happens if an oracle is stale?
- Affected swaps revert; use per-asset pause or increase haircut until resolved
