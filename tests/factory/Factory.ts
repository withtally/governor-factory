import { expect } from "chai";
import { ethers } from "hardhat";
import { deployMockFactoryFixture } from "./Factory.fixture";
import type { MockFactory, MockToken } from "../../types";

describe("MockFactory Contract", function () {
  let factory: MockFactory;
  let token: MockToken;
  let implementationAddress: string;

  beforeEach(async function () {
    ({ factory, token, implementationAddress } = await deployMockFactoryFixture());
  });

  const fixedSalt = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";

  describe("Clone Creation", function () {
    it("Should create a clone of the MockToken", async function () {
      await expect(factory.clone(fixedSalt, implementationAddress)).to.emit(factory, "CloneCreated");
    });

    it("Should emit Clone Created event with correct arguments", async function () {
      const tx = await factory.clone(fixedSalt, implementationAddress);
      const receipt = await tx.wait();

      const event = receipt?.logs?.[0];

      expect(event?.args?.[1]).to.equal(implementationAddress);
      expect(event?.args?.[2]).to.equal(fixedSalt);

    })
  });

  describe("Clone Initialization", function () {
    it("Should initialize the cloned MockToken", async function () {
      const initData = token.interface.encodeFunctionData("initialize", ["ClonedToken", "CTK"]);
      const tx = await factory.clone(fixedSalt, implementationAddress);
      const receipt = await tx.wait();

      const event = receipt?.logs?.[0];

      const cloneAddress = event?.args?.[0];

      await expect(factory.initClone(cloneAddress, initData))
        .to.emit(factory, "CloneInitialized")
        .withArgs(cloneAddress, initData);

      const clonedToken = await ethers.getContractAt("MockToken", cloneAddress) as MockToken;
      expect(await clonedToken.name()).to.equal("ClonedToken");
      expect(await clonedToken.symbol()).to.equal("CTK");
    });
  });

  describe("Clone and Initialize in One Step", function () {
    it("Should clone and initialize the MockToken in one transaction", async function () {
      const initData = token.interface.encodeFunctionData("initialize", ["OneStepToken", "OST"]);
      const tx = await factory.cloneAndInitialize(fixedSalt, implementationAddress, initData);
      const receipt = await tx.wait();

      const event = receipt?.logs?.[0];

      const cloneAddress = event?.args?.[0];

      const clonedToken = await ethers.getContractAt("MockToken", cloneAddress) as MockToken;
      expect(await clonedToken.name()).to.equal("OneStepToken");
      expect(await clonedToken.symbol()).to.equal("OST");
    });
  });

  describe("Predict Clone Address", function () {
    it("Should predict the address of a clone correctly", async function () {
      const predictedAddress = await factory.predictCloneAddress(fixedSalt, implementationAddress);
      const tx = await factory.clone(fixedSalt, implementationAddress);
      const receipt = await tx.wait();

      const event = receipt?.logs?.[0];

      const cloneAddress = event?.args?.[0];

      expect(predictedAddress).to.equal(cloneAddress);
    });
  });

});
