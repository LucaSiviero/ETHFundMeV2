//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegration is Test {
    FundMe fundMe;
    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 1000 ether;
    uint constant GAS_PRICE = 1;

    //address public constant USER = address(1);
    address immutable i_user = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(i_user, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.prank(i_user);
        fundFundMe.fundFundMe(address(fundMe));
        address funder = fundMe.getFunders(0);

        assertEq(funder, i_user); //check USER is registered as a funder

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        vm.prank(msg.sender);
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(i_user).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(i_user);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(i_user).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
