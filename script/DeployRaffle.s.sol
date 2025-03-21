// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interaction.s.sol";

contract DeployRaffle is Script {
    function run() public {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        // create subscription
        if (config.subscriptionId == 0) {
            CreateSubscription newSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = newSubscription.createSubscription(config.vrfCoordinator);
        }

        //fund subscription
        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link);
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.subscriptionId,
            config.gasLane,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumner = new AddConsumer();
        addConsumner.addConsumer(address(raffle), config.subscriptionId, config.vrfCoordinator);
        return (raffle, helperConfig);
    }
}

// vm.startBroadcast();

// vm.stopBroadcast();
