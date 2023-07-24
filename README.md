# FundWise Smart Contract - Crowdfunding

The CrowdfundingWithEth smart contract is a decentralized crowdfunding contract that allows users to create and participate in crowdfunding campaigns using Ether (ETH).

## Features
- Create crowdfunding campaigns with a specified target amount.
- Contribute to ongoing campaigns by sending Ether.
- Contract earns interest on contributions through the Aave protocol.
- Claim participation certificates after a campaign is completed successfully.
- Withdraw contributed funds if the campaign fails.
- Allow the campaign receiver to withdraw the raised funds after successful completion.

## External Dependencies
1.  [OpenZeppelin](https://docs.openzeppelin.com/): The contract imports various libraries and contracts from the OpenZeppelin library, including `Ownable`, `ERC721`, `Clones` 

2.  [Aave](https://docs.aave.com/developers/v/2.0/the-core-protocol/weth-gateway): The contract integrates with the Aave V2 lending protocol to deposit ETH and generate interest for the contract. 


## Set up
copy `.env.exmaple` contents to `.env` file and add the relevant keys. Use the scripts from `package.json` file for relevant task


## Contract Deployment
The contract is deployed on the network with the following initial parameters:

1. LENDING_POOL_PROVIDER_ADDRESS: Aave Lending Pool provider contract address.
2. AAVE_V2_ADDRESS: Aave V2 contract address.
3. AAVE_ATOKEN_ADDRESS: Aave aToken contract address.

## Future scope
1. Add another type of crowdfunding contract which allows users to create a fundraiser using stable coins.
