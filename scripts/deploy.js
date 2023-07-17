const { ethers, network } = require("hardhat");
const { verify } = require("../utils/verify");

async function main() {
    const { AAVE_V2_ADDRESS, AAVE_ATOKEN_ADDRESS, LENDING_POOL_PROVIDER_ADDRESS } = network.config.constants;

    // Compile the contract
    const CrowdfundingWithEthImplementation = await ethers.getContractFactory("CrowdfundingWithEth");

    // Deploy the contract
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

    // Compile the contract
    const CrowdfundingFactoryContract = await ethers.getContractFactory("CrowdfundingFactoryContract");
    const crowdfundingFactoryContract = await CrowdfundingFactoryContract.deploy(crowdfundingWithEthAddress);

    await crowdfundingFactoryContract.deployed();

    console.log({
        crowdfundingFactoryContract: crowdfundingFactoryContract.address,
    });

    // Wait for five confirmations of the contract deployment
    await crowdfundingWithEthImplementation.deployTransaction.wait(5);

    // Verify the contract if network is not hardhat
    if (network.name !== "hardhat" && process.env.ETHERSCAN_API_KEY) {
        await verify(crowdfundingWithEthAddress, [AAVE_V2_ADDRESS, AAVE_ATOKEN_ADDRESS, LENDING_POOL_PROVIDER_ADDRESS]);
    }

    // Wait for five confirmations of the contract deployment
    await crowdfundingFactoryContract.deployTransaction.wait(5);

    // Verify the contract if network is not hardhat
    if (network.name !== "hardhat" && process.env.ETHERSCAN_API_KEY) {
        await verify(crowdfundingFactoryContract.address, [crowdfundingWithEthAddress]);
    }
}

// Run the deployment script
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
