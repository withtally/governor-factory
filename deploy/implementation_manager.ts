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

};

deployContracts.id = "implementation_manager";
deployContracts.tags = ["ImplementationManager"];

export default deployContracts;
