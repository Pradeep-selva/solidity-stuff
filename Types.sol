// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

library Types {
    struct Exhibit {
        address payable manager;
        string itemName;
        uint256 endTime;
        uint256 bidAmount;
        address payable winner;
    }
}
