// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract cdpcds {
    //THIS IS AN ADDITION
    using SafeMath for uint256;
    
    address cont = this;
    uint testDate = block.timestamp;

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
    mapping(address => uint)collateralBalances; // for testing purposes

    uint currentID = 0; 
   
    function makeCDSOrder(uint _premium)public payable {
        require(msg.value >= 1e15);
        uint collateral = msg.value;
        allCDSs[currentID] = CDS(msg.sender, 0x0, collateral, 0, _premium, 0, currentID, 0, 0, 0, 7 days,now.add(35 days),2773);
        currentID = currentID.add(1);
        collateralBalances[msg.sender] = collateralBalances[msg.sender].add(msg.value);
    }
    //HELPER SHOW INFO FUNCTION::
<<<<<<< HEAD
<<<<<<< HEAD

<<<<<<< HEAD
    function getInfo(uint _ID) public view returns (address, uint, address, uint, uint, uint, uint){
        return(allCDSs[_ID].maker, allCDSs[_ID].makerCollateral, allCDSs[_ID].taker, allCDSs[_ID].takerCollateral, allCDSs[_ID].premium, allCDSs[_ID].payed, cont.balance);
    }
    //for testing...
    function getCollateralBalance(address _addr)public view returns(uint){
        return collateralBalances[_addr];
=======
    function getInfo(uint _ID) public view returns (string, uint, uint, uint, uint, uint){
        return("mkrCol,tkrCol,premium, paid, status",allCDSs[_ID].makerCollateral,allCDSs[_ID].takerCollateral,allCDSs[_ID].premium, allCDSs[_ID].payed,allCDSs[_ID].status);
    }
    
    function getMkrTkr(uint _ID) public view returns (address,address){
        return(allCDSs[_ID].maker,allCDSs[_ID].taker);
>>>>>>> 44ef0ba26072b42aba2af2ce73b20b89699b7d9f
=======
    
=======

>>>>>>> 928182a08b433068a3ccfb42e660434f53ac4258
    function getInfo(uint _ID) public view returns (address, uint, address, uint, uint, uint, uint){
        return(allCDSs[_ID].maker, allCDSs[_ID].makerCollateral, allCDSs[_ID].taker, allCDSs[_ID].takerCollateral, allCDSs[_ID].premium, allCDSs[_ID].payed, cont.balance);
>>>>>>> b184f85796c96ebc278246322f49e493010cef4f
    }
    //for testing...
    function getCollateralBalance(address _addr)public view returns(uint){
        return collateralBalances[_addr];
    }
    
    //END HLPERS
    function fillCDSOrder(uint _ID, uint _testDate)public payable returns (bool){
        require (msg.value >= allCDSs[_ID].premium && allCDSs[_ID].status==0);
        uint current = _testDate==0 ? block.timestamp : _testDate;
        allCDSs[_ID].takerCollateral = allCDSs[_ID].takerCollateral.add(msg.value);
        allCDSs[_ID].filledTime = current;
        allCDSs[_ID].status = 1;
        allCDSs[_ID].taker = msg.sender;
        collateralBalances[msg.sender] =  collateralBalances[msg.sender].add(msg.value);
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
    
    function _calculateOwed(uint _ID, uint _testDate)public view returns(uint){
        uint current = _testDate==0 ? block.timestamp : _testDate;
        uint earlier = current >= allCDSs[_ID].expiration ? allCDSs[_ID].expiration : current;
        uint delta = earlier.sub(allCDSs[_ID].filledTime);
        uint owedPayments = delta.div(allCDSs[_ID].payPeriod);
        uint outstanding = (owedPayments.mul(allCDSs[_ID].premium)).sub(allCDSs[_ID].payed);
        return(outstanding);
    }

    function setSetExpirationDate(uint _ID,uint newDate)public returns(bool){
        allCDSs[_ID].expiration = newDate;
        return(true);
    }

    function close(uint _ID, uint _testDate)public {//
        require(msg.sender == allCDSs[_ID].maker);
        uint current = _testDate==0 ? block.timestamp : _testDate;
        bool underCollateral = requestPremium(_ID, _testDate); //requestPremium requires no outstanding balance. stack is cleared and state is reversted. need another solution
        require(allCDSs[_ID].status<2);
        if(!underCollateral && (current < allCDSs[_ID].expiration)){
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

    function requestPremium(uint _ID, uint _testDate)public returns(bool){
        uint owed = _calculateOwed(_ID, _testDate);
        //add closed case
        //uint owed = allCDSs[_ID].premium;
        uint collateral = allCDSs[_ID].takerCollateral;
        uint makerPayout=0;
        uint takerPayout=0;
        
        if(owed==0) return(false);
        if(owed > collateral){
            allCDSs[_ID].status=2;
            allCDSs[_ID].takerCollateral = 0;
            makerPayout = (allCDSs[_ID].makerCollateral).add(collateral);
            allCDSs[_ID].makerCollateral = 0;
            allCDSs[_ID].maker.transfer(makerPayout);
            allCDSs[_ID].payed = allCDSs[_ID].payed.add(makerPayout);
            return(true);			             
        }
        if(owed <= collateral){//Fix Later
            allCDSs[_ID].takerCollateral = allCDSs[_ID].takerCollateral.sub(owed);
            allCDSs[_ID].payed = allCDSs[_ID].payed.add(owed);
            allCDSs[_ID].maker.transfer(owed);
            if(_testDate>=allCDSs[_ID].expiration) {
                allCDSs[_ID].status=2;
                makerPayout = allCDSs[_ID].makerCollateral;
                takerPayout = allCDSs[_ID].takerCollateral;
                allCDSs[_ID].makerCollateral=0;
                allCDSs[_ID].takerCollateral=0;
                allCDSs[_ID].maker.transfer(makerPayout);
                allCDSs[_ID].taker.transfer(takerPayout);
            }
            return(false);
        }
    }

    function reportLiquidation(uint _ID)public returns(bool){
        //add closed case
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
<<<<<<< HEAD
<<<<<<< HEAD

    //TODO: finish Collateral balance tracking for testing (removed or added where apropreate)

}
=======
=======

    //TODO: finish Collateral balance tracking for testing (removed or added where apropreate)

>>>>>>> 928182a08b433068a3ccfb42e660434f53ac4258
}
>>>>>>> b184f85796c96ebc278246322f49e493010cef4f
