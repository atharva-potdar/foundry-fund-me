// SPDX-License-Identifier: GPL-v3.0
pragma solidity ^0.8.24 <0.9.0;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {

    FundMe fundMe;

    // We call FundMeTest, which in turn deploys FundMe
    // Therefore, the true owner of FundMe is this contract
    function setUp() public {
        fundMe = new FundMe();
        console.log("FundMe deployed at:", address(fundMe));
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsSender() public view {
        assertEq(fundMe.iOwner(), address(this));
    }

    function testPriceFeedVersion() public view {
        // EvmError: Revert! Why? We're making a call to an external contract in a test environment

        // Let's understand the types of tests:
        // 1. Unit Tests: Testing a specific part of the code in isolation
        // 2. Integration Tests: Testing how one part of the code works with another part
        // 3. Forked Tests: Testing how our code works with a simulated version of a chain
        // 4. Staging Tests: Testing on a real chain that is not production

        // We'll mainly be using the first three types of tests
        // Forked tests make a lot of API calls and are thus very slow and expensive to run
        // We should make sure we have good unit and integration tests before relying on forked tests

        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}