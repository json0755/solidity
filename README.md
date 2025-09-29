# Bank Smart Contract

一个基于Solidity的银行智能合约项目，使用Foundry框架开发。

## 项目概述

Bank合约是一个简单的银行系统，支持以下功能：
- 接收ETH存款
- 跟踪前3名存款用户排行榜
- 仅允许合约所有者提取资金
- 内置重入攻击保护
- 内置访问控制

## 合约功能

### 核心功能
- **存款**: 用户可以通过`receive()`或`fallback()`函数向合约发送ETH
- **提取**: 仅合约所有者可以提取指定金额或全部资金
- **排行榜**: 自动维护前3名存款用户的排行榜
- **余额查询**: 查询合约总余额和用户存款余额

### 安全特性
- **访问控制**: 使用`onlyOwner`修饰符限制提取权限
- **重入保护**: 使用`nonReentrant`修饰符防止重入攻击
- **输入验证**: 验证存款金额必须大于0

## 项目结构

```
├── src/
│   └── Bank.sol              # 银行合约主文件
├── test/
│   └── Bank.t.sol           # 测试用例
├── script/
│   └── DeployBank.s.sol     # 部署脚本
├── lib/
│   └── forge-std/           # Foundry标准库
├── foundry.toml             # Foundry配置文件
└── .env.example             # 环境变量模板
```

## 快速开始

### 环境要求
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### 编译合约
```bash
forge build
```

### 运行测试
```bash
# 运行所有测试
forge test

# 运行测试并显示gas报告
forge test --gas-report

# 运行特定测试
forge test --match-test testDeposit -vv
```

### 部署合约

1. 复制环境变量模板：
```bash
cp .env.example .env
```

2. 编辑`.env`文件，填入你的私钥和RPC URL

3. 部署到本地网络：
```bash
forge script script/DeployBank.s.sol --rpc-url http://localhost:8545 --broadcast
```

## 测试覆盖

项目包含16个全面的测试用例，覆盖以下场景：

### 基础功能测试
- ✅ 合约所有者设置
- ✅ 通过`receive()`函数存款
- ✅ 通过`fallback()`函数存款
- ✅ 多次存款累计
- ✅ 余额查询

### 排行榜功能测试
- ✅ 前3名存款用户排行
- ✅ 排行榜动态更新
- ✅ 4个用户的排行榜处理

### 提取功能测试
- ✅ 所有者部分提取
- ✅ 所有者全额提取

### 安全性测试
- ✅ 零金额存款失败
- ✅ 非所有者提取失败
- ✅ 余额不足提取失败
- ✅ 空合约提取失败
- ✅ 重入攻击保护

## 合约接口

### 主要函数

```solidity
// 存款（通过receive或fallback）
receive() external payable
fallback() external payable

// 提取（仅所有者）
function withdraw(uint256 amount) external onlyOwner nonReentrant

// 查询函数
function getBalance() external view returns (uint256)
function getUserBalance(address user) external view returns (uint256)
function getTopDepositors() external view returns (address[3] memory, uint256[3] memory)
```

### 事件

```solidity
event Deposit(address indexed user, uint256 amount, uint256 newBalance)
event Withdraw(address indexed owner, uint256 amount, uint256 remainingBalance)
```

## 许可证

MIT License
