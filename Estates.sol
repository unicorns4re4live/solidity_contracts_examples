pragma solidity ^0.6.0;

contract RentContract {
    struct Estate {
        uint256 estateId;
        address owner;
        string info;
        uint256 square;
        uint256 usefulSquare;
        bool presentStatus;
        bool saleStatus;
    }
    
    struct Present {
        uint256 estateId;
        address addressFrom;
        address addressTo;
        bool finished;
    }
    
    struct Sale {
        uint256 estateId;
        address owner;
        uint256 price;
        address payable[] customers;
        uint256[] prices;
        bool finished;
    }
    
    
    Estate[] estates;
    Present[] presents;
    Sale[] sales;
    
    
    address admin;
    
    constructor() public {
        admin = msg.sender;
    }
    
    
    //MODIFIERS
    modifier isAdmin {
        require(msg.sender == admin, "You aren't admin");
        _;
    }
    
    modifier isOk(uint256 estateId) {
        require(estates[estateId].presentStatus == false, "Estate presented to someone");
        _;
    }
    
    modifier isOwner(uint256 estateId) {
        require(estates[estateId].owner == msg.sender, "You aren't owner of this estate");
        _;
    }
    
    //GET NUMBER FUNCTIONS
    function getEstatesNumber() public view returns(uint256) {
        return estates.length;
    }
    
    function getPresentsNumber() public view returns(uint256) {
        return presents.length;
    }
    
    function getSalesNumber() public view returns(uint256) {
        return sales.length;
    }
    
    //GET FUNCTIONS
    function getEstate(uint256 estateNum) public view returns(uint256, address, string memory, uint256, uint256) {
        Estate memory estate = estates[estateNum];
        return (estate.estateId, estate.owner, estate.info, estate.square, estate.usefulSquare);
    }
    
    function getPresent(uint256 presentNum) public view returns(uint256, address, address, bool) {
        Present memory present = presents[presentNum];
        return (present.estateId, present.addressFrom, present.addressTo, present.finished);
    }
    
    function getSale(uint256 saleNum) public view returns(uint256, address, uint256, address payable[] memory, uint256[] memory, bool) {
        Sale memory sale = sales[saleNum];
        return (sale.estateId, sale.owner, sale.price, sale.customers, sale.prices, sale.finished);
        
    }
    
    
    
    //ADMIN FUNCTIONS
    function createEstate(address _owner, string memory _info, uint256 _square, uint256 _usefulSquare) public isAdmin {
        require(_usefulSquare <= _square, "Useful square can't be higher than square");
        Estate memory newEstate = Estate(estates.length, _owner, _info, _square, _usefulSquare, false, false);
        estates.push(newEstate);
    }
    
    
    //PRESENT FUNCTIONS
    //Create present
    function createPresent(uint256 estateId, address addressTo) public isOk(estateId) isOwner(estateId) {
        Present memory newPresent = Present(estateId, msg.sender, addressTo, false);
        presents.push(newPresent);
        estates[estateId].presentStatus = true;
    }
    
    //Owner of present can cancel it
    function cancelPresent(uint256 presentNum) public {
        require(msg.sender == presents[presentNum].addressFrom, "You aren't owner of this present");
        require(presents[presentNum].finished == false, "Present already has been accepted");
        estates[presents[presentNum].estateId].presentStatus = false;
        presents[presentNum].finished = true;
    }
    
    //Gift acceptance
    function acceptPresent(uint256 presentNum) public {
        require(msg.sender == presents[presentNum].addressTo, "This present isn't for you :)");
        require(presents[presentNum].finished == false, "Present already has been accepted");
        uint256 estateid = presents[presentNum].estateId;
        estates[estateid].owner = msg.sender;
        estates[estateid].presentStatus = false;
        presents[presentNum].finished = true;
    }
    
    
    //SALE FUNCTIONS
    //Create sale
    function createSale(uint256 estateId, uint256 price) public isOk(estateId) isOwner(estateId) {
        address payable[] memory customers;
        uint256[] memory prices;
        Sale memory newSale = Sale(estateId, msg.sender, price, customers, prices, false);
        sales.push(newSale);
        estates[estateId].saleStatus = true;
    }
    
    //Cancel sale
    function cancelSale(uint256 saleNum) public {
        require(msg.sender == sales[saleNum].owner, "You aren't owner");
        require(sales[saleNum].finished == false, "Sale already has been finished");
        address payable[] memory customers = sales[saleNum].customers;
        for (uint256 i = 0; i < customers.length; i++) {
            customers[i].transfer(sales[saleNum].prices[i]);
        }
        estates[sales[saleNum].estateId].saleStatus = false;
        sales[saleNum].finished = true;
    }
    
    //Customer send money to buy
    function buyOrder(uint256 saleNum) public payable {
        require(msg.sender != sales[saleNum].owner, "Owner can't buy it's own estate");
        require(msg.value >= sales[saleNum].price, "Sum you sent isn't enough");
        require(sales[saleNum].finished == false, "Sale has beed finished");
        address payable[] memory customers = sales[saleNum].customers;
        for(uint256 i = 0; i < customers.length; i++) {
            if(customers[i] == msg.sender) {
                revert("You already have been paid money");
            }
        }
        sales[saleNum].customers.push(msg.sender);
        sales[saleNum].prices.push(msg.value);
    }
    
    //Customer canl buy order
    function cancelBuyorder(uint256 saleNum) public payable {
        require(sales[saleNum].finished == false, "Sale has been finished");
        address payable[] memory customers = sales[saleNum].customers;
        for(uint256 i = 0; i < customers.length; i++) {
            if(customers[i] == msg.sender) {
                msg.sender.transfer(sales[saleNum].prices[i]);
                delete sales[saleNum].prices[i];
                delete sales[saleNum].customers[i];
            }
        }
    }
    
    //Confirm sale to customer(id)
    function confirmSale(uint256 saleNum, uint256 customerNum) public payable {
        Sale memory sale = sales[saleNum];
        require(msg.sender == sale.owner, "You aren't estate owner");
        require(sale.prices[customerNum] > 0, "Customer got money back");
        require(sale.finished == false, "Sale has been finished");
        estates[sale.estateId].owner = sale.customers[customerNum];
        msg.sender.transfer(sale.prices[customerNum]);
        for(uint256 i = 0; i < sale.customers.length; i++) {
            if(i != customerNum) {
                sale.customers[i].transfer(sale.prices[i]);
            } else {
                delete sales[saleNum].prices[customerNum];
            }
        }
        
        estates[sale.estateId].saleStatus = false;
        sales[saleNum].finished = true;
    }
}