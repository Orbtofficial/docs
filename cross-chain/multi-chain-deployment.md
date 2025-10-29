### Multi-Chain Deployment

Checklist for enabling new destination chains.

1) Deploy/identify destination UCE and Ox asset
2) Identify canonical underlying on destination and Across handler address
3) On source, `setRoute(dstChainId, uceDst, underlyingDst, handlerDst, perTxMax, dailyMax)`
4) Dry run with small amounts; validate handler ABI and message format
5) Rollout with conservative caps; monitor reverts and fill latencies
