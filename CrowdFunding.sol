pragma solidity >=0.5.5 <=0.5.11;

contract CrowdFunding {
    struct Contribuitor {
        string name;
    }
    uint256 public fundingGoal;
    uint256 public raisedFunds;
    mapping(address => Contribuitor) public contribuitors;
    mapping(address => uint128) public amount;
    address private admin;

    event CreateContribution(string, address, uint256);
    event DeleteContribution(string, address, uint256);
    event TransferFunds(uint256);

    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin operation");
        _;
    }

    constructor(uint256 _fundingGoal) public {
        fundingGoal = _fundingGoal;
        admin = msg.sender;
    }

    function createFunding(address id, string calldata name) external payable {
        require(id != address(0), "Contribuitor cannot be 0x address");
        Contribuitor storage contribuitor = contribuitors[id];
        emit CreateContribution(name, id, msg.value);
        contribuitor.name = name;
        amount[id] += (uint128)(msg.value);
        raisedFunds += (uint128)(msg.value);
    }

    function deleteFunding(address id) external {
        require(amount[id] != 0, "Contribution amount is 0 Wei");
        uint128 donation = amount[id];
        emit DeleteContribution(contribuitors[id].name, id, donation);
        delete amount[id];
        delete contribuitors[id];
        raisedFunds -= donation;
    }

    function transferFundings(address payable distributeFundingContract) public {
        require(raisedFunds == fundingGoal, "Funding goal wasn't achieved");
        require(distributeFundingContract != address(0), "Invalid contract address(0)");
        raisedFunds = 0;
        emit TransferFunds(fundingGoal);
        distributeFundingContract.transfer(fundingGoal);
    }
}