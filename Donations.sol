pragma solidity ^0.7.0;


contract Donations {
    address payable public owner;
    
    //Persons, who donated more than 10 ethers
    address[] public donators;
    
    uint256 donationSum = 0;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier isOwner() {
        require(msg.sender == owner, "You aren't contract owner");
        _;
    }
    
    function withdrawDonations() public isOwner payable {
        owner.transfer(address(this).balance);
    }
    
    //Function to accept donation
    function getDonation() public payable {
        if(msg.value > 10 ether) {
            donators.push(msg.sender);
        }
        donationSum+=msg.value;
    }
    
    function showDonators() public view returns(address[] memory) {
        return donators;
    }
    
    function showBalance() public view returns(uint256) {
        return donationSum;
    }
}
