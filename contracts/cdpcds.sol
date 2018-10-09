pragma solidity ^0.4.24;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract cdpcds {
    //THIS IS AN ADDITION
    using SafeMath for uint256;

    struct CDS {
        address maker;
        address taker;
        uint makerCollateral;
        uint takerCollateral;
        uint premium;
        //0=unmatched, 1=matched+open, 2=closed
        uint status;
        uint orderID;
        uint payed;
        uint owed;
        uint filledTime;
        uint payPeriod;
        uint expiration;
        uint cdpID;
        //uint expirationBounty;
    }

    mapping(uint => CDS)allCDSs;

    uint currentID = 0; 
   
    function makeCDSOrder(uint _premium)public payable {
        require(msg.value >= 1000000000000000);
        uint collateral = msg.value;
        allCDSs[currentID] = CDS(msg.sender, 0x0, collateral, 0, _premium, 0, currentID, 0, 0, 0, 7 days,now.add(90 days),2773);
        currentID = currentID.add(1);
    }
    //HELPER SHOW INFO FUNCTION::

    function getCDS(uint _ID)public view returns(address, address, uint, uint ){
        return (allCDSs[_ID].maker,allCDSs[_ID].taker, allCDSs[_ID].makerCollateral, allCDSs[_ID].takerCollateral);
    }
    
    //END HLPERS
    function fillCDSOrder(uint _ID)public payable returns (bool){
        require (msg.value >= allCDSs[_ID].premium);
        require(allCDSs[_ID].status==0);
        allCDSs[_ID].takerCollateral = allCDSs[_ID].takerCollateral.add(msg.value);
        allCDSs[_ID].filledTime = block.timestamp;
        allCDSs[_ID].status = 1;
        allCDSs[_ID].taker = msg.sender;
        return true;
    }

    function cancelCDSOrder(uint _ID) public returns (bool){
        require(allCDSs[_ID].maker == msg.sender);
        allCDSs[_ID].status=2;
        uint toTransfer = allCDSs[_ID].makerCollateral;
        allCDSs[_ID].makerCollateral = 0;
        allCDSs[_ID].maker.transfer(toTransfer);
        return true;        
    }
    
    function _calculateOwed(uint _ID)internal view returns(uint){
        uint current = block.timestamp > allCDSs[_ID].expiration ? allCDSs[_ID].expiration : block.timestamp;
        uint delta = current.sub(allCDSs[_ID].filledTime);
        uint owedPayments = uint(delta).div(uint(allCDSs[_ID].payPeriod).mul(86400));
        uint outstanding = (owedPayments.mul(allCDSs[_ID].premium)).sub(allCDSs[_ID].payed);
        return outstanding;
    }

    function close(uint _ID)public {
        require(msg.sender == allCDSs[_ID].maker);
        bool underCollateral = requestPremium(_ID); //requestPremium requires no outstanding balance. stack is cleared and state is reversted. need another solution       
        if(!underCollateral && (block.timestamp < allCDSs[_ID].expiration)){
            uint earlyTermFee = (allCDSs[_ID].makerCollateral.mul(13)).div(100);
            allCDSs[_ID].makerCollateral = allCDSs[_ID].makerCollateral.sub(earlyTermFee);
            allCDSs[_ID].takerCollateral = allCDSs[_ID].takerCollateral.add(earlyTermFee);                              
        }
        //msg.sender.transfer(allCDSs[_ID].expirationBounty);
        allCDSs[_ID].status=2;
        uint takerPayout = allCDSs[_ID].takerCollateral;
        allCDSs[_ID].takerCollateral = 0;
        allCDSs[_ID].taker.transfer(takerPayout);
        uint makerPayout = allCDSs[_ID].makerCollateral;
        allCDSs[_ID].makerCollateral = 0;
        allCDSs[_ID].maker.transfer(makerPayout);
    }

    function requestPremium(uint _ID)public returns(bool){
        uint owed = _calculateOwed(_ID);
        uint collateral = allCDSs[_ID].takerCollateral;

        if(owed==0) return(false);
        if(owed > collateral){            
            allCDSs[_ID].takerCollateral = 0;
            if(collateral>0) allCDSs[_ID].maker.transfer(collateral);
            return(true);			             
        }
        if(owed <= collateral){//Fix Later
            allCDSs[_ID].takerCollateral = allCDSs[_ID].takerCollateral.sub(owed);
            allCDSs[_ID].payed = allCDSs[_ID].payed.add(owed);
            allCDSs[_ID].maker.transfer(owed);            
            return(false);
        }
    }

    function reportLiquidation(uint _ID)public returns(bool){
        uint collateral = allCDSs[_ID].makerCollateral;
        allCDSs[_ID].takerCollateral = collateral.add(allCDSs[_ID].takerCollateral);
        allCDSs[_ID].makerCollateral = 0;
        uint takerPayout = allCDSs[_ID].takerCollateral;
        allCDSs[_ID].takerCollateral = 0;
        allCDSs[_ID].taker.transfer(takerPayout);
        allCDSs[_ID].status=2;
    }
    

    /* function addMakerCollateral(uint _ID)public payable returns (bool){
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
    } */
}