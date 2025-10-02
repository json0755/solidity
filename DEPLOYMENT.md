# BigBank 部署指南

## 概述
BigBank 是一个继承自 Bank 合约的增强版银行合约，具有最小存款限制和 OpenZeppelin Ownable 访问控制功能。

## 部署前准备

### 1. 环境配置
复制环境变量示例文件并配置：
```bash
cp .env.example .env
```

编辑 `.env` 文件，设置您的私钥：
```
PRIVATE_KEY=your_private_key_here
RPC_URL=http://127.0.0.1:8545  # 或其他网络RPC
```

### 2. 启动本地测试网络（可选）
如果要在本地测试，启动 Anvil：
```bash
anvil
```

## 部署步骤

### 1. 编译合约
```bash
forge build
```

### 2. 运行测试
```bash
forge test -vv
```

### 3. 部署到本地网络
```bash
forge script script/DeployBigBank.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

### 4. 部署到测试网络（如 Sepolia）
```bash
forge script script/DeployBigBank.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## 合约特性

### BigBank 合约功能：
- **最小存款限制**: 0.001 ETH
- **访问控制**: 只有所有者可以提取资金
- **继承功能**: 包含所有 Bank 合约的基础功能
- **安全性**: 使用 OpenZeppelin 的 Ownable 模式

### 主要函数：
- `receive()`: 接收 ETH 存款（需满足最小存款要求）
- `fallback()`: 备用函数处理存款
- `withdraw(uint256 amount)`: 所有者提取资金
- `owner()`: 查看当前所有者
- `MIN_DEPOSIT`: 最小存款常量 (0.001 ETH)

## 验证部署

部署成功后，您可以：
1. 检查合约地址
2. 验证所有者地址
3. 确认最小存款限制
4. 测试存款和提取功能

## 注意事项

- 确保私钥安全，不要在生产环境中使用测试私钥
- 部署前务必运行完整的测试套件
- 在主网部署前，建议先在测试网络上验证
