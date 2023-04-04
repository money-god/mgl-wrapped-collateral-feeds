pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WstethFeed.sol";

contract WstethMock {
    uint result;

    function stEthPerToken() external view returns (uint256) {
        return result;
    }

    function setResult(uint256 newResult) external {
        result = newResult;
    }
}

contract WstethFeedTest is Test {
    WstethFeed public feed;
    WstethMock public wsteth;

    function setUp() public {
        wsteth = new WstethMock();
        wsteth.setResult(1.1 ether);

        feed = new WstethFeed(address(wsteth));
    }

    function testConstructor() public {
        assertEq(address(feed.wsteth()), address(wsteth));
    }

    function testRead() public {
        assertEq(feed.read(), 1.1 ether);
    }

    function testFailReadNull() public {
        wsteth.setResult(0);
        feed.read();
    }    

    function testGetResultWithValidity() public {
        (uint result, bool valid) = feed.getResultWithValidity();
        assertEq(result, 1.1 ether);
        assertTrue(valid);

        wsteth.setResult(0);
        (result, valid) = feed.getResultWithValidity();
        assertEq(result, 0);
        assertFalse(valid);        
    }    

    function testUpdateResult() public {
        feed.updateResult(address(this)); // should not revert
    }
}
