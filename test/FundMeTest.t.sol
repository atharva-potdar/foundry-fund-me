// SPDX-License-Identifier: GPL-v3.0
pragma solidity ^0.8.24 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address user = makeAddr("ladidadidaslobonmeknob");

    DeployFundMe deployFundMe = new DeployFundMe();

    // We call FundMeTest, which in turn calls DeployFundMe, which deploys FundMe
    // No explanation, but the correct owner is now msg.sender in the tests
    function setUp() public {
        fundMe = deployFundMe.run();
        console.log("FundMe deployed at:", address(fundMe));
        vm.deal(user, 1e5 ether);
    }

    function testGetSepoliaETHConfig() public {
        vm.chainId(11155111);
        HelperConfig sepoliaHelper = new HelperConfig();
        
        (address priceFeed, uint256 version) = sepoliaHelper.activeNetworkConfig();
        
        assertEq(priceFeed, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
        assertEq(version, 4);
    }

    function testGetMainnetCeloConfig() public {
        vm.chainId(42220);
        HelperConfig celoHelper = new HelperConfig();
        
        (address priceFeed, uint256 version) = celoHelper.activeNetworkConfig();
        
        assertEq(priceFeed, 0x0568fD19986748cEfF3301e55c0eb1E729E0Ab7e);
        assertEq(version, 4);
    }

    function testGetMainnetETHConfig() public {
        vm.chainId(1);
        HelperConfig ethHelper = new HelperConfig();
        
        (address priceFeed, uint256 version) = ethHelper.activeNetworkConfig();
        
        assertEq(priceFeed, 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        assertEq(version, 6);
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testReceiveFunctionCallToFundMe() public {
        vm.prank(user);
        (bool success, ) = address(fundMe).call{value: 1e18}("");
        assertTrue(success);
        assertEq(fundMe.getFunder(0), user);
        assertEq(fundMe.getAddressToAmountFunded(user), 1e18);
    }

    function testFallbackFunctionCallToFundMe() public {
        vm.prank(user);
        (bool success, ) = address(fundMe).call{value: 1e18}("data wooo");
        assertTrue(success);
        assertEq(fundMe.getFunder(0), user);
        assertEq(fundMe.getAddressToAmountFunded(user), 1e18);
    }


    // EvmError: Revert! Why? We're making a call to an external contract in a test environment

    // Let's understand the types of tests:
    // 1. Unit Tests: Testing a specific part of the code in isolation
    // 2. Integration Tests: Testing how one part of the code works with another part
    // 3. Forked Tests: Testing how our code works with a simulated version of a chain
    // 4. Staging Tests: Testing on a real chain that is not production

    // We'll mainly be using the first three types of tests
    // Forked tests make a lot of API calls and are thus very slow and expensive to run
    // We should make sure we have good unit and integration tests before relying on forked tests

    function testPriceFeedVersionMatchesChainlink() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, deployFundMe.currentChainlinkContractVersion());
    }

    function testRevertsIfNotEnoughETHSent() public {
        vm.expectRevert(); // the next line should revert
        fundMe.fund{value: 2e13}(); //0.00002 ETH
    }

    function testFundMeTracksFunder() public funded {
        assertEq(fundMe.getFunder(0), user);
    }

    function testFundMeTracksFundedAmount() public funded {
        assertEq(fundMe.getAddressToAmountFunded(user), 1e18);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(user);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange, Act, Assert - methodology for writing tests
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 1e18);
            fundMe.fund{value: 1e18}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    modifier funded() {
        vm.prank(user);
        fundMe.fund{value: 1e18}();
        _;
    }
}
