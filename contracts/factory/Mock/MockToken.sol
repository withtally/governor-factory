// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title MockToken
 * @dev A mock implementation of an ERC20 token.
 */
contract MockToken is Initializable, ERC20Upgradeable {
    /**
     * @dev Initializes the contract by setting the initial supply and minting tokens to the deployer.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     */
    function initialize(string memory name, string memory symbol) public initializer {
        __ERC20_init(name, symbol);
        _mint(msg.sender, 1000 * 10 ** decimals()); // Initial supply
    }

    /**
     * @dev Mints new tokens and adds them to the specified address.
     * @param to The address to which the tokens will be minted.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /**
     * @dev Burns tokens from the specified address.
     * @param from The address from which the tokens will be burned.
     * @param amount The amount of tokens to burn.
     */
    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
