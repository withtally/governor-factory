// ImplementationManager.fixture.ts
import { ethers } from "hardhat";
import type { ImplementationManager } from "../../types";
import type { ImplementationManager__factory } from "../../types";

export async function deployImplementationManagerFixture() {
    const [deployer] = await ethers.getSigners();

    const ImplementationManagerFactory = (await ethers.getContractFactory("ImplementationManager", deployer)) as ImplementationManager__factory;
    const implementationManager = await ImplementationManagerFactory.deploy() as ImplementationManager;

    return { implementationManager, deployer };
}
