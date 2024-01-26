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

    /// Errors
    error InvalidImplementationAddress();
    error InitializationFailed();

    /// Emitted when a new implementation address is stored
    event ImplementationStored(address indexed implementation);

    /// Emitted when a new clone is created
    event CloneCreated(address indexed cloneAddress, address indexed implementation, bytes32 indexed salt);

    /// @notice Initializes the contract with the given implementation address
    /// @param _implementation The address of the implementation contract
    /// @dev Sets up roles and sets the implementation address
    function initialize(address _implementation) public virtual initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPDATER_ROLE, msg.sender);
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
        if (newImplementation == address(0)) revert InvalidImplementationAddress();

        implementation = newImplementation;
        emit ImplementationStored(newImplementation);
    }

    /// @notice Clones the implementation contract using a deterministic address
    /// @param salt The salt value used for predictable cloning
    /// @return The address of the newly created clone
    /// @dev Uses OpenZeppelin's Clones library
    function clone(bytes32 salt) public returns (address) {
        address _clone = Clones.cloneDeterministic(implementation, salt);
        emit CloneCreated(_clone, implementation, salt);
        return _clone;
    }

    /// @notice Initializes a cloned contract with provided data
    /// @param cloneAddress The address of the cloned contract
    /// @param initData The initialization data to be sent to the cloned contract
    /// @dev Calls the cloned contract with provided data; requires success
    function init(address cloneAddress, bytes calldata initData) public {
        (bool success, ) = cloneAddress.call(initData);

        if (!success) revert InitializationFailed();
    }

    /// @notice Clones and initializes a new contract in one transaction
    /// @param salt The salt value used for predictable cloning
    /// @param initData The initialization data for the new clone
    /// @return The address of the newly created and initialized clone
    /// @dev Combines the clone and init functions for convenience
    function cloneAndInitialize(bytes32 salt, bytes calldata initData) public returns (address) {
        address _clone = this.clone(salt);
        this.init(_clone, initData);
        return _clone;
    }

    /// @notice Predicts the address of a clone created with a specific implementation and salt
    /// @param salt The salt value to be used in the deterministic cloning process
    /// @return The predicted address of the new clone contract
    /// @dev Utilizes the keccak256 hash of the concatenation of a prefix, the factory contract address, salt, and the implementation bytecode for prediction
    function predictCloneAddress(bytes32 salt) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(type(Clones).creationCode, abi.encode(implementation));

        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));

        return address(uint160(uint256(hash)));
    }
}
