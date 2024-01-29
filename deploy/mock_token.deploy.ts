import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import fs from "fs";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const [deployerSigner] = await hre.ethers.getSigners();
    const deployer = await deployerSigner.getAddress();

    console.log("\x1B[37mDeploying MockToken contract");

    // Deploy MockToken contract
    await (async function deployMockToken() {

        const mockToken = await deploy("MockToken", {
            from: deployer,
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

};

deployContracts.id = "mock_token";
deployContracts.tags = ["MockToken"];

export default deployContracts;
