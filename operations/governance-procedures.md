### Governance Procedures

#### Normal Changes
1) Draft proposal with clear intent and parameters
2) Security review and risk notes (oracle, liquidity, credit limits)
3) Queue via timelock; notify community
4) Execute after delay; verify effects and monitor

Common actions:
- UCE: set tin bps, reserve bps, oracles, allocators (lines/fees/pockets)
- Bridge: set routes, update caps, pause/unpause
- Strategies: set treasury/fees, pocket whitelist changes

#### Emergency Changes
- Global pause or per-asset pause on UCE
- Set bridge caps to zero
- Disable specific oracles or set haircut high
- Incident response workflow triggers (see incident-response)
