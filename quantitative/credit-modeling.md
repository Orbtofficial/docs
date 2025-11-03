### Credit Modeling

`OrbtUCE` issues Ox inventory to allocators under a line-of-credit with daily caps and a global index for debt scaling. Repayments occur in underlying, fees are charged on repay, and debt reduces in Ox-equivalent.

#### State
- For allocator `a`:
  - `allowed`: boolean
  - `line = { ceiling, dailyCap, mintedToday, lastMintDay }`
  - `borrowFeeBps`: per-allocator repay fee in bps
  - `reservedOx`: Ox inventory reserved to allocator
  - `baseDebt`: un-indexed debt units
  - `debtEpoch`: allocator epoch vs global `wipeEpoch`
- Global:
  - `debtIndex` (RAY-style 1e18), starts at 1e18
  - `baseTotalDebt`
  - `wipeEpoch`

#### Effective Debt
- `effDebt(a) = (baseDebt(a) × debtIndex) / 1e18` if `debtEpoch(a) ≥ wipeEpoch`, else 0
- `totalEffDebt = (baseTotalDebt × debtIndex) / 1e18`

#### Mint (Credit)
- Preconditions: `allowed(a)`, `line.ceiling > 0`, `amount > 0`
- Daily bucket: reset at new UTC day; `mintedToday + amount ≤ dailyCap`
- Ceiling check: `effDebt(a) + amount ≤ ceiling`
- Effects:
  - **Mint `amount` 0xAssets directly to UCE contract** (assets remain in UCE custody, not transferred to allocator)
  - Increase `reservedOx(a)` and `totalReservedOx` (accounting entry for allocator's reserved inventory)
  - **Peg Integrity**: These minted 0xAssets can only leave UCE when users swap equivalent underlying assets, ensuring all 0xAssets in circulation are backed 1:1 by underlying in UCE
  - Increase `baseDebt(a)` and `baseTotalDebt` by `amount / debtIndex`
  - Emit `CreditMinted(a, amount)`

#### Repay (Underlying)
- Preconditions: `asset != Ox`, valid asset, amount > 0
- Pull underlying, compute `u_fee = amount × borrowFeeBps / 10_000` to `treasury`
- Principal: `u_principal = amount − u_fee`
- Convert to Ox-equivalent via decimals normalization: `ox_equiv = std18(u_principal)`
- Reduce effective debt by `repay_ox = min(ox_equiv, effDebt(a))`
- Convert to base: `baseRepay = (repay_ox × 1e18) / debtIndex`, clamp to `baseDebt(a)`
- Update `baseDebt(a)`, `baseTotalDebt`
- Emit `AllocatorRepaid(repayer, allocator, repay_ox)`

#### Pro-rata Draw on Protocol Sends
When routing Ox to users without a referral/allocator, protocol may draw reserved Ox pro-rata from allocators up to `min(reservedOx, effDebt)` and reduce their debts proportionally in base units.

#### Wipe Epoch
`wipeEpoch` marks the current global epoch; allocators with `debtEpoch < wipeEpoch` are masked to zero effective debt until touched (lazy wipe). Use governance to advance wipeEpoch during migrations.
