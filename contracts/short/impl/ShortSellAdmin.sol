pragma solidity 0.4.19;

import { Ownable } from "zeppelin-solidity/contracts/ownership/Ownable.sol";
import { DelayedUpdate } from "../../lib/DelayedUpdate.sol";
import { ShortSellState } from "./ShortSellState.sol";


/**
 * @title ShortSellAdmin
 * @author Antonio Juliano
 *
 * This contract contains the owner only admin functions of ShortSell
 */
contract ShortSellAdmin is Ownable, DelayedUpdate {

    // Copy of state variable defined on ShortSell, so we can reference it
    ShortSellState.State state;

    // --------------------------------
    // ----- Owner Only Functions -----
    // --------------------------------

    function updateTrader(
        address _trader
    )
        onlyOwner // Must come before delayedAddressUpdate
        delayedAddressUpdate("TRADER", _trader)
        external
    {
        state.TRADER = _trader;
    }

    function updateProxy(
        address _proxy
    )
        onlyOwner // Must come before delayedAddressUpdate
        delayedAddressUpdate("PROXY", _proxy)
        external
    {
        state.PROXY = _proxy;
    }

    function updateVault(
        address _vault
    )
        onlyOwner // Must come before delayedAddressUpdate
        delayedAddressUpdate("VAULT", _vault)
        external
    {
        state.VAULT = _vault;
    }

    function updateRepo(
        address _repo
    )
        onlyOwner // Must come before delayedAddressUpdate
        delayedAddressUpdate("REPO", _repo)
        external
    {
        state.REPO = _repo;
    }

    function updateAuctionRepo(
        address _auction_repo
    )
        onlyOwner // Must come before delayedAddressUpdate
        delayedAddressUpdate("AUCTION_REPO", _auction_repo)
        external
    {
        state.AUCTION_REPO = _auction_repo;
    }
}
