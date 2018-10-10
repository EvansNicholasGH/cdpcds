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