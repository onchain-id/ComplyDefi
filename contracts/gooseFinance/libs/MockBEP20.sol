// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20.sol";

contract MockBEP20 is BEP20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) BEP20(name, symbol) {
        _mint(msg.sender, supply);

    }
}