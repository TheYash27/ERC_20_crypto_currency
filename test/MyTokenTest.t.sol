// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract MyTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    MyToken public myToken;
    DeployMyToken public deployer;
    address public deployerAddress;
    address Bob;
    address Alice;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        Alice = makeAddr("Alice");
        Bob = makeAddr("Bob");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        myToken.transfer(Bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(myToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(myToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(Bob);
        myToken.approve(Alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(Alice);
        myToken.transferFrom(Bob, Alice, transferAmount);
        assertEq(myToken.balanceOf(Alice), transferAmount);
        assertEq(myToken.balanceOf(Bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    // Can U get coverage up?
}
