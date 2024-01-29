import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import fs from "fs";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const [deployerSigner] = await hre.ethers.getSigners();
    const deployer = await deployerSigner.getAddress();

    console.log("\x1B[37mDeploying MockFactory contract");

    // Deploy MockFactory contract
    await (async function deployMockFactory() {

        const mockFactory = await deploy("MockFactory", {
            from: deployer,
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

deployContracts.id = "mock_factory";
deployContracts.tags = ["MockFactory"];

export default deployContracts;
