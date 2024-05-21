//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

/* 
4 types of testing:
    1. Unit testing: Check if single part the code actually works.
    2. Integration testing: Check how the code works with other parts of the code.
    3. Forked testing: Test the code on a simulated virtual environment.
    4. Staging: Test the code in a real environment that is not the production environment.
*/

contract FundMeTest is Test {
    FundMe fundMe;
    // In Foundry, you can create a new fake user with the makeAddr() method. You can use it with the prank() cheatcode
    address USER = makeAddr("user");
    uint constant SEND_VALUE = 1e18;
    uint constant STARTING_BALANCE = 1000e18;
    uint constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //When you create a fake user with makeAddr, he doesn't have money indeed.
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(msg.sender, fundMe.getOwner());
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailedWithNotEnoughEths() public {
        //This cheatcode expects the next line to fail!
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundWithEnoughEths() public {
        //The prank cheatcode sets the next caller as the one passed as argument
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    // Use a modifier to execute a piece of code before another function!
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundingBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundingBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawMultipleFunders() public funded {
        uint numberOfFunders = 10;
        uint startingIndex = 1;

        for (uint index = startingIndex; index < numberOfFunders; index++) {
            // hoax is another foundry cheatcode that allows to execude both a prank and a deal cheatcode, all in a single line of code.
            // So, the idea here was to make sure that first - the index is used to generate an address which we'll pass to prank, and then deal the SEND_VALUE to that address
            // The reason for the cast to uint160 is that we can't convert directly uint256 to addresses, but we have to convert them first to uint160, since it holds
            //      the same amount of data that an address holds
            hoax(address(uint160(index)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundingBalance = address(fundMe).balance;

        //This syntax for prank executes all the code in the block with startPrank and stopPrank() with the address specified in startPrank()
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundingBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawMultipleFundersOptimized() public funded {
        uint numberOfFunders = 10;
        uint startingIndex = 1;

        for (uint index = startingIndex; index < numberOfFunders; index++) {
            // hoax is another foundry cheatcode that allows to execude both a prank and a deal cheatcode, all in a single line of code.
            // So, the idea here was to make sure that first - the index is used to generate an address which we'll pass to prank, and then deal the SEND_VALUE to that address
            // The reason for the cast to uint160 is that we can't convert directly uint256 to addresses, but we have to convert them first to uint160, since it holds
            //      the same amount of data that an address holds
            hoax(address(uint160(index)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundingBalance = address(fundMe).balance;

        //This syntax for prank executes all the code in the block with startPrank and stopPrank() with the address specified in startPrank()
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundingBalance,
            endingOwnerBalance
        );
    }
}
