// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TokenBank.sol";
import "../src/BaseERC20.sol";

/**
 * @title DeployTokenBank
 * @dev TokenBank合约部署脚本
 */
contract DeployTokenBank is Script {
    function run() external returns (TokenBank, BaseERC20) {
        vm.startBroadcast();
        
        // 首先部署BaseERC20代币合约
        BaseERC20 token = new BaseERC20();
        console.log("BaseERC20 deployed to:", address(token));
        
        // 部署TokenBank合约，传入BaseERC20地址
        TokenBank tokenBank = new TokenBank(address(token));
        console.log("TokenBank deployed to:", address(tokenBank));
        
        // 记录部署信息
        console.log("=== Deployment Summary ===");
        console.log("BaseERC20 address:", address(token));
        console.log("TokenBank address:", address(tokenBank));
        console.log("Token name: BaseERC20");
        console.log("Token symbol: BERC20");
        console.log("Token decimals: 18");
        console.log("Total supply: 100000000000000000000000000");
        console.log("Deployer balance:", token.balanceOf(msg.sender));
        console.log("TokenBank token address:", address(tokenBank.token()));
        console.log("TokenBank total deposits:", tokenBank.totalDeposits());
        
        vm.stopBroadcast();
        
        return (tokenBank, token);
    }
    
    /**
     * @dev 部署到已存在的BaseERC20代币
     * @param tokenAddress 已部署的BaseERC20代币地址
     */
    function runWithExistingToken(address tokenAddress) external returns (TokenBank) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        
        vm.startBroadcast();
        
        // 部署TokenBank合约，使用现有的BaseERC20地址
        TokenBank tokenBank = new TokenBank(tokenAddress);
        
        // 记录部署信息
        console.log("TokenBank deployed to:", address(tokenBank));
        console.log("Using existing token at:", tokenAddress);
        console.log("TokenBank token address:", address(tokenBank.token()));
        console.log("TokenBank total deposits:", tokenBank.totalDeposits());
        
        vm.stopBroadcast();
        
        return tokenBank;
    }
}