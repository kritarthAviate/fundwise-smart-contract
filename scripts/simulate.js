// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, network } = require("hardhat");

async function main() {
  const {
    AAVE_V2_ADDRESS,
    AAVE_ATOKEN_ADDRESS,
    LENDING_POOL_PROVIDER_ADDRESS,
  } = network.config.constants;
  const [deployer] = await ethers.getSigners();

  const CrowdfundingWithEthImplementation = await ethers.getContractFactory(
    "CrowdfundingWithEth"
  );
  const crowdfundingWithEth = await CrowdfundingWithEthImplementation.deploy(
    AAVE_V2_ADDRESS,
    AAVE_ATOKEN_ADDRESS,
    LENDING_POOL_PROVIDER_ADDRESS
  );
  const crowdfundingWithEthAddress = await crowdfundingWithEth.getAddress();
  console.log({
    crowdfundingWithEth: crowdfundingWithEthAddress,
    deployer: deployer.address,
    owner: await crowdfundingWithEth.owner(),
  });

  const CrowdfundingFactoryContract = await ethers.getContractFactory(
    "CrowdfundingFactoryContract"
  );
  const crowdfundingFactoryContract = await CrowdfundingFactoryContract.deploy(
    crowdfundingWithEthAddress
  );

  const crowdfundingFactoryContractAddress =
    await crowdfundingFactoryContract.getAddress();

  console.log({
    crowdfundingFactoryContract: crowdfundingFactoryContractAddress,
  });

  const txnForEthProxy = await crowdfundingFactoryContract.createFund(
    1,
    2,
    "ipfs_Ka_Hash"
  );
  const receiptForEthProxy = await txnForEthProxy.wait();
  console.log({
    receiptForEthProxy,
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
