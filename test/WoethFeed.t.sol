pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WoethFeed.sol";

contract WoethMock {
    uint result;

    function convertToAssets(uint256 amount) external view returns (uint256) {
        return result * amount / 10**18;
    }

    function totalAssets() external pure returns (uint256) {
        return 1;
    }

    function setResult(uint256 newResult) external {
        result = newResult;
    }
}

contract WoethFeedTest is Test {
    WoethFeed public feed;
    WoethMock public woeth;

    function setUp() public {
        woeth = new WoethMock();
        woeth.setResult(1.1 ether);

        feed = new WoethFeed(address(woeth));
    }

    function testConstructor() public {
        assertEq(address(feed.woeth()), address(woeth));
    }

    function testRead() public {
        assertEq(feed.read(), 1.1 ether);
    }

    function testFailReadNull() public {
        woeth.setResult(0);
        feed.read();
    }    

    function testGetResultWithValidity() public {
        (uint result, bool valid) = feed.getResultWithValidity();
        assertEq(result, 1.1 ether);
        assertTrue(valid);

        woeth.setResult(0);
        (result, valid) = feed.getResultWithValidity();
        assertEq(result, 0);
        assertFalse(valid);        
    }    

    function testUpdateResult() public {
        feed.updateResult(address(this)); // should not revert
    }
}
