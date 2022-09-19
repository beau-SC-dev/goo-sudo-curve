// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.15;

// import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
// import {console} from "forge-std/console.sol";

// import {GooCurve} from "../src/GooCurveWIP.sol";
// import {CurveErrorCodes} from "../src/sudo/CurveErrorCodes.sol";
// import {LibGOO} from "../src/GOObblers/LibGOO.sol";

// contract GooCurveTestWIP is DSTestPlus {
//     GooCurve gooCurve;
//     uint256 runsToCheck;

//     function setUp() public {
//         gooCurve = new GooCurve();
//         runsToCheck = 10;
//     }

//     function testSingleSell() public {
//         CurveErrorCodes.Error error;
//         uint256 newSpotPrice;
//         uint256 newDelta;
//         uint256 inputAmount;
//         uint256 protocolFee;

//         (error, newSpotPrice, newDelta, inputAmount, protocolFee) = gooCurve.getSellInfo(
//             1e18, // start with 1 ETH price - try 0 too
//             1, // start with emission multiple of 1
//             1, // numItems
//             0, // feeMultiplier
//             5000000000000000 // 0.50%, protocolFeeMultiplier
//         );
//         console.log("Output amount received from single sell:");
//         console.log(inputAmount); // expect to be equal to singles
//     }

//     function testRepeatedSells() public {
//         uint256 sum;

//         CurveErrorCodes.Error error;
//         uint256 newSpotPrice = 1e18; // start with 1 ETH price
//         uint256 newDelta = 1; // start with emission multiple of 1
//         uint256 inputAmount;
//         uint256 protocolFee;

//         for (uint256 i = 0; i < runsToCheck; i++) {
//             (error, newSpotPrice, newDelta, inputAmount, protocolFee) = gooCurve.getSellInfo(
//                 uint128(newSpotPrice), // lastPrice
//                 uint128(newDelta), // emission multiple
//                 1, // numItems
//                 0, // feeMultiplier
//                 5000000000000000 // 0.50%, protocolFeeMultiplier
//             );
//             console.log("input amount:");
//             console.log(inputAmount);
//             console.log("new spot:");
//             console.log(newSpotPrice);
//             sum += inputAmount;
//         }

//         console.log("Total output amount received for single sells:");
//         console.log(sum);
//     }

//     function testBatchSell() public {
//         CurveErrorCodes.Error error;
//         uint256 newSpotPrice;
//         uint256 newDelta;
//         uint256 inputAmount;
//         uint256 protocolFee;

//         (error, newSpotPrice, newDelta, inputAmount, protocolFee) = gooCurve.getSellInfo(
//             1e18, // // start with 1 ETH price - try 0 too
//             1, // start with emission multiple of 1
//             runsToCheck, // numItems
//             0, // feeMultiplier
//             5000000000000000 // 0.50%, protocolFeeMultiplier
//         );
//         console.log("Total output amount received for batch sell:");
//         console.log(inputAmount); // expect to be equal to singles
//     }
// }
