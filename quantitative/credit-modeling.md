### Credit Modeling

`OrbtUCE` issues 0xAssets inventory to allocators under a line-of-credit with daily caps. Debt is tracked directly in 0xAsset units (no index scaling). Repayments occur in underlying, fees are charged on repay, and debt reduces in 0x-equivalent.

#### State
- For allocator `a`:
  - `allowed`: boolean
  - `line = { ceiling, dailyCap, mintedToday, lastMintDay }`
  - `borrowFeeBps`: per-allocator repay fee in bps
  - `reservedZeroX`: 0xAssets inventory reserved to allocator (minted to UCE, remains in UCE custody)
  - `baseDebt`: outstanding debt in 0xAsset units (direct tracking, no scaling)
  - `debtEpoch`: allocator epoch vs global `wipeEpoch`
- Global:
  - `baseTotalDebt`: sum of all allocator `baseDebt` values
  - `wipeEpoch`: current global epoch; allocators with `debtEpoch < wipeEpoch` have debt masked to 0 until touched

#### Debt Calculation
- `allocatorDebt(a) = baseDebt(a)` if `debtEpoch(a) ≥ wipeEpoch`, else `0`
- Debt is tracked directly in 0xAsset units; no index scaling is applied
- `totalAllocatorDebt() = baseTotalDebt` (sum of all allocators' baseDebt in current epoch)

#### Mint (Credit)
- Preconditions: `allowed(a)`, `line.ceiling > 0`, `amount > 0`
- Daily bucket: reset at new UTC day; `mintedToday + amount ≤ dailyCap`
- Ceiling check: `allocatorDebt(a) + amount ≤ ceiling`
- Effects:
  - **Mint `amount` 0xAssets directly to UCE contract** (assets remain in UCE custody, not transferred to allocator)
  - Increase `reservedZeroX(a)` by `amount` and `totalReservedZeroX` by `amount`
  - **Peg Integrity**: These minted 0xAssets can only leave UCE when users swap equivalent underlying assets, ensuring all 0xAssets in circulation are backed 1:1 by underlying in UCE
  - If `debtEpoch(a) < wipeEpoch`, reset `baseDebt(a) = 0` and set `debtEpoch(a) = wipeEpoch`
  - Increase `baseDebt(a)` by `amount` and `baseTotalDebt` by `amount`
  - Update `line.mintedToday` to `newMintedToday`
  - Emit `CreditMinted(a, amount)`

#### Repay (Underlying)
- Preconditions: `asset != 0xAsset`, valid asset, amount > 0
- Pull underlying from allocator to UCE contract
- Compute borrow fee: `u_fee = amount × borrowFeeBps / 10_000`, send to `treasury`
- Principal: `u_principal = amount − u_fee`
- Convert to 0x-equivalent via decimals normalization: `ox_equiv = _toStd18(asset, u_principal)`
- Current debt: `currentDebt = allocatorDebt(a)`
- Repay amount: `repay_ox = min(ox_equiv, currentDebt)`
- If `repay_ox == 0`, return early (no-op)
- `baseRepay = repay_ox` (no index scaling; directly reduces baseDebt)
- Clamp: `baseRepay = min(baseRepay, baseDebt(a))`
- Update: `baseDebt(a) -= baseRepay`, `baseTotalDebt -= baseRepay` (clamped to prevent underflow)
- Emit `AllocatorRepaid(repayer, allocator, repay_ox)`

#### Pro-rata Draw on Protocol Sends
When routing 0xAssets to users without a referral/allocator, protocol may draw reserved 0xAssets pro-rata from allocators up to `min(reservedZeroX, baseDebt)` and reduce their debts proportionally. Debt reduction is: `baseRepay = takeZeroX` (clamped to `baseDebt(a)`).

#### Wipe Epoch
`wipeEpoch` marks the current global epoch; allocators with `debtEpoch < wipeEpoch` are masked to zero debt until touched (lazy wipe mechanism). When an allocator is touched (credit mint/repay), if `debtEpoch < wipeEpoch`, their `baseDebt` is reset to 0 and `debtEpoch` is updated to current `wipeEpoch`. Use governance to advance `wipeEpoch` during migrations or debt wipes.
