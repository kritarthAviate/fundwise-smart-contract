// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IAaveV2.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";

contract CrowdfundingWithEth is Initializable, Ownable, ERC721 {
    using Strings for uint256;

    // Aave V2 interface for interacting with Aave protocol
    IAaveV2 private immutable iAaveV2;
    // Aave aToken interface for interacting with aToken
    IERC20 private immutable iAToken;
    // LendingPoolAddressesProvider interface for getting LendingPool address
    ILendingPoolAddressesProvider private immutable lendingPoolAddressesProvider;
    address immutable LENDING_POOL_ADDRESS;

    address public creatorAddress;
    address public receiver;
    uint256 public targetAmount;
    uint256 public amountRaised;
    Status public projectStatus;
    bool public fundsWithdrawn;
    string public ipfsLink;

    enum Status {
        ONGOING,
        COMPLETED,
        FAILED
    }

    mapping(address => uint256) public contributions;
    mapping(address => bool) public certificateClaimed;
    uint256 private totalCertificates;

    event Contribute(address indexed contributor, uint256 amount);
    event WithdrawContributions(address indexed contributor, uint256 amount);
    event WithdrawFunds(address receiver, uint256 amount);
    event ProjectCompleted(address indexed proxyAddress, address indexed receiver, uint256 timestamp);
    event ProjectInvalidated(address indexed proxyAddress, uint256 timestamp, uint8 invalidatorType);

    constructor(
        address _AAVE_V2_ADDRESS,
        address _AAVE_ATOKEN_ADDRESS,
        address _LENDING_POOL_PROVIDER_ADDRESS
    ) ERC721("Participation Certificate", "CERT") {
        iAaveV2 = IAaveV2(_AAVE_V2_ADDRESS);
        iAToken = IERC20(_AAVE_ATOKEN_ADDRESS);
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(_LENDING_POOL_PROVIDER_ADDRESS);
        LENDING_POOL_ADDRESS = getLendingPoolAddress();
    }

    function initialize(
        address _receiver,
        uint _targetAmount,
        string memory _ipfsLink,
        address _creatorAddress
    ) public initializer {
        receiver = _receiver;
        targetAmount = _targetAmount;
        projectStatus = Status.ONGOING;
        ipfsLink = _ipfsLink;
        iAToken.approve(address(iAaveV2), type(uint256).max);
        creatorAddress = _creatorAddress;
    }

    function contribute() external payable {
        require(projectStatus == Status.ONGOING, "Project status is not ongoing");

        contributions[msg.sender] += msg.value;
        amountRaised += msg.value;

        iAaveV2.depositETH{ value: msg.value }(LENDING_POOL_ADDRESS, address(this), 0);

        if (amountRaised >= targetAmount) {
            projectStatus = Status.COMPLETED;
            emit ProjectCompleted(address(this), receiver, block.timestamp);
        }

        emit Contribute(msg.sender, msg.value);
    }

    function withdrawContributions() external {
        require(projectStatus == Status.FAILED, "Project status is not failed");
        require(contributions[msg.sender] > 0, "No contributions to withdraw");

        uint256 amountToWithdraw = contributions[msg.sender];
        contributions[msg.sender] = 0;

        iAaveV2.withdrawETH(LENDING_POOL_ADDRESS, amountToWithdraw, address(this));
        payable(msg.sender).transfer(amountToWithdraw);

        amountRaised -= amountToWithdraw;

        emit WithdrawContributions(msg.sender, amountToWithdraw);
    }

    function withdrawFunds() external {
        require(projectStatus == Status.COMPLETED, "Project status is not completed");
        require(msg.sender == receiver, "Only the receiver can withdraw funds");
        require(!fundsWithdrawn, "Funds have already been withdrawn");

        fundsWithdrawn = true;

        iAaveV2.withdrawETH(LENDING_POOL_ADDRESS, amountRaised, address(this));
        payable(msg.sender).transfer(amountRaised);

        emit WithdrawFunds(msg.sender, amountRaised);
    }

    function invalidateProject() external {
        require(
            msg.sender == creatorAddress || msg.sender == super.owner(),
            "Only the creator or owner can invalidate the project"
        );

        projectStatus = Status.FAILED;

        uint8 invalidatorType;
        if (msg.sender == creatorAddress) {
            invalidatorType = 1;
        } else {
            invalidatorType = 2;
        }

        emit ProjectInvalidated(address(this), block.timestamp, invalidatorType);
    }

    function claimCertificate() external {
        require(projectStatus == Status.COMPLETED, "Project status is not completed");
        require(!certificateClaimed[msg.sender], "Certificate has already been claimed");

        certificateClaimed[msg.sender] = true;

        uint256 tokenId = totalCertificates + 1;

        _safeMint(msg.sender, tokenId);

        // Set the token metadata
        _setTokenMetadata(tokenId, contributions[msg.sender]);

        totalCertificates++;
    }

    function _setTokenMetadata(uint256 tokenId, uint256 contribution) internal {
        string memory metadata = string(
            abi.encodePacked(
                '{"name": "Participation Certificate #',
                tokenId.toString(),
                '", "description": "Certificate of participation for the crowdfunding project", "attributes": [{"trait_type": "Receiver", "value": "',
                _toString(receiver),
                '"}, {"trait_type": "Target Amount", "value": "',
                targetAmount.toString(),
                '"}, {"trait_type": "IPFS Link", "value": "',
                ipfsLink,
                '"}, {"trait_type": "Contribution", "value": "',
                contribution.toString(),
                '"}]}'
            )
        );

        _setTokenURI(tokenId, metadata);
    }

    function _toString(address _address) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }

    function getLendingPoolAddress() private view returns (address) {
        return lendingPoolAddressesProvider.getLendingPool();
    }

    receive() external payable {}
}
