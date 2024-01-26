import { expect } from "chai";
import { deployMockFactoryFixture } from "./Factory.fixture";

describe("Factory Contract", function () {
    beforeEach(async function () {
        const { factory, deployer, implementationAddress } = await deployMockFactoryFixture();
        this.factory = factory;
        this.deployer = deployer;
        this.implementationAddress = implementationAddress;
    });

    describe("Deployment", function () {
        it("Should set the right implementation address", async function () {
            expect(await this.factory.implementation()).to.equal(this.implementationAddress);
        });

        it("Should assign the deployer as the admin", async function () {
            expect(await this.factory.hasRole(await this.factory.DEFAULT_ADMIN_ROLE(), this.deployer.address)).to.be.true;
        });
    });

    describe("Implementation Update", function () {
        it("Should update the implementation address", async function () {
            const newImplementationAddress = this.deployer.address; // Replace with new implementation address
            await expect(this.factory.updateImplementation(newImplementationAddress))
                .to.emit(this.factory, "ImplementationStored")
                .withArgs(newImplementationAddress);
            expect(await this.factory.implementation()).to.equal(newImplementationAddress);
        });
    });

    // Add more test cases as needed...
});
