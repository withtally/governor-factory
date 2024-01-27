// ImplementationManager.test.ts
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployImplementationManagerFixture } from "./ImplementationManager.fixture";
import type { ImplementationManager } from "../../types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("ImplementationManager Contract", function () {
  let implementationManager: ImplementationManager;
  let deployer: SignerWithAddress;
  let mockImplementation: string;

  beforeEach(async function () {
    ({ implementationManager, deployer } = await deployImplementationManagerFixture());
    mockImplementation = deployer.address;
  });

  const fixedCommitHash = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
  const typeName = "TestType";


  describe("Contract Type Management", function () {
    it("Should allow adding a new contract type", async function () {
      const typeName = "TestType";
      await expect(implementationManager.addContractType(typeName))
        .to.emit(implementationManager, "ContractTypeAdded"); // Assuming such an event exists
    });

    it("Should revert when adding an existing contract type", async function () {
      const typeName = "TestType";
      await implementationManager.addContractType(typeName);
      await expect(implementationManager.addContractType(typeName))
        .to.be.revertedWithCustomError(implementationManager, "TypeAlreadyExists");
    });
  });

  describe("Implementation Management", function () {
    it("Should allow adding an implementation", async function () {
      const typeName = "TestType";
      const version = 1;

      await implementationManager.addContractType(typeName);
      await expect(implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash))
        .to.emit(implementationManager, "ImplementationAdded"); // Assuming such an event exists
    });

    it("Should revert when adding an implementation for a non-existent contract type", async function () {
      const typeName = "NonExistentType";
      const version = 1;

      await expect(implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash))
        .to.be.revertedWithCustomError(implementationManager, "TypeDoesNotExist");
    });

    it("Should revert when adding an implementation with an existing version", async function () {
      const version = 1;

      await implementationManager.addContractType(typeName);
      await implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash);

      const newCommitHash = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890";
      await expect(implementationManager.addImplementation(typeName, mockImplementation, version, newCommitHash))
        .to.be.revertedWithCustomError(implementationManager, "VersionExists");
    });

    it("Should revert when adding an implementation with an existing commit hash", async function () {
      const version = 1;
      const newVersion = 2;

      await implementationManager.addContractType(typeName);
      await implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash);

      await expect(implementationManager.addImplementation(typeName, mockImplementation, newVersion, fixedCommitHash))
        .to.be.revertedWithCustomError(implementationManager, "CommitExists");
    });
  });

  describe("Implementation Retrieval", function () {
    it("Should retrieve the latest implementation", async function () {
      const typeName = "TestType";
      const version = 1;

      await implementationManager.addContractType(typeName);
      await implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash);

      const [implementationAddress] = await implementationManager.getLatestImplementation(typeName);
      expect(implementationAddress).to.equal(mockImplementation);
    });

    it("Should revert when retrieving an implementation for a non-existent type", async function () {
      await expect(implementationManager.getLatestImplementation("NonExistentType"))
        .to.be.revertedWithCustomError(implementationManager, "TypeDoesNotExist");
    });

    it("Should return correct implementation for a specific version", async function () {
      const version = 1;
      const newVersion = 2;
      const newCommitHash = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890";
      const newMockImplementation = "0x0000000000000000000000000000000000000002";

      await implementationManager.addContractType(typeName);
      await implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash);
      await implementationManager.addImplementation(typeName, newMockImplementation, newVersion, newCommitHash);

      const implementationAddress = await implementationManager.getImplementationByVersion(typeName, newVersion);
      expect(implementationAddress).to.equal(newMockImplementation);
    });

    it("Should revert when retrieving an implementation for a non-existent version", async function () {
      const nonExistentVersion = 999;

      await implementationManager.addContractType(typeName);
      await expect(implementationManager.getImplementationByVersion(typeName, nonExistentVersion))
        .to.be.revertedWithCustomError(implementationManager, "VersionDoesNotExist");
    });
  });

  describe("Role-Based Access Control Tests", function () {
    it("Should only allow UPDATER_ROLE to add a contract type", async function () {
      const [_, otherAccount] = await ethers.getSigners();
      await expect(implementationManager.connect(otherAccount).addContractType("NewType"))
        .to.be.revertedWithCustomError(implementationManager, "NotAuthorized");
    });

    // Similar tests for adding implementations
  });

  describe("Boundary Conditions", function () {
    it("Should handle maximum version number correctly", async function () {
      const maxVersion = 65535; // uint16 max value
      await implementationManager.addContractType(typeName);
      await expect(implementationManager.addImplementation(typeName, mockImplementation, maxVersion, fixedCommitHash))
        .to.emit(implementationManager, "ImplementationAdded");
    });

    it("Should handle edge-case names for contract types", async function () {
      const edgeCaseName = ""; // Empty string
      await expect(implementationManager.addContractType(edgeCaseName))
        .to.be.revertedWithCustomError(implementationManager, "InvalidTypeName"); // Assuming such a custom error
    });
    // Similar test for very long string and special characters
  });

  describe("State Consistency Checks", function () {
    it("Should update state correctly after adding implementations", async function () {
      const version = 1;
      await implementationManager.addContractType(typeName);
      await implementationManager.addImplementation(typeName, mockImplementation, version, fixedCommitHash);

      const latestVersion = (await implementationManager.contractTypes(await implementationManager.getTypeHash(typeName))).latestVersion;
      expect(latestVersion).to.equal(version);
    });
  });

  describe("Invalid Inputs", function () {
    it("Should revert when adding an implementation with an invalid address", async function () {
      const invalidAddress = "0x0000000000000000000000000000000000000000"; // Zero address
      await implementationManager.addContractType(typeName);
      await expect(implementationManager.addImplementation(typeName, invalidAddress, 1, fixedCommitHash))
        .to.be.revertedWithCustomError(implementationManager, "InvalidAddress");
    });
  });

  describe("Revert on Empty Implementations Array", function () {
    it("Should revert when retrieving implementation for an empty array", async function () {
      await implementationManager.addContractType(typeName);
      await expect(implementationManager.getLatestImplementation(typeName))
        .to.be.revertedWithCustomError(implementationManager, "NoImplementations");
    });
  });
  // Additional tests can be added as needed...
});
