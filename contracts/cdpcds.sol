pragma solidity ^0.4.24;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract cdpcds {

    using SafeMath for uint256;

    struct CDS {
        address maker;
        address taker;
        uint makerCollateral;
        uint takerCollateral;
        uint premium;
        bool matched;
        bool closed;
        bool matchable;
        uint orderID;
        uint expirationBounty;
        uint payed;
        uint owed;
        uint filledTime;
        uint payPeriod;
        uint expiration;
    }

    mapping(uint => CDS)allCDSs;
    mapping(address => mapping(uint => CDS))holdings;

    uint currentID = 0; 
   
    function makeCDSOrder(uint _takerCollateral, uint _premium) public payable {
        require(msg.value >= 1000000000000000);
        uint expirationBounty = msg.value.div(200);
        uint collateral = msg.value;
        collateral = collateral.sub(expirationBounty);
        allCDSs[currentID] = CDS(msg.sender, 0x0, collateral, _takerCollateral, _premium, false, true,false, currentID, expirationBounty, 0, 0, 0, 7 days,now.add(90 days));
        currentID += 1;
    }

    function fillCDSOrder(uint _ID)public payable returns (bool){
        require (msg.value >= allCDSs[_ID].takerCollateral);
        require(allCDSs[_ID].matchable==true);
        allCDSs[_ID].filledTime = block.timestamp;
        allCDSs[_ID].matched = true;
        allCDSs[_ID].matchable = false;
        allCDSs[_ID].taker = msg.sender;
        holdings[msg.sender][_ID] = allCDSs[_ID];

        
        return true;
    }

    function cancelCDSOrder(uint _ID) public returns (bool){
        require(allCDSs[_ID].maker == msg.sender);
        allCDSs[_ID].matchable =false ;
        uint toTransfer = allCDSs[_ID].makerCollateral;
        allCDSs[_ID].makerCollateral = 0;
        allCDSs[_ID].maker.transfer(toTransfer);
        return true;        
    }
    
    function addMakerCollateral(uint _ID)public payable returns (bool){
        require(msg.value >=0);
        require(msg.sender == allCDSs[_ID].maker);
        allCDSs[_ID].makerCollateral.add(msg.value);
    }

    function addMakerCollateralTo(uint _ID, address _to) public payable returns(bool){
        require(msg.value >=0);
        require(_to == allCDSs[_ID].maker);
        allCDSs[_ID].makerCollateral.add(msg.value);
    }
    
    function addTakerCollateral(uint _ID)public payable returns (bool){
        require(msg.value >=0);
        require(msg.sender == allCDSs[_ID].taker);
        allCDSs[_ID].takerCollateral.add(msg.value);
    }

    function addTakerCollateralTo(uint _ID, address _to) public payable returns(bool){
        require(msg.value >=0);
        require(_to == allCDSs[_ID].taker);
        allCDSs[_ID].takerCollateral.add(msg.value);
    }

    function _calculateOwed(uint _ID)internal view returns(uint){
        uint start = allCDSs[_ID].filledTime;
        uint current = block.timestamp > allCDSs[_ID].expiration ? allCDSs[_ID].expiration : block.timestamp;
        uint delta = current.sub(start);
        uint owedPeriod = uint(delta).div(uint(allCDSs[_ID].payPeriod).mul(86400));
        uint outstanding = (owedPeriod.mul(allCDSs[_ID].premium)).sub(allCDSs[_ID].payed);
        return outstanding;
    }

    function close(uint _ID)public {
        bool flag = requestPremium(_ID);        
        if(allCDSs[_ID].expiration > block.timestamp){
            require(msg.sender == allCDSs[_ID].maker);
            if(!flag){
                uint earlyTermFee = (allCDSs[_ID].makerCollateral.mul(13)).div(100);
                allCDSs[_ID].makerCollateral.sub(earlyTermFee);
                allCDSs[_ID].takerCollateral.add(earlyTermFee);
                uint makerPayout = allCDSs[_ID].makerCollateral;
                allCDSs[_ID].makerCollateral = 0;
                allCDSs[_ID].maker.transfer(makerPayout);
            }
        }
        else{
            msg.sender.transfer(allCDSs[_ID].expirationBounty);
            allCDSs[_ID].matched = false;
            allCDSs[_ID].matchable = false;
            allCDSs[_ID].closed = true;
        }
        allCDSs[_ID].takerCollateral=0;
        allCDSs[_ID].taker.transfer(allCDSs[_ID].takerCollateral);
    }
    function requestPremium(uint _ID)public returns(bool){
        uint owed = _calculateOwed(_ID);
        require(owed > 0);
        if(owed > allCDSs[_ID].takerCollateral){            
            uint collateral = allCDSs[_ID].takerCollateral;
            allCDSs[_ID].takerCollateral = 0;
            allCDSs[_ID].closed = true;
            allCDSs[_ID].matched = false;
            allCDSs[_ID].matchable = false;
            if(collateral > 0){
                allCDSs[_ID].maker.transfer(collateral);
            }
            return(true);            
        }
        else{//Fix Later
            allCDSs[_ID].maker.transfer(owed);
            allCDSs[_ID].payed.add(owed);
            return(false);
        }
    }
    

}
