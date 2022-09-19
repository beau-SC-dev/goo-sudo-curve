// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {ICurve} from "./sudo/ICurve.sol";
import {CurveErrorCodes} from "./sudo/CurveErrorCodes.sol";
import {FixedPointMathLib} from "./sudo/FixedPointMathLib.sol";
import {LibGOO} from "./GOObblers/LibGOO.sol";

/*
Note: This version is only built for "TOKEN" pool types, as it only supports buying.

    Check README for more important notes.
*/

/// @author bHeau
/// @notice GOO-based bonding curve logic for SudoSwap pools (https://www.paradigm.xyz/2022/09/goo)
/// @dev    The "GOO balance" for the pair is stored in `spotPrice`, and is used to track where on the curve pricing currently is.
/// @dev    The "scaler" is stored in `delta`, and is used to scale down (or up) the price via division
/// @dev    Both parameters can obviously be manually changed by setting spotPrice or delta.
contract GooCurve is ICurve, CurveErrorCodes {
    using FixedPointMathLib for uint256;

    uint256 constant emissionMultiple = 1; // Developer can change according to preference

    /**
        @dev See {ICurve-validateDelta}
     */
    function validateDelta(uint128 delta) external pure override returns (bool) {
        // Can't divide by 0
        return delta != 0;
    }

    /**
        @dev See {ICurve-validateSpotPrice}
     */
    function validateSpotPrice(uint128 newSpotPrice) external pure override returns (bool) {
        // Start at > 0
        return newSpotPrice > 0;
    }

    /**
        @dev See {ICurve-getBuyInfo}
     */
    function getBuyInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        pure
        override
        returns (
            Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 inputValue,
            uint256 protocolFee
        )
    {
        // Check that items are being purchased from the pair
        if (numItems == 0) {
            return (Error.INVALID_NUMITEMS, 0, 0, 0, 0);
        }

        // Get the pair's "GOO balance" and scaler
        uint256 gooBalance = spotPrice;
        uint256 scaler = delta;

        /* 
        Calculate input value
        This is defined by:

        n = numItems
        --------
        \
         >      [ (emissionMultiple * (n * 1e18)^2) / 4 ] + gooBalance + [ (n * 1e18) * sqrt(emissionMultiple * gooBalance) ]
        /
        --------
        n = 1

        */
        uint256 inputValueWithoutFee;
        for (uint256 n = 1; n < numItems + 1; n++) {
            inputValueWithoutFee += LibGOO.computeGOOBalance(
                emissionMultiple,
                gooBalance,
                n * 1e18 // Scale to 1e18
            );
        }

        // Divide by scaler to keep pricing in sought after range
        inputValueWithoutFee = inputValueWithoutFee.fdiv(scaler, FixedPointMathLib.WAD);

        // Add the fees to the amount to send in
        protocolFee = inputValueWithoutFee.fmul(protocolFeeMultiplier, FixedPointMathLib.WAD);
        uint256 fee = inputValueWithoutFee.fmul(feeMultiplier, FixedPointMathLib.WAD);
        inputValue = inputValueWithoutFee + fee + protocolFee;

        // Set the new "GOO balance" and emission multiple
        newSpotPrice = uint128(LibGOO.computeGOOBalance(emissionMultiple, gooBalance, numItems * 1e18)); // Note explicit conversion
        newDelta = delta; // Scaler must be updated manually

        // If we got all the way here, no math error happened
        error = Error.OK;
    }

    /**
        @dev See {ICurve-getSellInfo}
     */
    function getSellInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        pure
        override
        returns (
            Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee
        )
    {
        // WIP
        return (Error.INVALID_NUMITEMS, 0, 0, 0, 0);
    }
}
