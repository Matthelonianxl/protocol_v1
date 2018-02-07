pragma solidity 0.4.19;

import { ERC20 } from "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import { NoOwner } from "zeppelin-solidity/contracts/ownership/NoOwner.sol";
import { Pausable } from "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import { Math } from "zeppelin-solidity/contracts/math/Math.sol";
import { AccessControlled } from "../lib/AccessControlled.sol";


/**
 * @title Proxy
 * @author Antonio Juliano
 *
 * Used to transfer tokens between addresses which have set allowance on this contract
 */
contract Proxy is AccessControlled, NoOwner, Pausable {
    // ---------------------------
    // ----- State Variables -----
    // ---------------------------

    /**
     * Only addresses that are transfer authorized can move funds.
     * Authorized addresses through AccessControlled can add and revoke
     * transfer authorized addresses
     */
    mapping(address => bool) public transferAuthorized;

    // ------------------------
    // -------- Events --------
    // ------------------------

    event TransferAuthorization(
        address who,
        uint timestamp
    );

    event TransferDeauthorization(
        address who,
        uint timestamp
    );

    // -------------------------
    // ------ Constructor ------
    // -------------------------

    function Proxy(
        uint _accessDelay,
        uint _gracePeriod
    )
        AccessControlled(_accessDelay, _gracePeriod)
        public
    {}

    // ---------------------------
    // -------- Modifiers --------
    // ---------------------------

    modifier requiresTransferAuthorization() {
        require(transferAuthorized[msg.sender]);
        _;
    }

    // --------------------------------------------------
    // ---- Authorized Only State Changing Functions ----
    // --------------------------------------------------

    function grantTransferAuthorization(
        address who
    )
        requiresAuthorization
        whenNotPaused
        external
    {
        if (!transferAuthorized[who]) {
            transferAuthorized[who] = true;

            TransferAuthorization(
                who,
                block.timestamp
            );
        }
    }

    function revokeTransferAuthorization(
        address who
    )
        requiresAuthorization
        whenNotPaused
        external
    {
        if (transferAuthorized[who]) {
            delete transferAuthorized[who];

            TransferDeauthorization(
                who,
                block.timestamp
            );
        }
    }

    // ---------------------------------------------
    // ---- Owner Only State Changing Functions ----
    // ---------------------------------------------

    function ownerRevokeTransferAuthorization(
        address who
    )
        onlyOwner
        external
    {
        if (transferAuthorized[who]) {
            delete transferAuthorized[who];

            TransferDeauthorization(
                who,
                block.timestamp
            );
        }
    }

    // -----------------------------------------------------------
    // ---- Transfer Authorized Only State Changing Functions ----
    // -----------------------------------------------------------

    function transfer(
        address token,
        address from,
        uint value
    )
        requiresTransferAuthorization
        whenNotPaused
        public
    {
        require(ERC20(token).transferFrom(from, msg.sender, value));
    }

    function transferTo(
        address token,
        address from,
        address to,
        uint value
    )
        requiresTransferAuthorization
        whenNotPaused
        external
    {
        require(ERC20(token).transferFrom(from, to, value));
    }

    // -----------------------------------------
    // ------- Public Constant Functions -------
    // -----------------------------------------

    function available(
        address who,
        address token
    )
        view
        external
        returns (uint _allowance)
    {
        return Math.min256(
            ERC20(token).allowance(who, address(this)),
            ERC20(token).balanceOf(who)
        );
    }
}
