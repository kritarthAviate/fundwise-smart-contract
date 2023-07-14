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
const IERC20ABI = require("../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json").abi;

async function main() {
    console.log("------Simulating deployment of CrowdfundingWithEth and CrowdfundingFactoryContract------");
    const { AAVE_V2_ADDRESS, AAVE_ATOKEN_ADDRESS, LENDING_POOL_PROVIDER_ADDRESS } = network.config.constants;
    const [deployer, signer1, signer2, signer3, signer4, signer5, signer6, signer7] = await ethers.getSigners();
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
        .createFund(1, ethers.utils.parseEther("100"), "ipfs_Ka_Hash", signer2.address);
    const receiptForEthProxy = await txnForEthProxy.wait();
    const proxyAddress = getProxyAddress(receiptForEthProxy);
    const proxyContract = new ethers.Contract(proxyAddress, ProxyContractABI, deployer);
    console.log({
        proxyAddress: proxyContract.address,
        owner: await proxyContract.creatorAddress(),
        beneficiary: await proxyContract.receiver(),
    });

    console.log("------Contributing to the fund from signer3------");
    const txnForContribution = await proxyContract.connect(signer3).contribute({ value: ethers.utils.parseEther("1") });

    console.log("------Contributing to the fund from signer4------");
    const txnForContribution2 = await proxyContract
        .connect(signer4)
        .contribute({ value: ethers.utils.parseEther("10") });

    console.log("------Contributing to the fund from signer5------");
    const txnForContribution3 = await proxyContract
        .connect(signer5)
        .contribute({ value: ethers.utils.parseEther("5") });

    console.log("------Contributing to the fund from signer6------");
    const txnForContribution4 = await proxyContract
        .connect(signer6)
        .contribute({ value: ethers.utils.parseEther("9") });

    console.log("------Contributing to the fund from signer7------");
    const txnForContribution5 = await proxyContract
        .connect(signer7)
        .contribute({ value: ethers.utils.parseEther("80") });

    // to increase block time by 1000 seconds since 0x3e8 = 1000 and 0x3c = 60 seconds in hex
    await network.provider.send("hardhat_mine", ["0x3e8", "0x3c"]);

    // init aave aToken contract
    const aTokenContract = new ethers.Contract(AAVE_ATOKEN_ADDRESS, IERC20ABI, deployer);
    // get aave aToken balance of proxy contract
    const aTokenBalanceOfProxy = await aTokenContract.balanceOf(proxyContract.address);

    console.log({
        amountRaised: ethers.utils.formatEther(await proxyContract.amountRaised()).toString(),
        projectStatus: await proxyContract.projectStatus(),
        aTokenBalanceOfProxy: ethers.utils.formatEther(aTokenBalanceOfProxy.toString()),
    });

    console.log("------Withdrawing funds from signer2------");
    const signer2BalanceBefore = await signer2.getBalance();
    console.log({ signer2BalanceBefore: ethers.utils.formatEther(signer2BalanceBefore.toString()) });
    const txnForWithdrawal = await proxyContract.connect(signer2).withdrawFunds();
    const signer2BalanceAfter = await signer2.getBalance();
    console.log({ signer2BalanceAfter: ethers.utils.formatEther(signer2BalanceAfter.toString()) });

    // call totalCertificates to get total certificates issued
    const totalCertificatesB4 = await proxyContract.getTotalCertificates();
    console.log({ totalCertificates: totalCertificatesB4.toString() });

    // call claimCertificate from signer7 to get certificate
    const txnForClaimingCertificate = await proxyContract.connect(signer7).claimCertificate();

    const certificateId = totalCertificatesB4.add(1);

    // Retrieve the token URI of the certificate
    const tokenURI = await proxyContract.tokenURI(certificateId);
    // convert the tokenURI from string to JSON
    const tokenURIJSON = JSON.parse(tokenURI);
    console.log({ tokenURI, tokenURIJSON });

    // call totalCertificates to get total certificates issued
    const totalCertificates = await proxyContract.getTotalCertificates();
    console.log({ totalCertificates: totalCertificates.toString() });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
