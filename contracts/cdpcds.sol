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
		uint cdpID;
	}

	mapping(uint => CDS)allCDSs;
	mapping(address => uint[])holdings;

	uint currentID = 0; 
   
	function makeCDSOrder(uint _premium) public payable {
		require(msg.value >= 1000000000000000);
		uint expirationBounty = msg.value.div(20000);
		uint collateral = msg.value;
		collateral = collateral.sub(expirationBounty);
		allCDSs[currentID] = CDS(msg.sender, 0x0, collateral, 0, _premium, true, false,true, currentID, expirationBounty, 0, 0, 0, 7 days,now.add(90 days),2773);
		currentID += 1;
	}
	//HELPER SHOW INFO FUNCTION::

	function getCDS(uint _ID)public view returns(address, uint, uint ){
		return (allCDSs[_ID].maker, allCDSs[_ID].makerCollateral, allCDSs[_ID].takerCollateral);
	}

	function viewHoldings(address _addr)public view returns(uint[]){
		return holdings[_addr];        
	}

	
	//END HLPERS
	function fillCDSOrder(uint _ID)public payable returns (bool){
		require (msg.value >= allCDSs[_ID].premium);
		require(allCDSs[_ID].matchable==true);
		allCDSs[_ID].takerCollateral.add(msg.value);
		allCDSs[_ID].filledTime = block.timestamp;
		allCDSs[_ID].matched = true;
		allCDSs[_ID].matchable = false;
		allCDSs[_ID].taker = msg.sender;
		holdings[msg.sender].push(_ID);
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
		require(msg.sender == allCDSs[_ID].maker);
		bool underCollateral = requestPremium(_ID);//requestPremium requires no outstanding balance. stack is cleared and state is reversted. need another solution       
		if(!underCollateral && block.timestamp < allCDSs[_ID].expiration){
			uint earlyTermFee = (allCDSs[_ID].makerCollateral.mul(13)).div(100);
			allCDSs[_ID].makerCollateral.sub(earlyTermFee);
			allCDSs[_ID].takerCollateral.add(earlyTermFee);                              
		}
		//msg.sender.transfer(allCDSs[_ID].expirationBounty);
		allCDSs[_ID].matched = false;
		allCDSs[_ID].matchable = false;
		allCDSs[_ID].closed = true;
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
		}else {//Fix Later
			allCDSs[_ID].maker.transfer(owed);
			allCDSs[_ID].payed.add(owed);
			allCDSs[_ID].takerCollateral.sub(owed);
			return(false);
		}
	}

	function reportLiquidation(uint _ID) public returns(bool){
		bool verifiedLiquidation = true;
		//insert some code to set verified liquidation to be the outcome of the oracle
		if(verifiedLiquidation){
			uint makerCollateral = allCDSs[_ID].makerCollateral;
			allCDSs[_ID].takerCollateral.add(makerCollateral);
			close(_ID);
		}
	}
}