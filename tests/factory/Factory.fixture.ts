import { ethers } from "hardhat";
import type { MockFactory, MockToken } from "../../types";
import type { MockFactory__factory, MockToken__factory } from "../../types";

export async function deployMockFactoryFixture() {

  // Contracts are deployed using the first signer/account by default
  const [deployer] = await ethers.getSigners();

  // Deploy the MockFactory
  const Factory = (await ethers.getContractFactory("MockFactory", deployer)) as MockFactory__factory;
  const factory = await Factory.deploy() as MockFactory;

  // Deploy the MockToken
  const Token = (await ethers.getContractFactory("MockToken", deployer)) as MockToken__factory;
  const token = await Token.deploy() as MockToken;

  // Initialize the MockToken with desired parameters
  await token.initialize("MockToken", "MTK");

  const implementationAddress = await token.getAddress();

  return { factory, token, deployer, implementationAddress };
}
