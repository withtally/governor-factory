import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import fs from "fs";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();

    console.log("\x1B[37mDeploying ImplementationManager and MockToken contracts");

    // Deploy ImplementationManager contract
    await (async function deployImplementationManager() {
        const implementationManager = await deploy("ImplementationManager", {
            from: deployer,
            args: [], // ImplementationManager constructor arguments
            log: true,
        });

        const implementationManagerBlock = await hre.ethers.provider.getBlock("latest");

        console.log(`\nImplementationManager contract deployed at: `, implementationManager.address);

        // Save to contracts.out file
        const implementationManagerDeployStr = `ImplementationManager contract deployed at: ${implementationManager.address} - Block number: ${implementationManagerBlock?.number}\n`;
        fs.appendFileSync("contracts.out", implementationManagerDeployStr);

        // Verify ImplementationManager contract
        const implementationManagerVerifyStr = `npx hardhat verify --network ${hre.network.name} ${implementationManager.address}\n`;
        console.log(implementationManagerVerifyStr);
        fs.appendFileSync("contracts.out", implementationManagerVerifyStr);

    })();

    // Deploy MockToken contract
    await (async function deployMockToken() {
        const mockToken = await deploy("MockToken", {
            from: deployer,
            args: [], // MockToken constructor arguments
            log: true,
        });

        const mockTokenBlock = await hre.ethers.provider.getBlock("latest");

        console.log(`\nMockToken contract deployed at: `, mockToken.address);

        // Save to contracts.out file
        const mockTokenDeployStr = `MockToken contract deployed at: ${mockToken.address} - Block number: ${mockTokenBlock?.number}\n`;
        fs.appendFileSync("contracts.out", mockTokenDeployStr);

        // Verify MockToken contract
        const mockTokenVerifyStr = `npx hardhat verify --network ${hre.network.name} ${mockToken.address}\n`;
        console.log(mockTokenVerifyStr);
        fs.appendFileSync("contracts.out", mockTokenVerifyStr);
    })();

    // Function to add MockToken as an implementation on ImplementationManager
    async function addMockTokenAsImplementation() {
        const implementationManager = await hre.deployments.get("ImplementationManager");
        const mockToken = await hre.deployments.get("MockToken");

        await implementationManager.addImplementation("MockToken", mockToken.address);
    }

    // Call the function to add MockToken as an implementation on ImplementationManager
    await addMockTokenAsImplementation();
};

deployContracts.id = "deploy_contracts";
deployContracts.tags = ["ImplementationManager", "MockToken"];

export default deployContracts;
