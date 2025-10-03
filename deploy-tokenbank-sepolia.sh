#!/bin/bash

# TokenBank合约Sepolia部署脚本
# 按顺序部署BaseERC20和TokenBank合约到Sepolia测试网
# 使用方法: ./deploy-tokenbank-sepolia.sh

set -e  # 遇到错误时退出

echo "🚀 开始部署TokenBank系统到Sepolia测试网..."
echo "📋 部署顺序: BaseERC20 -> TokenBank"
echo ""

# 检查.env文件是否存在
if [ ! -f .env ]; then
    echo "❌ 错误: .env文件不存在"
    echo "请复制.env.example为.env并填入你的配置:"
    echo "cp .env.example .env"
    exit 1
fi

# 加载环境变量
source .env

# 检查必要的环境变量
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ 错误: PRIVATE_KEY未设置"
    echo "请在.env文件中设置你的私钥"
    exit 1
fi

if [ -z "$SEPOLIA_RPC_URL" ]; then
    echo "❌ 错误: SEPOLIA_RPC_URL未设置"
    echo "请在.env文件中设置Sepolia RPC URL"
    exit 1
fi

echo "✅ 环境变量检查通过"
echo ""

# 编译合约
echo "🔨 编译合约..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 合约编译失败"
    exit 1
fi

echo "✅ 合约编译成功"
echo ""

# 运行测试
echo "🧪 运行TokenBank相关测试..."
forge test --match-contract "TokenBank|BaseERC20"

if [ $? -ne 0 ]; then
    echo "❌ 测试失败，请修复后再部署"
    exit 1
fi

echo "✅ 所有测试通过"
echo ""

# 获取部署者地址
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
echo "📍 部署者地址: $DEPLOYER_ADDRESS"

# 检查余额
echo "💰 检查Sepolia ETH余额..."
BALANCE=$(cast balance $DEPLOYER_ADDRESS --rpc-url $SEPOLIA_RPC_URL)
BALANCE_ETH=$(cast --to-unit $BALANCE ether)
echo "💰 当前余额: $BALANCE_ETH ETH"

if (( $(echo "$BALANCE_ETH < 0.01" | bc -l) )); then
    echo "⚠️  警告: 余额可能不足，建议至少有0.01 ETH用于部署"
fi
echo ""

# 第一步：部署BaseERC20合约
echo "🚀 第一步: 部署BaseERC20代币合约..."
echo "⏰ 开始时间: $(date)"

# 临时禁用代理以避免连接问题
unset http_proxy https_proxy

forge script script/DeployBaseERC20.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    -vvvv

if [ $? -ne 0 ]; then
    echo "❌ BaseERC20合约部署失败"
    exit 1
fi

echo "✅ BaseERC20合约部署成功!"
echo ""

# 从部署结果中提取BaseERC20地址
BASEERC20_BROADCAST_FILE="broadcast/DeployBaseERC20.s.sol/11155111/run-latest.json"
if [ -f "$BASEERC20_BROADCAST_FILE" ]; then
    BASEERC20_ADDRESS=$(jq -r '.transactions[0].contractAddress' $BASEERC20_BROADCAST_FILE)
    echo "📍 BaseERC20合约地址: $BASEERC20_ADDRESS"
    
    # 将地址转换为正确的校验和格式
    BASEERC20_ADDRESS=$(cast to-check-sum-address $BASEERC20_ADDRESS)
    echo "📍 校验和地址: $BASEERC20_ADDRESS"
else
    echo "⚠️  无法找到BaseERC20部署记录文件，请手动检查地址"
fi
echo ""

# 等待几秒让网络确认
echo "⏳ 等待网络确认..."
sleep 10

# 第二步：部署TokenBank合约
echo "🚀 第二步: 部署TokenBank合约..."
echo "⏰ 开始时间: $(date)"

# 创建临时的TokenBank部署脚本，使用已部署的BaseERC20地址
cat > script/DeployTokenBankSepolia.s.sol << EOF
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TokenBank.sol";
import "../src/BaseERC20.sol";

contract DeployTokenBankSepolia is Script {
    function run() external returns (TokenBank) {
        vm.startBroadcast();
        
        // 使用已部署的BaseERC20地址
        address tokenAddress = ${BASEERC20_ADDRESS:-0x0000000000000000000000000000000000000000};
        require(tokenAddress != address(0), "BaseERC20 address not found");
        
        // 部署TokenBank合约
        TokenBank tokenBank = new TokenBank(tokenAddress);
        
        // 记录部署信息
        console.log("=== TokenBank Deployment Summary ===");
        console.log("TokenBank address:", address(tokenBank));
        console.log("BaseERC20 address:", tokenAddress);
        console.log("TokenBank token address:", address(tokenBank.token()));
        console.log("TokenBank total deposits:", tokenBank.totalDeposits());
        console.log("Deployer:", msg.sender);
        
        vm.stopBroadcast();
        
        return tokenBank;
    }
}
EOF

forge script script/DeployTokenBankSepolia.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    -vvvv

if [ $? -ne 0 ]; then
    echo "❌ TokenBank合约部署失败"
    # 清理临时文件
    rm -f script/DeployTokenBankSepolia.s.sol
    exit 1
fi

echo "✅ TokenBank合约部署成功!"
echo ""

# 从部署结果中提取TokenBank地址
TOKENBANK_BROADCAST_FILE="broadcast/DeployTokenBankSepolia.s.sol/11155111/run-latest.json"
if [ -f "$TOKENBANK_BROADCAST_FILE" ]; then
    TOKENBANK_ADDRESS=$(jq -r '.transactions[0].contractAddress' $TOKENBANK_BROADCAST_FILE)
    echo "📍 TokenBank合约地址: $TOKENBANK_ADDRESS"
else
    echo "⚠️  无法找到TokenBank部署记录文件，请手动检查地址"
fi

# 清理临时文件
rm -f script/DeployTokenBankSepolia.s.sol

echo ""
echo "🎉 TokenBank系统成功部署到Sepolia测试网!"
echo "⏰ 完成时间: $(date)"
echo ""
echo "📋 部署摘要:"
echo "├── BaseERC20合约地址:  $BASEERC20_ADDRESS"
echo "├── TokenBank合约地址:  $TOKENBANK_ADDRESS"
echo "├── 网络: Sepolia (Chain ID: 11155111)"
echo "└── 部署者: $DEPLOYER_ADDRESS"
echo ""
echo "🔍 部署信息:"
echo "├── BaseERC20 Etherscan: https://sepolia.etherscan.io/address/$BASEERC20_ADDRESS"
echo "└── TokenBank Etherscan: https://sepolia.etherscan.io/address/$TOKENBANK_ADDRESS"
echo ""
echo "💡 提示: 合约未自动验证，如需验证请手动执行验证命令"
echo ""
echo "📁 部署记录文件:"
echo "├── BaseERC20: $BASEERC20_BROADCAST_FILE"
echo "└── TokenBank: $TOKENBANK_BROADCAST_FILE"
echo ""
echo "📝 下一步:"
echo "1. 在Sepolia Etherscan上查看合约"
echo "2. 更新前端配置文件中的合约地址"
echo "3. 可以开始与合约交互了!"
echo ""
echo "💡 提示:"
echo "- 代币名称: BaseERC20 (BERC20)"
echo "- 代币精度: 18位小数"
echo "- 初始供应量: 100,000,000 BERC20"
echo "- 所有代币已分配给部署者地址"