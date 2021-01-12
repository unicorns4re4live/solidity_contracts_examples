pragma solidity ^0.5.0;

import "./UsersContract.sol";

contract FundKeeper {
  function() payable external {}
    
  address payable usersContractAddress;
    
  constructor() public payable {
    usersContractAddress = msg.sender;
  }

  function getInfo() public view returns (uint256, address payable) {
    return (address(this).balance, usersContractAddress);   
  }
    
    
  //Withdraw func   
  function withdraw(address payable receiver, uint256 amount) external payable{
    require(msg.sender == usersContractAddress, "You can call this func only from usersContract");
   
    require(amount > 0, "Withdraw sum mustn't be equal 0");
    require(amount <= address(this).balance, "Withdraw sum must be lower than contract balance");
       
    receiver.transfer(amount);
  }
}
