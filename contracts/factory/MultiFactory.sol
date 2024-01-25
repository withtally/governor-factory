// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title MultiFactory Contract for creating clones of multiple implementations
/// @dev Extends AccessControl and Initializable from OpenZeppelin
contract MultiFactory is AccessControl, Initializable {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    /// Mapping from contract names to their versions and implementation addresses
    mapping(bytes32 => mapping(uint32 => address)) public implementations;

    /// Mapping from contract names to their latest versions
    mapping(bytes32 => uint32) public lastVersions;

    /// Emitted when a new implementation address is stored
    event ImplementationStored(string name, uint32 version, address indexed implementation);

    /// Emitted when a new clone is created
    event CloneCreated(string name, uint32 version, address indexed cloneAddress);

    /// @notice Initializes the contract
    /// @dev Sets up the DEFAULT_ADMIN_ROLE
    function initialize() public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPDATER_ROLE, msg.sender);
    }

    /// @notice Updates the address of a specific implementation
    /// @param newImplementation The address of the new implementation contract
    /// @param name The name of the contract
    /// @dev Requires UPDATER_ROLE; increments version and emits ImplementationStored event
    function updateImplementation(address newImplementation, string memory name) public onlyRole(UPDATER_ROLE) {
        _setImplementation(newImplementation, name);
    }

    /// @notice Internal function to set the implementation address
    /// @param newImplementation The address of the new implementation contract
    /// @param name The name of the contract
    /// @dev Validates the new address, updates the mapping, and increments the version
    function _setImplementation(address newImplementation, string memory name) internal {
        require(newImplementation != address(0), "Invalid implementation address");
        bytes32 nameHash = keccak256(abi.encodePacked(name));
        uint32 currentVersion = lastVersions[nameHash] + 1;
        implementations[nameHash][currentVersion] = newImplementation;
        lastVersions[nameHash] = currentVersion;
        emit ImplementationStored(name, currentVersion, newImplementation);
    }

    /// @notice Clones a specific implementation using a deterministic address
    /// @param name The name of the contract to clone
    /// @param salt The salt value used for predictable cloning
    /// @return The address of the newly created clone
    /// @dev Uses the latest version of the implementation; uses OpenZeppelin's Clones library
    function clone(string memory name, bytes32 salt) public returns (address) {
        bytes32 nameHash = keccak256(abi.encodePacked(name));
        address implementation = implementations[nameHash][lastVersions[nameHash]];
        address clone = Clones.cloneDeterministic(implementation, salt);
        emit CloneCreated(name, lastVersions[nameHash], clone);
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

    /// @notice Predicts the address of a clone created with a specific implementation and salt
    /// @param name The name of the contract to clone
    /// @param salt The salt value to be used in the deterministic cloning process
    /// @return The predicted address of the new clone contract
    /// @dev Utilizes the keccak256 hash of the concatenation of a prefix, the factory contract address, salt, and the implementation bytecode for prediction
    function predictCloneAddress(string memory name, bytes32 salt) public view returns (address) {
        bytes32 nameHash = keccak256(abi.encodePacked(name));
        address implementation = implementations[nameHash][lastVersions[nameHash]];

        bytes memory bytecode = abi.encodePacked(
            type(Clones).creationCode,
            abi.encode(implementation)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }
}
