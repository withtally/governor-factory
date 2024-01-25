import { ethers } from "hardhat";
import type { Factory } from "../../types/Factory";
import type { Factory__factory } from "../../types/factories/Factory__factory";

export async function deployFactoryFixture() {
    // Default values for deployment
    const implementationAddress = "0x..."; // Replace with actual implementation contract address

    // Contracts are deployed using the first signer/account by default
    const [deployer] = await ethers.getSigners();

    const Factory = (await ethers.getContractFactory("Factory")) as Factory__factory;
    const factory = (await Factory.deploy(implementationAddress)) as Factory;

    return { factory, deployer, implementationAddress };
}