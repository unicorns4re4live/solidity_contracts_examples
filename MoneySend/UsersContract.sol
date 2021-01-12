pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./FundKeeper.sol";

contract UsersContract {
    using SafeMath for uint256;

    // contract fund keeper initialization
    FundKeeper private storeContract;
    
    constructor() public payable {
        storeContract = new FundKeeper();
    }
    
    event etherTransfers(address indexed receiver, address sender);
    
    mapping (address => mapping(address => uint256)) public fundReceive; //Маппинг с суммой на вывод
    
    //Check info about fund keeper contract
    function getInfoAboutKeeperContr() public view returns (uint256, address payable) {
        return storeContract.getInfo();
    }
    
    

    //Function for making transfer request
    function transferEther(address receiver) public payable  {
        require(msg.value > 0, "Ether sent sum mustn't me equal 0");
        require(msg.sender.balance >= msg.value, "Sender balance is lower than sent sum");
        require(msg.sender != receiver, "Sender can't send ether to himself");
        
        uint256 prevValue = fundReceive[receiver][msg.sender];
        uint256 newSum = prevValue.add(msg.value);
        
        fundReceive[receiver][msg.sender] = newSum;
       
        
        address(storeContract).transfer(msg.value);
        emit etherTransfers(receiver, msg.sender);
    }
    
    
    //Accept transfer request
    function getFund(address fromWho) public payable {
        
        uint256 amount = fundReceive[msg.sender][fromWho];
        require(amount > 0, "Pay request not found");
        
        storeContract.withdraw(msg.sender, amount);
        
        
        delete(fundReceive[msg.sender][fromWho]);
    }
    
    
    
    //Cancel transfer request
    function cancelPay(address payable receiver) public {
        uint256 amount = fundReceive[receiver][msg.sender];
    
        require(amount > 0, "Pay request not found");
        
        storeContract.withdraw(msg.sender, amount);
        
        delete(fundReceive[receiver][msg.sender]);
    }
    
}
