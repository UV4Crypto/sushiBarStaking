// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// SushiBar is the coolest bar in town. You come in with some Sushi, and leave with more! The longer you stay, the more Sushi you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.
contract SushiBar is ERC20("SushiBar", "xSUSHI") {
    using SafeMath for uint256;
    IERC20 public sushi;

    mapping(address => uint256) _staked_time;

    uint256 _staking_time;

    // Define the Sushi token contract
    constructor(IERC20 _sushi) {
        sushi = _sushi;
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks Sushi and mints xSushi
    function enter(uint256 _amount) public {
        // Gets the amount of Sushi locked in the contract
        uint256 totalSushi = sushi.balanceOf(address(this));
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // If no xSushi exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
        }
        // Calculate and mint the amount of xSushi the Sushi is worth. The ratio will change overtime, as xSushi is burned/minted and Sushi deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalSushi);
            _mint(msg.sender, what);
        }
        // Lock the Sushi in the contract
        sushi.transferFrom(msg.sender, address(this), _amount);

        _staked_time[msg.sender] = block.timestamp;
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unlocks the staked + gained Sushi and burns xSushi
    function leave(uint256 _share) public {
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Sushi the xSushi is worth
        uint256 what;
        uint256 temp;

        _staking_time = block.timestamp - _staked_time[msg.sender];

        if (_staking_time < 172800) {
            what = 0;
            temp = 1;
        } else if (_staking_time >= 172800 && _staking_time < 172800 * 2) {
            what = _share
                .mul(sushi.balanceOf(address(this)))
                .div(totalShares)
                .div(4);
        } else if (_staking_time >= 172800 * 2 && _staking_time < 172800 * 3) {
            what = _share
                .mul(sushi.balanceOf(address(this)))
                .div(totalShares)
                .div(2);
        } else if (_staking_time >= 172800 * 3 && _staking_time < 172800 * 4) {
            what = _share
                .mul(sushi.balanceOf(address(this)))
                .div(totalShares)
                .div(4)
                .mul(3);
        } else {
            what = _share.mul(sushi.balanceOf(address(this))).div(totalShares);
        }
        if (temp != 1) {
            _burn(msg.sender, _share);    // The tokens received on tax will go back into rewards pool.
            sushi.transfer(msg.sender, what);
        }

        
    }
}
