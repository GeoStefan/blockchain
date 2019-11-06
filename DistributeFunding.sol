pragma solidity >=0.5.5 <=0.5.11;

contract DistributeFunding {

    uint8 leftBusinessPercentage;
    mapping (address => uint) pendingWithdrawals;
    uint256 public finalCrowdfundingAmount;
    address private admin;

    constructor() public {
        leftBusinessPercentage = 100;
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin operation");
        _;
    }

    function becomeShareholder(uint8 percentage) external {
        require(percentage > 0, "Percentage should be positive");
        require(percentage <= leftBusinessPercentage, "Not enough shares left");
        leftBusinessPercentage -= percentage;
        pendingWithdrawals[msg.sender] = percentage;
    }

    function withdrawShareholderMoney() external {
        require(finalCrowdfundingAmount > 0, "Funds have not been transfered");
        uint amountToSend = pendingWithdrawals[msg.sender] * finalCrowdfundingAmount / 100;
        require(amountToSend > 0, "Amount is 0");

        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amountToSend);
    }

    function setFinalCrowdfundingAmount() external onlyAdmin {
        uint amount = address(this).balance;
        require(amount > 0, "Contract has no funds");
        finalCrowdfundingAmount = amount;
    }

    function () payable external {
    }
}