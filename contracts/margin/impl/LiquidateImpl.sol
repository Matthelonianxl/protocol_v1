pragma solidity 0.4.21;
pragma experimental "v0.5.0";

import { SafeMath } from "zeppelin-solidity/contracts/math/SafeMath.sol";
import { CloseShortShared } from "./CloseShortShared.sol";
import { MarginState } from "./MarginState.sol";


/**
 * @title LiquidateImpl
 * @author dYdX
 *
 * This library contains the implementation for the liquidate function of Margin
 */
library LiquidateImpl {
    using SafeMath for uint256;

    // ------------------------
    // -------- Events --------
    // ------------------------

    /**
     * A loan was liquidated
     */
    event LoanLiquidated(
        bytes32 indexed marginId,
        address indexed liquidator,
        address indexed payoutRecipient,
        uint256 liquidatedAmount,
        uint256 remainingAmount,
        uint256 quoteTokenPayout
    );

    // -------------------------------------------
    // ----- Public Implementation Functions -----
    // -------------------------------------------

    function liquidateImpl(
        MarginState.State storage state,
        bytes32 marginId,
        uint256 requestedLiquidationAmount,
        address payoutRecipient
    )
        public
        returns (uint256, uint256)
    {
        CloseShortShared.CloseTx memory transaction = CloseShortShared.createCloseTx(
            state,
            marginId,
            requestedLiquidationAmount,
            payoutRecipient,
            address(0),
            true,
            true
        );

        uint256 quoteTokenPayout = CloseShortShared.sendQuoteTokensToPayoutRecipient(
            state,
            transaction,
            0, // No buyback cost
            0  // Did not receive any base token
        );

        CloseShortShared.closeShortStateUpdate(state, transaction);

        logEventOnLiquidate(transaction);

        return (
            transaction.closeAmount,
            quoteTokenPayout
        );
    }

    // --------- Helper Functions ---------

    function logEventOnLiquidate(
        CloseShortShared.CloseTx transaction
    )
        internal
    {
        emit LoanLiquidated(
            transaction.marginId,
            msg.sender,
            transaction.payoutRecipient,
            transaction.closeAmount,
            transaction.currentShortAmount.sub(transaction.closeAmount),
            transaction.availableQuoteToken
        );
    }

}
