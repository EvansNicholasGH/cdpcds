pragma solidity ^0.4.24;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/cdpcds.sol";

contract TestCds{
    function testInitilBalance() public{
        cdpcds cdp = cdpcds(DeployedAddresses.cdpcds());
        uint expected = 0;
        Assert.equal(address(cdp).balance, expected, "contract balance expected 0");
    }
}

//test1
//a0 = web3.eth.accounts[0]
//a1 = web3.eth.accounts[1]
//a2 = web3.eth.accounts[2]
//a3 = web3.eth.accounts[3]
//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539154800)
//requestPremium(0,1539327600)
//requestPremium(0,1539586800)
//requestPremium(0,1539759600)
//requestPremium(0,1540278000)
//requestPremium(0,1540882800)
//requestPremium(0,1541487600)
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a3})
//fillCDSOrder(1,1539068400,{val:3000000000000000000,from:a4})
//requestPremium(1,1539759600)
//close(1,1539759600,{from:a3})

//test2
//a0 = web3.eth.accounts[0]
//a1 = web3.eth.accounts[1]
//a2 = web3.eth.accounts[2]
//a3 = web3.eth.accounts[3]
//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539759600)
//close(0,1539759600)

//test3
//a0 = web3.eth.accounts[0]
//a1 = web3.eth.accounts[1]
//a2 = web3.eth.accounts[2]
//a3 = web3.eth.accounts[3]
//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539759600)
//close(0,1541487600)

//test4
//a0 = web3.eth.accounts[0]
//a1 = web3.eth.accounts[1]
//a2 = web3.eth.accounts[2]
//a3 = web3.eth.accounts[3]
//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1541487600)
//close(0,1541487600)