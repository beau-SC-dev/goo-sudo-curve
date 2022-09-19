// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {console} from "forge-std/console.sol";

import {GooCurve} from "../src/GooCurve.sol";
import {CurveErrorCodes} from "../src/sudo/CurveErrorCodes.sol";
import {LibGOO} from "../src/GOObblers/LibGOO.sol";

contract GooCurveTest is DSTestPlus {
    GooCurve gooCurve;
    uint256 runsToCheck;

    function setUp() public {
        gooCurve = new GooCurve();
        runsToCheck = 10;
    }

    function testSingleBuy() public {
        CurveErrorCodes.Error error;
        uint256 newSpotPrice;
        uint256 newDelta;
        uint256 inputAmount;
        uint256 protocolFee;

        (error, newSpotPrice, newDelta, inputAmount, protocolFee) = gooCurve.getBuyInfo(
            1e18, // start with 1e18 GOO balance
            100e18, // start with scaler of 100e18
            1, // numItems
            0, // feeMultiplier
            5000000000000000 // 0.50%, protocolFeeMultiplier
        );
        console.log("Input amount required for single buy:");
        console.log(inputAmount); // .022612500000000000 ETH
    }

    function testRepeatedVsBatchBuys() public {
        uint256 repeated;
        uint256 batch;

        CurveErrorCodes.Error error;
        uint256 newSpotPrice = 1e18; // start with 1e18 GOO balance
        uint256 newDelta = 100e18; // start with scaler of 100e18
        uint256 inputAmount;
        uint256 protocolFee;

        for (uint256 i = 0; i < runsToCheck; i++) {
            (error, newSpotPrice, newDelta, inputAmount, protocolFee) = gooCurve.getBuyInfo(
                uint128(newSpotPrice), // lastPrice
                uint128(newDelta), // emission multiple
                1, // numItems
                0, // feeMultiplier
                5000000000000000 // 0.50%, protocolFeeMultiplier
            );
            repeated += inputAmount;
        }

        (error, newSpotPrice, newDelta, inputAmount, protocolFee) = gooCurve.getBuyInfo(
            1e18, // start with 1e18 GOO balance
            100e18, // start with scaler of 100e18
            runsToCheck, // numItems
            0, // feeMultiplier
            5000000000000000 // 0.50%, protocolFeeMultiplier
        );

        batch = inputAmount;

        assertEq(repeated, batch);
        console.log("Matched prices:");
        console.log(repeated);
    }
}
