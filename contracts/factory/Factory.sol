// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Factory Contract for creating clones of a given implementation
/// @dev Extends AccessControl, Initializable, and ReentrancyGuard from OpenZeppelin
abstract contract Factory is Initializable, ReentrancyGuard {
    /// Eimitted if a clone fails to initialize
    error InitializationFailed();

    /// Emitted when a new clone is created
    event CloneCreated(address indexed cloneAddress, address indexed implementation, bytes32 indexed salt);
    event CloneInitialized(address indexed cloneAddress, bytes initData);

    /// @notice Clones the implementation contract using a deterministic address
    /// @param salt The salt value used for predictable cloning
    /// @return The address of the newly created clone
    /// @dev Uses OpenZeppelin's Clones library
    function clone(bytes32 salt, address _immplementation) public virtual returns (address) {
        return _clone(salt, _immplementation);
    }

    function _clone(bytes32 salt, address _implementation) internal returns (address) {
        address output = Clones.cloneDeterministic(_implementation, salt);
        emit CloneCreated(output, _implementation, salt);
        return output;
    }

    /// @notice Initializes a cloned contract with provided data
    /// @param cloneAddress The address of the cloned contract
    /// @param initData The initialization data to be sent to the cloned contract
    /// @dev Calls the cloned contract with provided data; requires success
    function initClone(address cloneAddress, bytes calldata initData) public payable virtual {
        _initClone(cloneAddress, initData);
    }

    function _initClone(address cloneAddress, bytes calldata initData) internal {
        (bool success, ) = cloneAddress.call{ value: msg.value }(initData);

        if (!success) revert InitializationFailed();
        emit CloneInitialized(cloneAddress, initData);
    }

    /// @notice Clones and initializes a new contract in one transaction
    /// @param salt The salt value used for predictable cloning
    /// @param initData The initialization data for the new clone
    /// @return The address of the newly created and initialized clone
    /// @dev Combines the clone and init functions for convenience
    function cloneAndInitialize(
        bytes32 salt,
        address implementation,
        bytes calldata initData
    ) public payable virtual returns (address) {
        return _cloneAndInitialize(salt, implementation, initData);
    }

    function _cloneAndInitialize(
        bytes32 salt,
        address implementation,
        bytes calldata initData
    ) private returns (address) {
        address output = clone(salt, implementation);
        initClone(output, initData);
        return output;
    }

    /// @notice Predicts the address of a clone created with a specific implementation and salt
    /// @param salt The salt value to be used in the deterministic cloning process
    /// @return The predicted address of the new clone contract
    /// @dev Utilizes the keccak256 hash of the concatenation of a prefix, the factory contract address, salt, and the implementation bytecode for prediction
    function predictCloneAddress(bytes32 salt, address implementation) public view returns (address) {
        return Clones.predictDeterministicAddress(implementation, salt, address(this));
    }
}
