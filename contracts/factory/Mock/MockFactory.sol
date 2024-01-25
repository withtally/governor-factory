// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Factory.sol";

/// @title MockFactory
/// @notice A mock implementation of the Factory contract
contract MockFactory is Factory {
    string public MOCK_NAME;

    /// @dev Initializes the MockFactory contract
    /// @param _name The name of the mock factory
    /// @param _implementation The address of the implementation contract
    function initialize(string calldata _name, address _implementation) public {
        MOCK_NAME = _name;
        super.initialize(_implementation);
    }
}
