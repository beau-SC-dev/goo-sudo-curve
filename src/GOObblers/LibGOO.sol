// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/// @title GOO (Gradual Ownership Optimization) Issuance
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Implementation of the GOO Issuance mechanism.
library LibGOO {
    using FixedPointMathLib for uint256;

    /// @notice Compute goo balance based on emission multiple, last balance, and time elapsed.
    /// @param emissionMultiple The multiple on emissions to consider when computing the balance.
    /// @param lastBalanceWad The last checkpointed balance to apply the emission multiple over time to, scaled by 1e18.
    /// @param timeElapsedWad The time elapsed since the last checkpoint, scaled by 1e18.
    function computeGOOBalance(
        uint256 emissionMultiple,
        uint256 lastBalanceWad,
        uint256 timeElapsedWad
    ) public pure returns (uint256) {
        unchecked {
            // We use wad math here because timeElapsedWad is, as the name indicates, a wad.
            uint256 timeElapsedSquaredWad = timeElapsedWad.mulWadDown(timeElapsedWad);

            // prettier-ignore
            return lastBalanceWad + // The last recorded balance.

            // Don't need to do wad multiplication since we're
            // multiplying by a plain integer with no decimals.
            // Shift right by 2 is equivalent to division by 4.
            ((emissionMultiple * timeElapsedSquaredWad) >> 2) +

            timeElapsedWad.mulWadDown( // Terms are wads, so must mulWad.
                // No wad multiplication for emissionMultiple * lastBalance
                // because emissionMultiple is a plain integer with no decimals.
                // We multiply the sqrt's radicand by 1e18 because it expects ints.
                (emissionMultiple * lastBalanceWad * 1e18).sqrt()
            );
        }
    }
    
    /// @notice Compute last goo balance based on current balance, emission multiple, and time to "go back" on the curve by.
    /// @param emissionMultiple The multiple on emissions to consider when computing the balance.
    /// @param currentBalanceWad The current balance of GOO, scaled by 1e18.
    /// @param timeBackWad The time elapsed since the time we want the balance for, scaled by 1e18.
    function computeLastGOOBalance(
        uint256 emissionMultiple,
        uint256 currentBalanceWad,
        uint256 timeBackWad
    ) public pure returns (uint256) {
        /*
        We know the current balance (result of computeGOOBalance), so we can solve for "lastBalanceWad" 
        using the same equation used in computeGOOBalance.

        Solving that equation for lastBalanceWad gives us:
        lastBalanceWad = [ +-4 sqrt(b) sqrt(m) t + 4b + mt^2 ] / 4
        where m = emissionMultiple, b = currentBalanceWad, and t = timeSinceWad
        */

        uint256 timeSinceSquaredWad = timeBackWad.mulWadDown(timeBackWad);

        // prettier-ignore
        return ((emissionMultiple * timeSinceSquaredWad)

        + (currentBalanceWad << 2)

        - (
            (((currentBalanceWad*1e18).sqrt()).mulWadDown(
                ((emissionMultiple).sqrt()) * timeBackWad
            )
            )
        << 2)
        
        ) >> 2;
    }
}
