// SPDX-License-Identifier: MIT
pragma solidity  >=0.7.6;

library Types {
    struct Exhibit {
        address payable manager;
        string itemName;
        uint256 duration;
        uint256 bidAmount;
        address payable winner;
    }
}
