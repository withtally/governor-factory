// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import “@openzeppelin/contracts/proxy/Clones.sol”;
import “@openzeppelin/contracts/access/AccessControl.sol”;
import “@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol”;

contract MultiFactory is AccessControl, Initializable {
    
    // Address of the implementation contract

    // name with keccak, to version ( as integer ), to address
    public mapping(bytes32=>mapping(uint32)=>address) implementations;

    // user can get most recent version
    public mapping(bytes32=>uint32) public lastVersions;
    
    // Event to announce the implementation address stored
    event ImplementationStored(
        string name,
        version uint32,
        address indexed implementation,
    );

    // Event to announce a new clone was created
    event CloneCreated(
        string name,
        version uint32,
        address indexed cloneAddress,
    );

    // Initializer function to set the initial implementation address
    function initialize(address _implementation) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPDATER_ROLE, msg.sender);
        _setImplementation(_implementation);
    }

    // Function to update the implementation contract address
    function updateImplementation(address newImplementation,string name) public onlyRole(UPDATER_ROLE) {
        _setImplementation(newImplementation,name);
    }

    // Internal function to set the implementation address
    function _setImplementation(address newImplementation,string name) internal {
        require(newImplementation != address(0), “Invalid implementation address”);
        uint32 nameKeccak256 = keccak256(name);
        implementations[keccak256(name);] = newImplementation;
        emit ImplementationStored(
            name,
            lastVersions[nameKeccak256],
            newImplementation
        );
    }
    
    // Function to clone and initialize a new contract
    function cloneAndInitialize(
        string name,
        bytes calldata initData
    ) public returns (address) {
        address clone = Clones.clone(implementation);
        (bool success, ) = clone.call(initData);
        require(success, “Initialization failed”);
        emit CloneCreated(clone);
        return clone;
    }
}