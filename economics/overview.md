### Economic Overview

This document summarizes the economic levers in UCE, strategies, and bridge adapter.

#### Fee Sources
- UCE redemption fee (Ox→U): dynamic, 0–5% with decay and volume bump; fee paid in underlying
- UCE tin fee (U→Ox): per-asset bps in Ox; minted to treasury
- Allocator borrow fee: bps on repay (in underlying) before debt reduction
- Strategy performance fee: `feeBps` on realized interest withdrawn from Aave positions

#### Reserve Policy
- Portion of U received on U→Ox retained as reserve on-contract; remainder routed to pockets
- Reserves are consumed first on Ox→U outbound to minimize pocket dependency

#### Credit and Debt
- Allocators mint Ox inventory under ceiling/daily caps; debt tracked via `debtIndex`
- Repay in underlying reduces debt in Ox-equivalent; borrow fee collected first
- Protocol can draw reserved Ox pro-rata from allocators for protocol sends, reducing base debt proportionally

#### Revenue Distribution
- Treasury receives: redemption fees (underlying), tin fees (Ox minted), borrow fees (underlying), and strategy fees (underlying)
- Configurable via `setTreasury`; zero address disables fee routing for that operation
