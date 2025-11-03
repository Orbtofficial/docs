// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IOrbtUCE
 * @notice Public interface for the Orbit Unified Collateral Engine (UCE).
 * @dev    UCE unifies 0x assets (Ox), underlyings (U), and ERC4626 yield wrappers (S) for
 *         protocol-native swaps, custody, and allocator-aware accounting.
 */
interface IOrbtUCE {

    /**********************************************************************************************/
    /*** Enums                                                                                  ***/
    /**********************************************************************************************/

    /// @notice Logical group for a deployed UCE instance; determines the base unit and price index.
    enum AssetFamily {
        BTC,
        ETH,
        USD
    }

    // Unified per-asset configuration/state
    struct AssetCfg {
        address pocket;
        AssetFamily family;
        bool paused;
        uint16 tinBps;
        uint16 reserveBps; // 0 => default RESERVE_BPS
        uint16 mintHaircutBps;
        bool oracleEnabled;
        uint32 oracleHeartbeat;
        address oracleBaseFeed;
        address oracleUsdFeed;
        uint256 reservedUnderlying;
    }

    /// @notice Operation types permitted for allocator configuration changes.
    enum AllocatorOperations {
        SET_ALLOCATOR,
        UPDATE_ALLOWED,
        UPDATE_REFERRAL_CODE,
        UPDATE_POCKET,
        UPDATE_LINE,
        UPDATE_BORROW_FEE
    }

    /// @notice Pair classification used by UCE for swap routing/gating
    enum PairType {
        OxToS, // OX -> s0x
        SToOx, // s0x -> OX
        OxToU, // OX -> Underlying
        UToOx  // Underlying -> OX
    }
    
    // ==============================
    // Unified Allocator State
    // ==============================

    /// @notice Allocator credit line limits with day-bucketed accounting.
    struct LineOfCredit {
        uint128 ceiling;      // Max total outstanding debt
        uint128 dailyCap;     // Max amount mintable per 24h
        uint128 mintedToday;  // Amount minted in current 24h window
        uint32  lastMintDay;  // Day index (UTC days)
    }

    /// @notice Complete allocator accounting and config state.
    struct AllocatorState {
        bool allowed;
        uint256 baseDebt; // outstanding debt in 0xAsset units (direct tracking, no index scaling)
        uint256 reservedOx; // allocator-reserved 0x inventory
        uint16 borrowFeeBps; // upfront borrow fee in bps
        LineOfCredit line;
        mapping(address asset => address pocket) pocket;                // per-asset allocator pocket
        uint256 referralCode; // attribution code for user-initiated swaps
        uint256 debtEpoch; // epoch of this allocator's debt (masked if < wipeEpoch)
        address prev;
        address next;
    }

    // ==============================
    // Allocator config/credit
    // ==============================

    /// @notice In-memory structure used for admin/governance updates
    struct SetAllocatorMemory {
        address allocator;
        bool allowed;
        LineOfCredit line;
        uint16 borrowFeeBps;
    }

    /**********************************************************************************************/
    /*** Events                                                                                 ***/
    /**********************************************************************************************/

    /**
     *  @dev   Emitted when a new pocket is set for an asset.
     *  @param asset         Address of the asset.
     *  @param oldPocket     Address of the old pocket.
     *  @param newPocket     Address of the new pocket.
     *  @param amountTransferred Amount of asset transferred from old to new pocket.
     */
    event PocketSet(
        address indexed asset,
        address indexed oldPocket,
        address indexed newPocket,
        uint256 amountTransferred
    );

    /// @notice Emitted when per-asset pause state is changed.
    event AssetPaused(address indexed asset, bool paused);

    /**
     *  @dev   Emitted when an asset is swapped in the PSM.
     *  @param assetIn       Address of the asset swapped in.
     *  @param assetOut      Address of the asset swapped out.
     *  @param sender        Address of the sender of the swap.
     *  @param receiver      Address of the receiver of the swap.
     *  @param amountIn      Amount of the asset swapped in.
     *  @param amountOut     Amount of the asset swapped out.
     *  @param referralCode  Referral code for the swap.
     */
    event Swap(
        address indexed assetIn,
        address indexed assetOut,
        address sender,
        address indexed receiver,
        uint256 amountIn,
        uint256 amountOut,
        uint256 referralCode
    );

    /**
     *  @dev   Emitted when an asset is deposited into the PSM.
     *  @param asset           Address of the asset deposited.
     *  @param user            Address of the user that deposited the asset.
     *  @param receiver        Address of the receiver of the resulting 0xAsset from the deposit.
     *  @param assetsDeposited Amount of the asset deposited.
     *  @param oxAssetsMinted  Number of 0xAssets minted to the user.
     */
    event Deposit(
        address indexed asset,
        address indexed user,
        address indexed receiver,
        uint256 assetsDeposited,
        uint256 oxAssetsMinted
    );

    /**
     *  @dev   Emitted when an asset is withdrawn from the PSM.
     *  @param asset           Address of the asset withdrawn.
     *  @param user            Address of the user that withdrew the asset.
     *  @param receiver        Address of the receiver of the withdrawn assets.
     *  @param assetsWithdrawn Amount of the asset withdrawn.
     *  @param oxAssetsBurned  Number of 0xAssets burned from the user.
     */
    event Withdraw(
        address indexed asset,
        address indexed user,
        address indexed receiver,
        uint256 assetsWithdrawn,
        uint256 oxAssetsBurned
    );

    /**********************************************************************************************/
    /*** State variables and immutables                                                         ***/
    /**********************************************************************************************/

    /**
     *  @dev    Returns the pocket address for a given asset.
     *  @param  asset The address of the asset.
     *  @return The pocket address for the asset.
     */
    function pockets(address asset) external view returns (address);

    /**
     *  @dev    Returns the asset family for a given asset.
     *  @param  asset The address of the asset.
     *  @return The asset family of the asset.
     */
    function assetFamilies(address asset) external view returns (AssetFamily);

    /**********************************************************************************************/
    /*** Owner functions                                                                        ***/
    /**********************************************************************************************/

    /**
     *  @dev    Sets the pocket address for a given asset.
     *  @param  asset     Address of the asset.
     *  @param  newPocket Address of the new pocket.
     */
    function setPocket(address asset, address newPocket) external;

    /**
     *  @dev    Adds a new asset with its family, pocket and reserveBps. If the asset is an s-asset
     *          (per ISOxAsset/IERC4626 with asset() == family's 0x), it is auto-registered.
     *  @param  asset       Address of the asset to add.
     *  @param  family      Asset family of the asset.
     *  @param  pocket      Address of the pocket for the asset (ignored runtime for s-assets; kept on-contract by reserve).
     *  @param  reserveBps  Portion (in bps) of inbound kept on-contract for this asset.
     */
    function addAsset(address asset, AssetFamily family, address pocket, uint256 reserveBps) external;

    /**********************************************************************************************/
    /*** Swap functions                                                                         ***/
    /**********************************************************************************************/

    /**
     *  @dev    Swaps a specified amount of assetIn for assetOut in the PSM.
     *  @param  assetIn      Address of the ERC-20 asset to swap in.
     *  @param  assetOut     Address of the ERC-20 asset to swap out.
     *  @param  amountIn     Amount of the asset to swap in.
     *  @param  receiver     Address of the receiver of the swapped assets.
     *  @param  referralCode Referral code for the swap.
     *  @return amountOut    Resulting amount of the asset that will be received in the swap.
     */
    function swapExactIn(
        address assetIn,
        address assetOut,
        uint256 amountIn,
        address receiver,
        uint256 referralCode
    ) external returns (uint256 amountOut);

    /**
     *  @dev    Swaps a derived amount of assetIn for a specific amount of assetOut in the PSM.
     *  @param  assetIn      Address of the ERC-20 asset to swap in.
     *  @param  assetOut     Address of the ERC-20 asset to swap out.
     *  @param  amountOut    Amount of the asset to receive from the swap.
     *  @param  maxAmountIn  Max amount of the asset to use for the swap.
     *  @param  receiver     Address of the receiver of the swapped assets.
     *  @param  referralCode Referral code for the swap.
     *  @return amountIn     Resulting amount of the asset swapped in.
     */
    function swapExactOut(
        address assetIn,
        address assetOut,
        uint256 amountOut,
        uint256 maxAmountIn,
        address receiver,
        uint256 referralCode
    ) external returns (uint256 amountIn);

    /**********************************************************************************************/
    /*** Liquidity provision functions                                                          ***/
    /**********************************************************************************************/

    /**
     *  @dev    Deposits an amount of a given asset into the PSM.
     *  @param  asset           Address of the ERC-20 asset to deposit.
     *  @param  receiver        Address of the receiver of the resulting 0xAsset from the deposit.
     *  @param  assetsToDeposit Amount of the asset to deposit into the PSM.
     *  @return newOxAssets     Number of 0xAssets minted to the user.
     */
    function deposit(address asset, address receiver, uint256 assetsToDeposit)
        external returns (uint256 newOxAssets);

    /**
     *  @dev    Withdraws an amount of a given asset from the PSM.
     *  @param  asset               Address of the ERC-20 asset to withdraw.
     *  @param  receiver            Address of the receiver of the withdrawn assets.
     *  @param  maxAssetsToWithdraw Max amount that the user is willing to withdraw.
     *  @return assetsWithdrawn     Resulting amount of the asset withdrawn from the PSM.
     */
    function withdraw(
        address asset,
        address receiver,
        uint256 maxAssetsToWithdraw
    ) external returns (uint256 assetsWithdrawn);

    /**********************************************************************************************/
    /*** Deposit/withdraw preview functions                                                     ***/
    /**********************************************************************************************/

    /**
     *  @dev    View function that returns the exact number of 0xAssets that would be minted for a
     *          given asset and amount to deposit.
     *  @param  asset  Address of the ERC-20 asset to deposit.
     *  @param  assets Amount of the asset to deposit into the PSM.
     *  @return oxAssets Number of 0xAssets to be minted to the user.
     */
    function previewDeposit(address asset, uint256 assets) external view returns (uint256 oxAssets);

    /**
     *  @dev    View function that returns the exact number of assets that would be withdrawn and
     *          corresponding 0xAssets that would be burned in a withdrawal.
     *  @param  asset               Address of the ERC-20 asset to withdraw.
     *  @param  maxAssetsToWithdraw Max amount that the user is willing to withdraw.
     *  @return oxAssetsToBurn      Number of 0xAssets that would be burned in the withdrawal.
     *  @return assetsWithdrawn     Resulting amount of the asset withdrawn from the PSM.
     */
    function previewWithdraw(address asset, uint256 maxAssetsToWithdraw)
        external view returns (uint256 oxAssetsToBurn, uint256 assetsWithdrawn);

    /**********************************************************************************************/
    /*** Swap preview functions                                                                 ***/
    /**********************************************************************************************/

    /**
     * @dev    View function that returns the exact amount of assetOut that would be received for a
     *         given amount of assetIn in a swap.
     * @param  assetIn   Address of the ERC-20 asset to swap in.
     * @param  assetOut  Address of the ERC-20 asset to swap out.
     * @param  amountIn  Amount of the asset to swap in.
     * @return amountOut Amount of the asset that will be received in the swap.
     */
    function previewSwapExactIn(address assetIn, address assetOut, uint256 amountIn)
        external view returns (uint256 amountOut);

    /**
     * @dev    View function that returns the exact amount of assetIn that would be required to
     *         receive a given amount of assetOut in a swap.
     * @param  assetIn   Address of the ERC-20 asset to swap in.
     * @param  assetOut  Address of the ERC-20 asset to swap out.
     * @param  amountOut Amount of the asset to receive from the swap.
     * @return amountIn  Amount of the asset that is required to receive amountOut.
     */
    function previewSwapExactOut(address assetIn, address assetOut, uint256 amountOut)
        external view returns (uint256 amountIn);

    /**********************************************************************************************/
    /*** Conversion functions                                                                   ***/
    /**********************************************************************************************/

    /**
     *  @dev    View function that converts an amount of 0xAssets to the equivalent amount of
     *          underlying assets for a specified asset.
     *  @param  asset     Address of the asset to use to convert.
     *  @param  numOxAssets Number of 0xAssets to convert to assets.
     *  @return assets    Value of assets in asset-native units.
     */
    function convertToAssets(address asset, uint256 numOxAssets) external view returns (uint256);

    /**
     *  @dev    View function that converts an amount of a given asset to 0xAssets.
     *  @param  asset  Address of the ERC-20 asset to convert to 0xAssets.
     *  @param  assets Amount of assets in asset-native units.
     *  @return oxAssets Number of 0xAssets that the assets are equivalent to.
     */
    function convertToOxAssets(address asset, uint256 assets) external view returns (uint256);

    function allocatorCreditMint(address allocator, uint256 amount) external;

    /**
     * @dev    Repays an amount of a given asset for an allocator.
     * @param  asset     Address of the ERC-20 asset to repay.
     * @param  assets    Amount of the asset to repay.
     */
    function allocatorRepay(address asset, uint256 assets) external;
}
