// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, network } = require("hardhat");
const { getProxyAddress } = require("../utils");
const ProxyContractABI =
    require("../artifacts/contracts/fundWithEther/CrowdfundingWithEth.sol/CrowdfundingWithEth.json").abi;

async function main() {
    console.log("------Simulating deployment of CrowdfundingWithEth and CrowdfundingFactoryContract------");
    const { AAVE_V2_ADDRESS, AAVE_ATOKEN_ADDRESS, LENDING_POOL_PROVIDER_ADDRESS } = network.config.constants;
    const [deployer, signer1, signer2] = await ethers.getSigners();
    console.log({
        deployer: deployer.address,
        signer1: signer1.address,
        signer2: signer2.address,
    });

    const CrowdfundingWithEthImplementation = await ethers.getContractFactory("CrowdfundingWithEth");
    const crowdfundingWithEthImplementation = await CrowdfundingWithEthImplementation.deploy(
        AAVE_V2_ADDRESS,
        AAVE_ATOKEN_ADDRESS,
        LENDING_POOL_PROVIDER_ADDRESS
    );
    await crowdfundingWithEthImplementation.deployed();

    const crowdfundingWithEthAddress = crowdfundingWithEthImplementation.address;

    console.log({
        crowdfundingWithEthImplementation: crowdfundingWithEthAddress,
        ownerOfImplementation: await crowdfundingWithEthImplementation.owner(),
    });

    const CrowdfundingFactoryContract = await ethers.getContractFactory("CrowdfundingFactoryContract");
    const crowdfundingFactoryContract = await CrowdfundingFactoryContract.deploy(crowdfundingWithEthAddress);

    await crowdfundingFactoryContract.deployed();

    console.log({
        crowdfundingFactoryContract: crowdfundingFactoryContract.address,
    });

    const txnForEthProxy = await crowdfundingFactoryContract
        .connect(signer1)
        .createFund(1, 2, "ipfs_Ka_Hash", signer2.address);
    const receiptForEthProxy = await txnForEthProxy.wait();
    const proxyAddress = getProxyAddress(receiptForEthProxy);
    const proxyContract = new ethers.Contract(proxyAddress, ProxyContractABI, deployer);
    console.log({
        proxyAddress: proxyContract.address,
        owner: await proxyContract.creatorAddress(),
        beneficiary: await proxyContract.receiver(),
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
