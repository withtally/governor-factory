import { time } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

import type { Lock } from "../../types/contracts/lock/Lock";
import type { Lock__factory } from "../../types/factories/contracts/lock/Lock__factory";

export async function deployLockFixture() {
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const ONE_GWEI = 1_000_000_000;

  const lockedAmount = ONE_GWEI;
  const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

  // Contracts are deployed using the first signer/account by default
  const [owner, otherAccount] = await ethers.getSigners();

  const LockFactory = (await ethers.getContractFactory("Lock", owner)) as Lock__factory;
  const lock = (await LockFactory.deploy()) as Lock;

  // Initialize the deployed Lock contract
  await lock.initialize(unlockTime, { value: lockedAmount });

  const lock_address = await lock.getAddress();  // Use .address to get the contract address

  return { lock, lock_address, unlockTime, lockedAmount, owner, otherAccount };
}
