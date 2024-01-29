// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Factory.sol";

/// @title Implementation Manager Contract
/// @notice This contract is responsible for managing the creation and tracking of contract implementations.
/// It allows for the addition of contract types and their corresponding implementations.
/// @dev This contract extends AccessControl, Initializable, and ReentrancyGuard from OpenZeppelin.
contract ImplementationManager is AccessControl, Factory {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    // Custom error messages
    error TypeAlreadyExists();
    error TypeDoesNotExist();
    error NotAuthorized();
    error VersionExists();
    error VersionDoesNotExist();
    error CommitExists();
    error InvalidTypeName();
    error InvalidAddress();
    error NoImplementations();

    // Events
    event ContractTypeAdded(bytes32 indexed typeHash);
    event ImplementationAdded(
        bytes32 indexed typeHash,
        address indexed implementation,
        uint16 indexed version,
        bytes32 commitHash
    );

    struct Implementation {
        address implementation;
        uint16 version;
        bytes32 commitHash;
    }

    struct ContractType {
        bytes32 typeHash;
        uint16 latestVersion;
    }

    mapping(bytes32 => ContractType) public contractTypes;
    mapping(bytes32 => Implementation[]) public implementations;

    // Track versions and commits to avoid clashes
    mapping(bytes32 => mapping(uint16 => bool)) public versions;
    mapping(bytes32 => mapping(bytes32 => bool)) public commits;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPDATER_ROLE, msg.sender);
    }

    modifier onlyUpdater() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert NotAuthorized();
        _;
    }

    /// @notice Generates the type hash for a given contract type name.
    /// @param typeName The name of the contract type.
    /// @return The type hash.
    function getTypeHash(string memory typeName) public pure returns (bytes32) {
        return keccak256(abi.encode(typeName));
    }

    /// @notice Adds a new contract type.
    /// @param typeName The name of the contract type to add.
    function addContractType(string memory typeName) external onlyUpdater {
        if (bytes(typeName).length == 0) revert InvalidTypeName();

        bytes32 typeHash = getTypeHash(typeName);
        if (contractTypes[typeHash].typeHash != bytes32(0)) revert TypeAlreadyExists();

        contractTypes[typeHash] = ContractType(typeHash, 0);

        emit ContractTypeAdded(typeHash);
    }

    /// @notice Adds a new implementation for a contract type.
    /// @param typeName The name of the contract type.
    /// @param implementation The address of the implementation contract.
    /// @param version The version number of the implementation.
    /// @param commitHash The commit hash associated with the implementation.
    function addImplementation(
        string memory typeName,
        address implementation,
        uint16 version,
        bytes32 commitHash
    ) external onlyUpdater {
        bytes32 typeHash = getTypeHash(typeName);
        ContractType storage contractType = contractTypes[typeHash];

        if (contractType.typeHash == bytes32(0)) revert TypeDoesNotExist();
        if (versions[typeHash][version]) revert VersionExists();
        if (commits[typeHash][commitHash]) revert CommitExists();
        if (implementation == address(0)) revert InvalidAddress();

        implementations[typeHash].push(Implementation(implementation, version, commitHash));
        contractType.latestVersion = version;

        // Marking the version and commit hash as used for this contract type
        versions[typeHash][version] = true;
        commits[typeHash][commitHash] = true;

        emit ImplementationAdded(typeHash, implementation, version, commitHash);
    }

    /// @notice Retrieves the latest implementation for a contract type.
    /// @param typeName The name of the contract type.
    /// @return The address, version, and commit hash of the latest implementation.
    function getLatestImplementation(string memory typeName) external view returns (address, uint16, bytes32) {
        bytes32 typeHash = getTypeHash(typeName);
        Implementation[] storage impls = implementations[typeHash];

        if (contractTypes[typeHash].typeHash == bytes32(0)) revert TypeDoesNotExist();
        if (impls.length == 0) revert NoImplementations();

        uint256 latestIndex = impls.length - 1;
        return (impls[latestIndex].implementation, impls[latestIndex].version, impls[latestIndex].commitHash);
    }

    /// @notice Retrieves the implementation for a specific version of a contract type.
    /// @param typeName The name of the contract type.
    /// @param version The version number of the implementation.
    /// @return The address of the implementation.
    function getImplementationByVersion(string memory typeName, uint16 version) external view returns (address) {
        bytes32 typeHash = getTypeHash(typeName);
        Implementation[] storage impls = implementations[typeHash];

        for (uint i = 0; i < impls.length; i++) {
            if (impls[i].version == version) {
                return impls[i].implementation;
            }
        }

        revert VersionDoesNotExist(); // No matching implementation found for the given version
    }
}
