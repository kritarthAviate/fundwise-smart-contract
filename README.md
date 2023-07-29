# FundWise Smart Contract - Crowdfunding

The FundWise Smart Contract is a decentralized crowdfunding contract that empowers users to create and participate in crowdfunding campaigns using Ether (ETH) as the primary currency.

[Link to frontend repo](https://github.com/kritarthAviate/fundwise-frontend)

## Features

- **Create Crowdfunding Campaigns**: Users can create crowdfunding campaigns with a specific target amount they aim to raise.

- **Contribute with Ether**: Participants can contribute to ongoing campaigns by sending Ether to the contract.

- **Interest Earnings through Aave**: The contract utilizes the Aave V2 lending protocol to deposit ETH and earn interest on the contributions.

- **Claim Participation Certificates**: Upon successful completion of a campaign, contributors can claim participation certificates as tokenized proof of their support.

- **Refund on Campaign Failure**: If a campaign fails to reach its target amount, contributors can withdraw their contributed funds.

- **Withdraw Raised Funds**: After a campaign reaches its funding goal, the campaign creator can withdraw the raised funds for the intended purpose.

## External Dependencies

1. [OpenZeppelin](https://docs.openzeppelin.com/): The contract leverages various libraries and contracts from the OpenZeppelin library, including `Ownable`, `ERC721`, and `Clones`.

2. [Aave](https://docs.aave.com/developers/v/2.0/the-core-protocol/weth-gateway): The contract integrates with the Aave V2 lending protocol to deposit ETH and generate interest for the contract.

## Set up

To set up the FundWise Smart Contract locally or deploy it to the network, follow these steps:

1. Copy the contents of `.env.example` to a new file called `.env` and add the relevant API keys or addresses.

2. Utilize the scripts from the `package.json` file for relevant tasks related to deployment or local setup.

## Contract Deployment

The contract is deployed on the network with the following initial parameters:

1. LENDING_POOL_PROVIDER_ADDRESS: Aave Lending Pool provider contract address.
2. AAVE_V2_ADDRESS: Aave V2 contract address.
3. AAVE_ATOKEN_ADDRESS: Aave aToken contract address.

Please ensure that you provide the correct values for these parameters during deployment.

## Future Scope

We have exciting plans for the future development of the FundWise Smart Contract. Some of the upcoming features include:

1. **Stablecoin Fundraising**: Adding another type of crowdfunding contract that allows users to create fundraisers using stablecoins, providing more flexibility to both creators and participants.

2. **Multi-Chain Support**: Expanding to other chains like mainnet and various layer 2 chains, enabling a wider user base to participate in crowdfunding campaigns.

We are committed to continually enhancing the FundWise Smart Contract to provide the best crowdfunding experience for our users.

If you have any questions, suggestions, or feedback, please don't hesitate to reach out. Thank you for choosing FundWise Smart Contract for your crowdfunding needs! 🌟
