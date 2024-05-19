//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
    1. We want to deploy mocks when we are on a local anvil chain
    2. Keep track of contract addressess depending on the chain
*/

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant ETH_PRICE = 3000e8;

    NetworkConfig public activeNetworkConfig;

    //You can refer to chainlist.org to check the ids...
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //1. Deploy the mock
        //2. Return the mock address

        //This block of code is used to check if the priceFeed address has already been set. When an address is not set, its value is 0
        //So we can check and make sure that we don't re-deploy the mock aggregator more than once
        if (address(activeNetworkConfig.priceFeed) != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            ETH_DECIMALS,
            ETH_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilConfig;
    }
}
