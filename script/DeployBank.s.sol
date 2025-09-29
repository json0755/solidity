// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Bank.sol";

contract DeployBank is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Bank bank = new Bank();
        
        vm.stopBroadcast();
        
        console.log("Bank deployed to:", address(bank));
        console.log("Owner:", bank.owner());
    }
}