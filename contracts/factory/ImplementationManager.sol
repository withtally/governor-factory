// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Factory.sol";

/// @title Factory Contract for creating clones of a given implementation
/// @dev Extends AccessControl, Initializable, and ReentrancyGuard from OpenZeppelin
contract ImplementationManager is AccessControl, Factory {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    // Custom error messages
    error TypeAlreadyExists();
    error TypeDoesNotExist();
    error NotAuthorized();
    error VersionExists();
    error CommitExists();

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

    //track versions and committs for no clashes
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

    function getTypeHash(string memory typeName) public pure returns (bytes32) {
        return keccak256(abi.encode(typeName));
    }

    function addContractType(string memory typeName) external onlyUpdater {
        bytes32 typeHash = getTypeHash(typeName);
        if (contractTypes[typeHash].typeHash == bytes32(0)) revert TypeAlreadyExists();

        contractTypes[typeHash] = ContractType(typeHash, 0);
    }

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

        implementations[typeHash].push(Implementation(implementation, version, commitHash));
        contractType.latestVersion = version;

        // Marking the version and commit hash as used for this contract type
        versions[typeHash][version] = true;
        commits[typeHash][commitHash] = true;
    }

    function getLatestImplementation(string memory typeName) external view returns (address, uint16, bytes32) {
        bytes32 typeHash = getTypeHash(typeName);
        Implementation[] storage impls = implementations[typeHash];
        uint256 latestIndex = impls.length - 1;
        return (impls[latestIndex].implementation, impls[latestIndex].version, impls[latestIndex].commitHash);
    }

    function getImplementationByVersion(string memory typeName, uint16 version) external view returns (address) {
        bytes32 typeHash = getTypeHash(typeName);
        Implementation[] storage impls = implementations[typeHash];

        for (uint i = 0; i < impls.length; i++) {
            if (impls[i].version == version) {
                return impls[i].implementation;
            }
        }

        revert TypeDoesNotExist(); // No matching implementation found for the given version
    }
}
