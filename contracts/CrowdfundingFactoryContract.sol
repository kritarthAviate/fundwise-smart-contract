// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./fundWithEther/CrowdfundingWithEth.sol";
import "./MinimalProxy.sol";

/**
 * @title CrowdfundingFactoryContract
 * @notice Factory contract for creating crowdfunding campaigns.
 */
contract CrowdfundingFactoryContract is Ownable {
    using Clones for address;

    address public fundWithEtherImplementationAddress;
    address public fundWithTokenImplementationAddress;

    event FundCreated(
        address indexed proxyAddress,
        address indexed ownerAddress,
        address indexed receiver,
        uint8 typeOfFunding,
        uint256 createdAt,
        uint256 targetAmount,
        string ipfsLink
    );

    constructor(address _fundWithEtherImplementationAddress) {
        fundWithEtherImplementationAddress = _fundWithEtherImplementationAddress;
    }

    /**
     * @notice Creates a new crowdfunding campaign.
     * @param _typeOfFunding The type of funding (1 for ETH, 2 for Token).
     * @param _targetAmount The target amount to be raised.
     * @param _ipfsLink The IPFS link associated with the campaign details.
     * @param _receiver The address of the receiver or beneficiary of the raised funds.
     * @return The address of the newly created crowdfunding campaign.
     */
    function createFund(
        uint8 _typeOfFunding,
        uint256 _targetAmount,
        string memory _ipfsLink,
        address _receiver
    ) public returns (address) {
        require(_typeOfFunding == 1 || _typeOfFunding == 2, "Invalid type of funding");
        if (_typeOfFunding == 1) {
            address payable proxy = payable(fundWithEtherImplementationAddress.clone());
            CrowdfundingWithEth(proxy).initialize(_receiver, _targetAmount, _ipfsLink, msg.sender);
            emit FundCreated(proxy, msg.sender, _receiver, _typeOfFunding, block.timestamp, _targetAmount, _ipfsLink);
            return proxy;
        } else {
            address payable proxy = payable(fundWithTokenImplementationAddress.clone());
            CrowdfundingWithEth(proxy).initialize(_receiver, _targetAmount, _ipfsLink, msg.sender);
            emit FundCreated(proxy, msg.sender, _receiver, _typeOfFunding, block.timestamp, _targetAmount, _ipfsLink);
            return proxy;
        }
    }

    /**
     * @notice Updates the addresses of the crowdfunding templates.
     * @param _newImplementationAddress The new address of the template contract.
     * @param _typeofFunding The type of funding (1 for ETH, 2 for Token).
     */
    function updateTemplateAddresses(address _newImplementationAddress, uint8 _typeofFunding) public onlyOwner {
        if (_typeofFunding == 1) {
            fundWithEtherImplementationAddress = _newImplementationAddress;
        } else if (_typeofFunding == 2) {
            fundWithTokenImplementationAddress = _newImplementationAddress;
        }
    }
}
