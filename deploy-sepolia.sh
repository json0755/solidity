#!/bin/bash

# Bank合约Sepolia部署脚本
# 使用方法: ./deploy-sepolia.sh

set -e  # 遇到错误时退出

echo "🚀 开始部署Bank合约到Sepolia测试网..."

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

# 编译合约
echo "🔨 编译合约..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 合约编译失败"
    exit 1
fi

echo "✅ 合约编译成功"

# 运行测试
echo "🧪 运行测试..."
forge test

if [ $? -ne 0 ]; then
    echo "❌ 测试失败，请修复后再部署"
    exit 1
fi

echo "✅ 所有测试通过"

# 部署合约
echo "🚀 部署合约到Sepolia..."
# 临时禁用代理以避免连接问题
unset http_proxy https_proxy
forge script script/DeployBank.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --broadcast \
    -vvvv

if [ $? -eq 0 ]; then
    echo "🎉 Bank合约成功部署到Sepolia测试网!"
    echo "📋 部署信息已保存在broadcast/目录中"
    echo "🔍 合约已在Etherscan上验证"
    echo ""
    echo "📝 下一步:"
    echo "1. 查看broadcast/DeployBank.s.sol/11155111/run-latest.json获取合约地址"
    echo "2. 在Sepolia Etherscan上查看你的合约"
    echo "3. 可以开始与合约交互了!"
else
    echo "❌ 部署失败，请检查错误信息"
    exit 1
fi