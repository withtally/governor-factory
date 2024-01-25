// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title Lock
 * @dev A contract for locking funds until a specific time.
 * This contract is for testing purposes only of the factory.
 */
contract Lock is Initializable {
    uint256 public unlockTime;
    address payable public owner;

    event Withdrawal(uint256 amount, uint256 when);

    /**
     * @dev Initializes the Lock contract
     * @param _unlockTime The time after which funds can be withdrawn
     */
    function initialize(uint256 _unlockTime) public payable initializer {
        require(block.timestamp < _unlockTime, "InvalidUnlockTime");
        
        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    /**
     * @dev Withdraws the locked funds if the unlock time has been reached
     */
    function withdraw() public {
        require(block.timestamp >= unlockTime, "UnlockTimeNotReached");
        require(msg.sender == owner, "NotOwner");

        emit Withdrawal(address(this).balance, block.timestamp);
        owner.transfer(address(this).balance);
    }
}
