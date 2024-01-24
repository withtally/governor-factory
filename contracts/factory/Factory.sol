// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import “@openzeppelin/contracts/proxy/Clones.sol”;
import “@openzeppelin/contracts/access/AccessControl.sol”;
import “@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol”;

contract Factory is AccessControl, Initializable {
    bytes32 public constant UPDATER_ROLE = keccak256(“UPDATER_ROLE”);
    // Address of the implementation contract
    address public implementation;
    // Event to announce the implementation address stored
    event ImplementationStored(address indexed implementation);
    // Event to announce a new clone was created
    event CloneCreated(address indexed cloneAddress);
    // Initializer function to set the initial implementation address
    function initialize(address _implementation) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPDATER_ROLE, msg.sender);
        _setImplementation(_implementation);
    }
    // Function to update the implementation contract address
    function updateImplementation(address newImplementation) public onlyRole(UPDATER_ROLE) {
        _setImplementation(newImplementation);
    }
    // Internal function to set the implementation address
    function _setImplementation(address newImplementation) internal {
        require(newImplementation != address(0), “Invalid implementation address”);
        implementation = newImplementation;
        emit ImplementationStored(newImplementation);
    }
    // Function to clone and initialize a new contract
    function cloneAndInitialize(bytes calldata initData) public returns (address) {
        address clone = Clones.clone(implementation);
        (bool success, ) = clone.call(initData);
        require(success, “Initialization failed”);
        emit CloneCreated(clone);
        return clone;
    }
}