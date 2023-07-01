// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./interfaces/IAaveV2.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";

contract Crowdfunding is Initializable {
    // Aave V2 interface for interacting with Aave protocol
    IAaveV2 private immutable iAaveV2;
    // Aave aToken interface for interacting with aToken
    IERC20 private immutable iAToken;
    // LendingPoolAddressesProvider interface for getting LendingPool address
    ILendingPoolAddressesProvider private immutable lendingPoolAddressesProvider;
    address immutable LENDING_POOL_ADDRESS;

    address public receiver;
    uint256 public targetAmount;
    uint256 public amountRaised;
    Status public projectStatus;
    bool public fundsWithdrawn;
    string public ipfsLink;

    enum Status {ONGOING, COMPLETED, FAILED}

    mapping(address => uint256) public contributions;

    event Contribute(address indexed contributor, uint256 amount);
    event WithdrawContributions(address indexed contributor, uint256 amount);
    event WithdrawFunds(address receiver, uint256 amount);
    event ProjectStatusChanged(Status status);

    constructor(
        address _AAVE_V2_ADDRESS,
        address _AAVE_ATOKEN_ADDRESS,
        address _LENDING_POOL_PROVIDER_ADDRESS
    ) {
        iAaveV2 = IAaveV2(_AAVE_V2_ADDRESS);
        iAToken = IERC20(_AAVE_ATOKEN_ADDRESS);
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(_LENDING_POOL_PROVIDER_ADDRESS);
        LENDING_POOL_ADDRESS = getLendingPoolAddress();
    }

    function initialize(
       address _receiver,
      uint _targetAmount,
      string memory _ipfsLink
    ) public initializer {
        receiver = _receiver;
        targetAmount = _targetAmount;
        projectStatus = Status.ONGOING;
        ipfsLink = _ipfsLink;
        iAToken.approve(address(iAaveV2), type(uint256).max);
    }

    function contribute() external payable {
        require(projectStatus == Status.ONGOING, "Project status is not ongoing");

        contributions[msg.sender] += msg.value;
        amountRaised += msg.value;

        iAaveV2.depositETH{ value: msg.value }(LENDING_POOL_ADDRESS, address(this), 0);

        if (amountRaised >= targetAmount) {
            projectStatus = Status.COMPLETED;
            emit ProjectStatusChanged(projectStatus);
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

    function changeProjectStatus(Status _status) external  {
        projectStatus = _status;

        emit ProjectStatusChanged(projectStatus);
    }

    function getLendingPoolAddress() private view returns (address) {
        return lendingPoolAddressesProvider.getLendingPool();
    }
}
