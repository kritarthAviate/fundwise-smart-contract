// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./fundWithEther/CrowdfundingWithEth.sol";
import "./MinimalProxy.sol";

contract CrowdfundingFactoryContract is Ownable {
    using Clones for address;

    address public fundWithEtherImplementationAddress;
    address public fundWithTokenImplementationAddress;

    event FundCreated(
        address indexed proxyAddress,
        address indexed ownerAddress,
        uint8 indexed typeOfFunding,
        uint256 createdAt,
        uint256 targetAmount
    );

    constructor(address _fundWithEtherImplementationAddress) {
        fundWithEtherImplementationAddress = _fundWithEtherImplementationAddress;
    }
 
    function createFund(uint8 _typeOfFunding, uint256 _targetAmount, string memory _ipfsLink) public returns (address) {
        require(_typeOfFunding == 1 || _typeOfFunding == 2, "Invalid type of funding");
        if(_typeOfFunding == 1) {
            address payable proxy = payable(fundWithEtherImplementationAddress.clone());
            CrowdfundingWithEth(proxy).initialize(msg.sender, _targetAmount, _ipfsLink);
            emit FundCreated(proxy, msg.sender,_typeOfFunding, block.timestamp, _targetAmount );
            return proxy;
        } else{
            address payable proxy = payable(fundWithTokenImplementationAddress.clone());
            CrowdfundingWithEth(proxy).initialize(msg.sender, _targetAmount, _ipfsLink);
            emit FundCreated(proxy, msg.sender,_typeOfFunding, block.timestamp, _targetAmount);
            return proxy;
        }
    }

    function updateTemplateAddresses(address _newImplementationAddress, uint8 _typeofFunding) public onlyOwner {
        if(_typeofFunding == 1){
          fundWithEtherImplementationAddress = _newImplementationAddress;
        }
        else if(_typeofFunding == 2){
          fundWithTokenImplementationAddress = _newImplementationAddress;
        }
    }
}
