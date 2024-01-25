// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Factory.sol";

contract MockFactory is Factory {
    // This mock contract can have additional functions or state variables
    // necessary for testing, such as counters or flags to validate behavior.

    function testFunction() public pure returns (string memory) {
        return "Mock Function Called";
    }
}