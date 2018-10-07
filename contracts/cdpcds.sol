pragma solidity ^0.4.24

contract cdpcds {

     
    struct CDS{
        address maker;
        uint makerCollateral;
        uint takerCollateral;
        uint premium;
        bool matched;
        bool matchable;
        uint orderID;
        uint nextPay;
    }

    mapping(uint => CDS)allCDSs;
    mapping(address => mapping(uint => CDS))holdings;

    uint currentID = 0; 
   
    function makeCDSOrder(uint _takerCollateral, uint _premium) public payable {
        uint collateral = msg.value;
        
        allCDSs[currentID] = CDS(msg.sender, collateral, _takerCollateral, _premium, false, true, currentID);
        currentID += 1;
    }

    function fillCDSOrder(uint _ID)public payable returns (bool){
        require (msg.value >= allCDSs[_ID].takerCollateral);
        require(allCDSs[_ID].matchable==true);
        allCDSs[_ID].matched = true;
        allCDSs[_ID].matchable = false;
        holdings[msg.sender][_ID] = allCDSs[_ID];
        
        return true;
    }

    function cancelCDSOrder(uint _ID) public returns (bool){
        require(allCDSs[_ID].maker == msg.sender);
        allCDSs[_ID].matchable =false ;
        allCDSs[_ID].maker.transfer(allCDSs[_ID].makerCollateral);
    }
    
    function addCollateral(uint _ID)


}
