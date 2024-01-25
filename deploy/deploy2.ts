import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import fs from "fs";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();

    console.log("\x1B[37mDeploying MockFactory and Lock contracts");

    // Deploy Lock contract
    await (async function deployLock() {
        const lock = await deploy("Lock", {
            from: deployer,
            args: [], // Lock constructor arguments
            log: true,
        });

        const lockBlock = await hre.ethers.provider.getBlock("latest");

        console.log(`\nLock contract deployed at: `, lock.address);

        // Save to contracts.out file
        const lockDeployStr = `Lock contract deployed at: ${lock.address} - Block number: ${lockBlock?.number}\n`;
        fs.appendFileSync("contracts.out", lockDeployStr);

        // Verify Lock contract
        const lockVerifyStr = `npx hardhat verify --network ${hre.network.name} ${lock.address}\n`;
        console.log(lockVerifyStr);
        fs.appendFileSync("contracts.out", lockVerifyStr);
    })();

    // Deploy MockFactory contract
    await (async function deployMockFactory() {
        const mockFactory = await deploy("MockFactory", {
            from: deployer,
            args: [], // MockFactory constructor arguments
            log: true,
        });

        const mockFactoryBlock = await hre.ethers.provider.getBlock("latest");

        console.log(`\nMockFactory contract deployed at: `, mockFactory.address);

        // Save to contracts.out file
        const mockFactoryDeployStr = `MockFactory contract deployed at: ${mockFactory.address} - Block number: ${mockFactoryBlock?.number}\n`;
        fs.appendFileSync("contracts.out", mockFactoryDeployStr);

        // Verify MockFactory contract
        const mockFactoryVerifyStr = `npx hardhat verify --network ${hre.network.name} ${mockFactory.address}\n`;
        console.log(mockFactoryVerifyStr);
        fs.appendFileSync("contracts.out", mockFactoryVerifyStr);
    })();

};

deployContracts.id = "deploy_contracts";
deployContracts.tags = ["MockFactory", "Lock"];

export default deployContracts;
