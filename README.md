# Tally Factory

This package provides a factory contract for creating clones of a given implementation.

## Factory Contract

The factory contract is responsible for creating clones of a given implementation contract.

The factory contract allows for the storage and update of the implementation address, cloning of the implementation
contract using a deterministic address, initialization of the cloned contract with provided data, and prediction of the
address of a clone created with a specific implementation and salt.

## Usage

To use the Tally Factory, follow these steps:

1. Install the package by running `npm install tally-factory`.

2. Import the factory module into your code:

   ```solidity
   import "@tallyxyz/tally-factory/contracts/factory/Factory.sol";
   ```

<!-- ## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a
pull request on the [GitHub repository](https://github.com/your-username/tally-factory). -->

## License

This package is licensed under the [MIT License](https://opensource.org/licenses/MIT).
