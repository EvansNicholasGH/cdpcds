pragma solidity ^0.4.24;

contract testing{

   struct cds{
       address maker;
       address taker;
       uint makerCollateral;
       uint takerCollateral;
       uint payment;
       uint filledTime;
       uint paid;
       uint payPeriod;
   }
   address cont = this;

   mapping(uint => cds)CDSs;
   uint currentID = 0;

   function make(uint _payment)public payable {
       require(msg.value > 1e17);
       CDSs[currentID] = cds(msg.sender, 0x0, msg.value, 0, _payment,  0, 0, 7 days);
       currentID += 1;
   }

   function fill(uint _ID)public payable {
       //require(msg.value >= CDSs[_ID].payment);
       require(msg.sender != CDSs[_ID].maker);
       CDSs[_ID].taker = msg.sender;
       CDSs[_ID].takerCollateral = msg.value;
   }

   function pay(uint _ID)public {
       require(msg.sender == CDSs[_ID].taker);
       uint mCol = CDSs[_ID].makerCollateral;
       CDSs[_ID].makerCollateral = 0;
       CDSs[_ID].taker.transfer(mCol);
       uint tCol = CDSs[_ID].takerCollateral;
       CDSs[_ID].takerCollateral = 0;
       CDSs[_ID].taker.transfer(tCol);
   }

   function getInfo(uint _ID) public view returns (uint, uint, uint, uint, uint){
       return(CDSs[_ID].makerCollateral,CDSs[_ID].takerCollateral, CDSs[_ID].payment, CDSs[_ID].paid, cont.balance);
   }

    function _calculateOwed(uint _ID)internal view returns(uint){
       //uint owed = CDSs[_ID].payment+CDSs[_ID].paid;
       uint current = block.timestamp;
       uint delta = current - CDSs[_ID].filledTime;
       uint owedPayments = 1 + (uint(delta)/(uint(CDSs[_ID].payPeriod)*(86400)));
       uint owed = owedPayments*(CDSs[_ID].payment);
       return owed;
   }

      function requestPremium(uint _ID)public returns(bool){
       uint owed = _calculateOwed(_ID);
       uint paid = CDSs[_ID].paid;
       uint outstanding = owed - paid;
       uint collateral = CDSs[_ID].takerCollateral;

       if(owed<=paid) return(true);
       else if(collateral>=outstanding){
           CDSs[_ID].takerCollateral -= outstanding;
           CDSs[_ID].paid = outstanding;
           CDSs[_ID].maker.transfer(outstanding);
           return(true);
       }
       else if(collateral<outstanding){
           CDSs[_ID].paid = collateral;
           if(collateral>0) CDSs[_ID].maker.transfer(collateral);
           CDSs[_ID].takerCollateral = 0;
           return(false);
       }

   }

}