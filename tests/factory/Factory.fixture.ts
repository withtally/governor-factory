import { ethers } from "hardhat";
import type { MockFactory } from "../../types/contracts/factory/mock/MockFactory";
import type { MockFactory__factory } from "../../types/factories/contracts/factory/mock/MockFactory__factory";

export async function deployMockFactoryFixture() {

    // Contracts are deployed using the first signer/account by default
    const [deployer] = await ethers.getSigners();

    const Factory = (await ethers.getContractFactory("MockFactory")) as MockFactory__factory;
    const factory = await Factory.deploy() as MockFactory;

    // set roles
    await factory["initialize(address)"](deployer.address);
    
    const implementationAddress = await factory.getAddress(); // Replace with implementation address

    await factory.updateImplementation(implementationAddress);

    return { factory, deployer, implementationAddress };
}
