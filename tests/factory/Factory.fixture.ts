import { ethers } from "hardhat";
import type { MockFactory } from "../../types/contracts/factory/mock/MockFactory";
import type { MockFactory__factory } from "../../types/factories/Factory__factory";

export async function deployMockFactoryFixture() {

    // Contracts are deployed using the first signer/account by default
    const [deployer] = await ethers.getSigners();

    const Factory = (await ethers.getContractFactory("MockFactory")) as MockFactory__factory;
    const factory = (await Factory.deploy()) as MockFactory;

    return { factory, deployer };
}