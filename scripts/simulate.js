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
  console.log({ CrowdfundingWithEthImplementation });
  const crowdfundingWithEth = await CrowdfundingWithEthImplementation.deploy(
    AAVE_V2_ADDRESS,
    AAVE_ATOKEN_ADDRESS,
    LENDING_POOL_PROVIDER_ADDRESS
  );
  console.log({ crowdfundingWithEth });
  await crowdfundingWithEth.deployed();
  console.log({
    crowdfundingWithEth: crowdfundingWithEth.address,
    deployer: deployer.address,
    owner: await crowdfundingWithEth.owner(),
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
