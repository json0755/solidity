# TokenBank Sepolia 部署指南

## 概述

`deploy-tokenbank-sepolia.sh` 脚本用于将 BaseERC20 和 TokenBank 合约按正确顺序部署到 Sepolia 测试网。

## 部署顺序

1. **BaseERC20 合约** - ERC20 代币合约
2. **TokenBank 合约** - 代币银行合约（依赖 BaseERC20 地址）

## 前置要求

### 1. 环境配置

复制并配置环境变量文件：

```bash
cp .env.example .env
```

在 `.env` 文件中设置以下变量：

```bash
# 部署者私钥 (请使用测试网私钥，不要使用主网私钥)
PRIVATE_KEY=your_private_key_here

# Sepolia RPC URL
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
# 或者使用 Alchemy: https://eth-sepolia.g.alchemy.com/v2/your_api_key

# Etherscan API Key (用于自动验证合约)
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

### 2. 测试网 ETH

确保部署地址有足够的 Sepolia ETH：
- 建议至少 0.01 ETH 用于部署
- 可从以下水龙头获取测试 ETH：
  - [Sepolia Faucet](https://sepoliafaucet.com/)
  - [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)

### 3. 依赖工具

确保已安装以下工具：
- `forge` (Foundry)
- `cast` (Foundry)
- `jq` (JSON 处理)
- `bc` (计算器)

## 使用方法

### 运行部署脚本

```bash
./deploy-tokenbank-sepolia.sh
```

### 脚本执行流程

1. **环境检查**
   - 验证 `.env` 文件存在
   - 检查必要的环境变量
   - 验证部署者余额

2. **合约编译**
   - 编译所有合约
   - 运行相关测试

3. **BaseERC20 部署**
   - 部署 BaseERC20 代币合约
   - 自动验证合约
   - 记录部署地址

4. **TokenBank 部署**
   - 使用 BaseERC20 地址部署 TokenBank
   - 自动验证合约
   - 记录部署地址

5. **部署摘要**
   - 显示所有合约地址
   - 提供 Etherscan 链接
   - 保存部署记录

## 输出信息

脚本会输出详细的部署日志，包括：

- ✅ 环境变量检查结果
- 🔨 合约编译状态
- 🧪 测试执行结果
- 💰 部署者余额信息
- 📍 合约部署地址
- 🔍 Etherscan 验证链接
- 📁 部署记录文件位置

## 部署记录

部署完成后，相关信息会保存在：

```
broadcast/
├── DeployBaseERC20.s.sol/11155111/run-latest.json
└── DeployTokenBankSepolia.s.sol/11155111/run-latest.json
```

## 合约信息

### BaseERC20 代币
- **名称**: BaseERC20
- **符号**: BERC20
- **精度**: 18 位小数
- **总供应量**: 100,000,000 BERC20
- **初始分配**: 全部分配给部署者

### TokenBank 合约
- **功能**: 代币存取银行
- **支持代币**: BaseERC20 (BERC20)
- **主要功能**: 存款、取款、余额查询

## 故障排除

### 常见错误

1. **余额不足**
   ```
   Error: insufficient funds for gas * price + value
   ```
   解决方案：从水龙头获取更多 Sepolia ETH

2. **RPC 连接失败**
   ```
   Error: could not connect to RPC
   ```
   解决方案：检查 `SEPOLIA_RPC_URL` 配置

3. **私钥格式错误**
   ```
   Error: invalid private key
   ```
   解决方案：确保私钥以 `0x` 开头且为 64 位十六进制

4. **合约验证失败**
   ```
   Error: verification failed
   ```
   解决方案：检查 `ETHERSCAN_API_KEY` 配置

### 手动验证合约

如果自动验证失败，可以手动验证：

```bash
# 验证 BaseERC20
forge verify-contract <CONTRACT_ADDRESS> src/BaseERC20.sol:BaseERC20 \
    --chain sepolia \
    --etherscan-api-key $ETHERSCAN_API_KEY

# 验证 TokenBank
forge verify-contract <CONTRACT_ADDRESS> src/TokenBank.sol:TokenBank \
    --chain sepolia \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address)" <BASEERC20_ADDRESS>)
```

## 后续步骤

部署完成后：

1. **更新前端配置**
   - 将合约地址更新到前端配置文件
   - 确保网络配置正确

2. **测试合约交互**
   - 在 Etherscan 上测试合约功能
   - 使用前端界面进行交互测试

3. **文档更新**
   - 记录部署的合约地址
   - 更新项目文档

## 安全提醒

- ⚠️ 永远不要在脚本中硬编码私钥
- ⚠️ 不要将包含私钥的 `.env` 文件提交到版本控制
- ⚠️ 仅在测试网使用测试私钥
- ⚠️ 部署到主网前请进行充分测试