### Economic Attacks

Threats and mitigations specific to UCE and the bridge.

#### Redemption-Induced Drain / Run Risk
- Attack: burst Ox→U redemptions to force liquidity pull from pockets
- Mitigations: dynamic redemption fee increases with volume; reserveBps retains on-hand U; per-asset pause

#### Oracle Manipulation / Staleness
- Attack: manipulate thin feeds or exploit staleness to bias U↔Ox pricing
- Mitigations: heartbeat freshness, fallbacks (usd/base), mint haircut, fail closed on anomalies

#### Referral Abuse / Allocator Imbalance
- Attack: route flows to drain specific allocator’s reservedOx
- Mitigations: pro-rata protocol draw path; referral validation; allocator-level monitoring and limits

#### Bridge Congestion / Cap Exhaustion
- Attack: saturate daily caps to deny service 
- Mitigations: per-tx/daily caps; priority queues via relayer agreements; per-route tuning and pause

#### Strategy Credit Delegation Misuse
- Attack: unauthorized borrow via signature replay/malleability
- Mitigations: EIP-712 signature expiry and domain verification; whitelist delegatees; monitor approvals
