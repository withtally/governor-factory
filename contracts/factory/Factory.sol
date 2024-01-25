// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Factory Contract for creating clones of a given implementation
/// @dev Extends AccessControl, Initializable, and ReentrancyGuard from OpenZeppelin
abstract contract Factory is AccessControl, Initializable, ReentrancyGuard {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    /// Address of the implementation contract
    address public implementation;

    /// Emitted when a new implementation address is stored
    event ImplementationStored(address indexed implementation);

    /// Emitted when a new clone is created
    event CloneCreated(address indexed cloneAddress);

    /// @notice Initializes the contract with the given implementation address
    /// @param _implementation The address of the implementation contract
    /// @dev Sets up roles and sets the implementation address
    function initialize(address _implementation) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPDATER_ROLE, msg.sender);
        _setImplementation(_implementation);
    }

    /// @notice Updates the address of the implementation contract
    /// @param newImplementation The address of the new implementation contract
    /// @dev Requires UPDATER_ROLE; emits ImplementationStored event
    function updateImplementation(address newImplementation) public onlyRole(UPDATER_ROLE) {
        _setImplementation(newImplementation);
    }

    /// @notice Internal function to set the implementation address
    /// @param newImplementation The address of the new implementation contract
    /// @dev Validates the new address and updates state; emits ImplementationStored event
    function _setImplementation(address newImplementation) internal {
        require(newImplementation != address(0), "Invalid implementation address");
        implementation = newImplementation;
        emit ImplementationStored(newImplementation);
    }

    /// @notice Clones the implementation contract using a deterministic address
    /// @param salt The salt value used for predictable cloning
    /// @return The address of the newly created clone
    /// @dev Uses OpenZeppelin's Clones library
    function clone(bytes32 salt) public returns (address) {
        address clone = Clones.cloneDeterministic(implementation, salt);
        emit CloneCreated(clone);
        return clone;
    }

    /// @notice Initializes a cloned contract with provided data
    /// @param cloneAddress The address of the cloned contract
    /// @param initData The initialization data to be sent to the cloned contract
    /// @dev Calls the cloned contract with provided data; requires success
    function init(address cloneAddress, bytes calldata initData) public {
        (bool success, ) = cloneAddress.call(initData);
        require(success, "Initialization failed");
    }

    /// @notice Clones and initializes a new contract in one transaction
    /// @param salt The salt value used for predictable cloning
    /// @param initData The initialization data for the new clone
    /// @return The address of the newly created and initialized clone
    /// @dev Combines the clone and init functions for convenience
    function cloneAndInitialize(bytes32 salt, bytes calldata initData) public returns (address) {
        address clone = this.clone(salt);
        this.init(clone, initData);
        return clone;
    }
}
