// SPDX-License-Identifier: GPL-v3.0
pragma solidity ^0.8.24 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    uint256 public currentChainlinkContractVersion;

    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed, uint256 chainlinkContractVersion) = helperConfig.activeNetworkConfig();

        currentChainlinkContractVersion = chainlinkContractVersion;

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
