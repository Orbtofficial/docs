# UCE

> This page documents **how to integrate swaps** with UCE for all three planes:
>
> * **Underlying → 0xAssets** (minting 0xAssets from underlyings)
    abbreviation: U → 0x
> * **OxAssets → Underlying** (redemption)
    abbreviation: 0x → U
> * **OxAssets ↔ s0xAsset** (staking-share conversions via ERC-4626)
>
> It also covers **referral vs. non-referral** origination and **all fees** that can apply.

---

## 1) API 
This guide covers swaps in the Unified Collateral Engine (UCE) across three paths: Underlying (U) ⇄ 0xAssets (0x) for mint/redemption, and 0x ⇄ s0xAssets (s0x) for ERC-4626 staking-share conversions. 0x are 18-dec synthetic assets (e.g., 0xUSD, 0xBTC); s0x are vault shares whose value follows the ERC-4626 exchange rate.
 Allocators are permissioned liquidity partners; their referral codes route U inflows to the allocator’s pocket and consume that allocator’s reserved OX first. 

Underlying → 0x uses oracle pricing (with optional mint haircut) and applies tinBps (fee in 0x to treasury). 0x → U applies a dynamic redemption fee (snapshotted at execution; rises with pressure, decays over time).
 0x ⇄ s0x is oracle-free and fee-free at UCE (yield comes from the vault’s rate). 
 
**Swap using ORBT's swapping interface**

```javascript
function swapExactIn(
  address assetIn,
  address assetOut,
  uint256 amountIn,
  address receiver,
  uint256 referralCode
) external returns (uint256 amountOut);

function swapExactOut(
  address assetIn,
  address assetOut,
  uint256 amountOut,
  uint256 maxAmountIn,
  address receiver,
  uint256 referralCode
) external returns (uint256 amountIn);
```

**Previews (strongly recommended for UI & slippage control)**

```javascript
function previewSwapExactIn(address assetIn, address assetOut, uint256 amountIn)
  external view returns (uint256 amountOut);

function previewSwapExactOut(address assetIn, address assetOut, uint256 amountOut)
  external view returns (uint256 amountIn);
```

**Helpful read-only utilities**

```javascript
// Family base discovery & routing context
function assetFamilies(address asset) external view returns (AssetFamily); // e.g., BTC/ETH/USD
function pockets(address asset) external view returns (address);           // global pocket set for the asset

// Unit conversions (18-dec OX ↔ native decimals of U)
function convertToOxAssets(address asset, uint256 assets) external view returns (uint256);
function convertToAssets(address asset, uint256 numOxAssets) external view returns (uint256);

/// tinBps per underlying asset is stored in AssetCfg (exposed via events/config UIs)
/// dynamic redemption fee is time-varying; preview methods already account for it
```

**Events for analytics**

```javascript
event Swap(address indexed assetIn, address indexed assetOut, address sender,
           address indexed receiver, uint256 amountIn, uint256 amountOut, uint256 referralCode);
```

**Token approvals you’ll need (per path)**

* **U → OX**: `IERC20(assetIn).approve(UCE, amountIn)`
* **OX → U**: `IERC20(ox).approve(UCE, amountIn)` (for `swapExactIn`) or `maxAmountIn` (for `swapExactOut`)
* **OX → S**: `IERC20(ox).approve(UCE, amountIn)`
* **S → OX**: `IERC20(s0x).approve(UCE, shares)` (shares are ERC-4626 shares)

---

## 2) Swap Planes & How To Integrate

### A) Underlying → OX (Minting)

**What it does**

* Pulls **U** from user, splits by **reserveBps** (on-hand buffer vs. pocket), computes OX via **oracle pricing** (+ optional mint haircut), then applies **tinBps** fee (OX minted to treasury). User receives **net OX**.

**Fees**

* **`tinBps` (per-asset mint fee, in OX):** Deducted from OX out; minted to `treasury`.
* **No redemption fee here.**

**Referral behavior**

* **With referralCode ≠ 0**:

  * Inbound **U** is routed to the **allocator’s pocket**.
  * **OX out must come from the referrer’s `reservedOx`**. If insufficient, **tx reverts**.
* **Without referral (referralCode = 0)**:

  * OX out settles from **unreserved protocol inventory**, then **pro-rata allocator inventory** (reserved 0xAssets that allocators minted to UCE via credit - these remain in UCE and only enter circulation when users swap equivalent underlying, maintaining peg integrity), then **mints shortfall** if needed.

**How to call**

```javascript
// 1) Show quote to user
uint256 oxOut = UCE.previewSwapExactIn(U, OX, amountU);

// 2) Approve & swap
IERC20(U).approve(address(UCE), amountU);
uint256 received = UCE.swapExactIn(U, OX, amountU, user, referralCode);
```

**Notes**

* **Decimal safety**: UCE handles decimals normalization; OX is always 18-decimals.
* **Oracle requirements**: If oracle is stale/disabled for the asset, the call reverts.
* **Asset pause**: If either side is paused, the call reverts.

---

### B) OX → Underlying (Redemption)

**What it does**

* Pulls **OX** from user; computes **snapshot redemption fee rate**; delivers **U** using on-hand reserve first, then **allowance-bounded pocket withdrawal** (referral pocket if provided, else global pocket). Transfers fee to treasury in **U** and **bumps** the dynamic redemption rate post-settlement.

**Fees**

* **Dynamic redemption fee (time-varying):**

  * **Preview-consistent**: UCE snapshots the fee rate at start; previews match execution.
  * Increases with redemption pressure (fraction of OX redeemed vs. supply) and **decays over time**.

**Referral behavior**

* **With referralCode ≠ 0**: U is pulled from the **referrer’s pocket** (subject to pocket allowance & balance).
* **Without referral**: UCE uses **global context** (on-hand + global pocket).

  * If pocket allowance is insufficient, the call reverts (`InsufficientPocketLiquidity`).

**How to call**

```javascript
// Exact-in: user knows OX in
uint256 uOut = UCE.previewSwapExactIn(OX, U, oxIn); // net of current redemption fee (snapshotted on exec)
IERC20(OX).approve(address(UCE), oxIn);
uint256 receivedU = UCE.swapExactIn(OX, U, oxIn, user, referralCode);

// Exact-out: user wants specific U out
uint256 oxNeeded = UCE.previewSwapExactOut(OX, U, targetU); // includes fee at snapshot rate
IERC20(OX).approve(address(UCE), oxNeeded);
uint256 paidOx = UCE.swapExactOut(OX, U, targetU, oxNeeded, user, referralCode); // reverts if > max
```

**Notes**

* **Allocators cannot redeem OX→U** (they must settle in underlying); allocator callers to OX→U revert.
* **Pocket allowance**: Ensure the pocket (global or referrer’s) has approved UCE; otherwise redemption may fail.

---

### C) OX ↔ S (ERC-4626 staking shares)

**What it does**

* **OX → S**: UCE deposits OX into the s-vault (`IERC4626(assetOut).deposit`) and mints **shares** (S) to receiver.
* **S → OX**: UCE redeems shares (`IERC4626(assetIn).redeem`) for **OX** to receiver.
* This is **oracle-free** and **fee-free** at UCE level (vault may accrue yield via exchange rate).

**Fees**

* **No UCE fee on OX↔S.** Exchange rate is determined by the ERC-4626 vault.

**How to call**

```javascript
// OX -> S (stake)
uint256 shares = UCE.previewSwapExactIn(OX, S0X, oxIn);
IERC20(OX).approve(address(UCE), oxIn);
uint256 mintedShares = UCE.swapExactIn(OX, S0X, oxIn, user, 0);

// S -> OX (unstake)
uint256 oxOut = UCE.previewSwapExactIn(S0X, OX, sharesIn);
IERC20(S0X).approve(address(UCE), sharesIn);
uint256 receivedOx = UCE.swapExactIn(S0X, OX, sharesIn, user, 0);
```

**Notes**

* For exact-out variants, use `previewSwapExactOut` and pass `maxAmountIn` guards.
* The **S↔OX exchange** depends on the **ERC-4626 exchange rate** (`convertToShares` / `convertToAssets`).

---

## 3) Referral vs Non-Referral
- A. Behavior at a Glance
Referral flow (referralCode != 0): U inflows route to the referrer’s Pocket; 0x outflows must be served from the referrer’s reservedOx (else revert). 0x→U pulls U from the referrer’s Pocket (subject to allowance/balance).
Non-referral (referralCode = 0): U inflows follow global routing; 0x outflows first use unreserved protocol inventory, then pro-rata allocator inventory, minting shortfalls only as designed. 0x→U pulls from on-hand reserve + global Pocket.
See the full reference for edge cases, invariants, and examples: Referral vs Non-Referral
- B. Integration Checklist
Always pass the correct referralCode (use 0 if none).
For referral redemptions, ensure the referrer’s Pocket maintains ERC-20 allowance to UCE and has sufficient balance.
Fees: U→0x applies tinBps (in 0x) regardless of referral; 0x→U applies the dynamic redemption fee equally—referral only affects liquidity source, not the fee math.

| Origination       | U → OX (mint)                                                                                  | OX → U (redeem)                                                     |
| ----------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **With referral** | Underlying routed to allocator pocket; 0x must come from allocator's reservedOx (else revert). | Underlying pulled **from referrer’s pocket** (subject to allowance/balance). |
| **No referral**   | OxAssets from **unreserved portion of 0xAssets in UCE by protocol** → **pro-rata allocator reserved inventory** (minted by allocators to UCE, remaining in UCE until swapped with equivalent underlying) → **mint shortfall**.            | Underlying from **on-hand reserve**, then **global pocket**.                 |

---

## 4) Fees & Slippage Guards (what to surface in UI)

* **U → OX (mint)**:

  * **Oracle-priced** (per asset family), optional **mint haircut**, then **`tinBps`** (deducted in OX, minted to treasury).
  * Use `previewSwapExactIn` / `previewSwapExactOut` for net OX and required U.
* **OX → U (redeem)**:

  * **Dynamic redemption fee** (time-varying). Snapshotted at swap start → **preview parity**.
  * Use `previewSwapExactIn` (OX in → U out) or `previewSwapExactOut` (U out → OX in).
* **OX ↔ S**: No UCE fee; ERC-4626 exchange rate applies.

**Recommended UI guards**

* For **Exact-In**: display `previewSwapExactIn` and allow a **minOut** tolerance on the client side.
* For **Exact-Out**: compute `previewSwapExactOut` and set **maxAmountIn = preview** (or small buffer).

---

## 5) Common Reverts & Integration Checks

* **Paused asset**: `assetIn` or `assetOut` paused → revert.
* **Invalid pair**: Only **U↔OX** and **OX↔S** are supported (no U↔U, no OX↔OX).
* **Zero amounts / bad receiver**: `amountIn == 0`, `amountOut == 0`, or `receiver == address(0)` → revert.
* **Allocator restrictions**: Allocators cannot call **OX→U** (must use underlying).
* **Oracle issues (U→OX)**: Stale/disabled feeds or family mismatch → revert.
* **Pocket liquidity/allowance** (OX→U): If allowance/balance on pocket is insufficient, revert (integrators should ensure pockets keep allowances open).
* **Referral invariants**: Referred **U→OX** must be fully served by referrer’s `reservedOx` (or it reverts).

---

## 6) End-to-End Examples

**Mint OX from U (no referral)**

```javascript
uint256 quote = UCE.previewSwapExactIn(U, OX, amountU);
IERC20(U).approve(address(UCE), amountU);
uint256 oxOut = UCE.swapExactIn(U, OX, amountU, msg.sender, 0);
```

**Redeem OX to U (exact-out with referral)**

```javascript
uint256 oxNeeded = UCE.previewSwapExactOut(OX, U, wantU);
IERC20(OX).approve(address(UCE), oxNeeded);
uint256 paid = UCE.swapExactOut(OX, U, wantU, oxNeeded, msg.sender, referralCode);
```

**Stake OX into s0x (ERC-4626)**

```javascript
uint256 shares = UCE.previewSwapExactIn(OX, S0X, oxIn);
IERC20(OX).approve(address(UCE), oxIn);
uint256 minted = UCE.swapExactIn(OX, S0X, oxIn, msg.sender, 0);
```

**Unstake s0x back to OX (exact-out)**

```javascript
uint256 sharesIn = UCE.previewSwapExactOut(S0X, OX, needOx);
IERC20(S0X).approve(address(UCE), sharesIn);
uint256 spentShares = UCE.swapExactOut(S0X, OX, needOx, sharesIn, msg.sender, 0);
```

---

## 7) Implementation Tips

* **Always preview** before calling swap; reflect **tin** and **redemption fee** in the UI.
* **Set appropriate allowances** for ERC-20s and ERC-4626 shares.
* **Handle referral codes**: pass `0` for non-referred flow; pass on-chain mapped code for referred users.
* **Surface failures clearly**: oracle stale, pocket allowance low, paused asset, invalid pair.
* **Block explorer & analytics**: index the `Swap` event for volumes, referral share, and path usage.
