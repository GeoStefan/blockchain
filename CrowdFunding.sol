pragma solidity >=0.5.5 <=0.5.11;

contract CrowdFunding {
    struct Contribuitor {
        string name;
        address userAddress;
    }
    enum Status { Open, Finalised }

    uint256 public fundingGoal;
    address private admin;
    Contribuitor[] public contribuitors;
    mapping(address => uint128) public amounts;
    Status private status;

    event CreateContribution(string userName, address userAddress, uint256 amount);
    event DeleteContribution(address userAddress, uint256 amount);
    event CrowdFundingFinalised(uint amount);
    event TransferFunds(uint256);

    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin operation");
        _;
    }

    constructor(uint256 _fundingGoal) public {
        fundingGoal = _fundingGoal;
        status = Status.Open;
        admin = msg.sender;
    }

    function createFunding(string calldata name) external payable {
        require(msg.value > 0, "Contribution should be greater than 0 wei");
        require(status == Status.Open, "Cannot create funding after goal is achieved");
        require(address(this).balance <= fundingGoal, "Contribution is too big");

        emit CreateContribution(name, msg.sender, msg.value);
        _addContribuitor(msg.sender, name);
        amounts[msg.sender] += (uint128)(msg.value);
        _setFundingStatus();
    }

    function deleteFunding() external {
        address payable user = msg.sender;
        require(amounts[user] != 0, "Contribution amount is 0 Wei");
        require(!_isFundingGoalAchieved(), "Cannot delete funding after goal is achieved");

        uint128 donation = amounts[user];
        emit DeleteContribution(user, donation);
        delete amounts[user];
        _removeContribuitor(msg.sender);
        user.transfer(donation);
    }

    function transferFundings(address payable distributeFundingContract) external onlyAdmin {
        require(_isFundingGoalAchieved(), "Funding goal wasn't achieved");
        require(distributeFundingContract != address(0), "Invalid contract address(0)");

        emit TransferFunds(fundingGoal);
        distributeFundingContract.transfer(fundingGoal);
    }

    function getAmount() external view returns(uint) {
        return address(this).balance;
    }

    function getStatus() external view returns (string memory) {
        if(status == Status.Finalised) {
            return "Finalised";
        } else {
            return "Open";
        }
    }

    function getContribuitorsNumber() external view returns(uint) {
        return contribuitors.length;
    }

    function _isFundingGoalAchieved() internal view returns (bool) {
        return fundingGoal == address(this).balance;
    }

    function _addContribuitor(address user, string memory name) internal{
        if(amounts[user] == 0) {
            Contribuitor memory contribuitor = Contribuitor({name: name, userAddress: user});
            contribuitors.push(contribuitor);
        }
    }

    function _removeContribuitor(address user) internal {
        uint contribuitorsLength = contribuitors.length;
        if(contribuitorsLength > 1) {
            for(uint i = 0; i < contribuitorsLength; i++) {
                if(contribuitors[i].userAddress == user) {
                    contribuitors[i] = contribuitors[contribuitorsLength - 1];
                    break;
                }
            }
        }
        contribuitors.length--;
    }

    function _setFundingStatus() internal {
        if(_isFundingGoalAchieved()) {
            emit CrowdFundingFinalised(fundingGoal);
            status = Status.Finalised;
        }
    }
}