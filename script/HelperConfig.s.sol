// SPDX-License-Identifier: GPL-v3.0
pragma solidity ^0.8.24 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// To deploy mock contracts when on a local anvil chain
// Keep track of contract addresses across different chains

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
        uint256 chainlinkContractVersion;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == 42220) {
            activeNetworkConfig = getMainnetCeloConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig =
            NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, chainlinkContractVersion: 4});
        return sepoliaConfig;
    }

    function getMainnetCeloConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetCeloConfig =
            NetworkConfig({priceFeed: 0x0568fD19986748cEfF3301e55c0eb1E729E0Ab7e, chainlinkContractVersion: 4});
        return mainnetCeloConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetEthConfig =
            NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419, chainlinkContractVersion: 6});
        return mainnetEthConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        // fix: return the activeNetworkConfig if it's already set
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // Deploy the mocks
        // Return the mock addresses

        vm.startBroadcast();

        // 8 decimals in ETH/USD
        // 2000 represents the "value" for ETH/USD we're setting
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig =
            NetworkConfig({priceFeed: address(mockPriceFeed), chainlinkContractVersion: mockPriceFeed.version()});
        return anvilConfig;
    }
}
