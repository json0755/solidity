// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BaseERC20.sol";

/**
 * @title DeployBaseERC20
 * @dev BaseERC20代币合约部署脚本
 */
contract DeployBaseERC20 is Script {
    function run() external returns (BaseERC20) {
        vm.startBroadcast();
        
        // 部署BaseERC20合约
        BaseERC20 token = new BaseERC20();
        
        // 记录部署信息
        console.log("BaseERC20 deployed to:", address(token));
        console.log("Token name: BaseERC20");
        console.log("Token symbol: BERC20");
        console.log("Token decimals: 18");
        console.log("Total supply: 100000000000000000000000000");
        console.log("Deployer balance:", token.balanceOf(msg.sender));
        
        vm.stopBroadcast();
        
        return token;
    }
}