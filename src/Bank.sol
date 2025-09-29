// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Bank
 * @dev 一个简洁优雅的银行合约，支持存款、管理员提取和排行榜功能
 */
contract Bank {
    // 管理员地址
    address public owner;
    
    // 重入锁
    bool private locked;
    // 状态变量
    mapping(address => uint256) public balances;
    address[3] public topDepositors;
    uint256 public totalDeposits;
    
    // 事件
    event Deposit(address indexed depositor, uint256 amount, uint256 newBalance);
    event Withdraw(address indexed admin, uint256 amount);
    event TopDepositorsUpdated(address[3] newTopDepositors);
    
    // 修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev 接收ETH存款
     */
    receive() external payable {
        _deposit();
    }
    
    /**
     * @dev 回退函数，也用于接收存款
     */
    fallback() external payable {
        _deposit();
    }
    
    /**
     * @dev 内部存款逻辑
     */
    function _deposit() internal {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        
        emit Deposit(msg.sender, msg.value, balances[msg.sender]);
        
        _updateTopDepositors(msg.sender);
    }
    
    /**
     * @dev 更新存款排行榜前3名
     * @param depositor 存款用户地址
     */
    function _updateTopDepositors(address depositor) internal {
        uint256 depositorBalance = balances[depositor];
        
        // 检查是否已在排行榜中
        int256 existingIndex = -1;
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositors[i] == depositor) {
                existingIndex = int256(i);
                break;
            }
        }
        
        if (existingIndex >= 0) {
            // 已在排行榜中，重新排序
            _sortTopDepositors();
            emit TopDepositorsUpdated(topDepositors);
            return;
        }
        
        // 不在排行榜中，找到合适的插入位置
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositors[i] == address(0)) {
                // 找到空位，直接插入
                topDepositors[i] = depositor;
                _sortTopDepositors();
                emit TopDepositorsUpdated(topDepositors);
                return;
            } else if (depositorBalance > balances[topDepositors[i]]) {
                // 找到应该插入的位置，将后面的元素后移
                for (uint256 j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j-1];
                }
                topDepositors[i] = depositor;
                emit TopDepositorsUpdated(topDepositors);
                return;
            }
        }
    }
    
    /**
     * @dev 对排行榜进行排序（降序）
     */
    function _sortTopDepositors() internal {
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (topDepositors[i] != address(0) && topDepositors[j] != address(0)) {
                    if (balances[topDepositors[i]] < balances[topDepositors[j]]) {
                        address temp = topDepositors[i];
                        topDepositors[i] = topDepositors[j];
                        topDepositors[j] = temp;
                    }
                } else if (topDepositors[i] == address(0) && topDepositors[j] != address(0)) {
                    topDepositors[i] = topDepositors[j];
                    topDepositors[j] = address(0);
                }
            }
        }
    }
    
    /**
     * @dev 管理员提取资金
     * @param amount 提取金额，0表示提取全部
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        
        uint256 withdrawAmount = amount == 0 ? contractBalance : amount;
        require(withdrawAmount <= contractBalance, "Insufficient contract balance");
        
        (bool success, ) = payable(owner).call{value: withdrawAmount}("");
        require(success, "Withdrawal failed");
        
        emit Withdraw(owner, withdrawAmount);
    }
    
    /**
     * @dev 获取用户余额
     * @param user 用户地址
     * @return 用户存款余额
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
    
    /**
     * @dev 获取合约总余额
     * @return 合约当前ETH余额
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev 获取存款排行榜前3名
     * @return 前3名用户地址数组
     */
    function getTopDepositors() external view returns (address[3] memory) {
        return topDepositors;
    }
    
    /**
     * @dev 获取排行榜前3名的详细信息
     * @return addresses 地址数组
     * @return amounts 对应的存款金额数组
     */
    function getTopDepositorsWithAmounts() external view returns (address[3] memory addresses, uint256[3] memory amounts) {
        addresses = topDepositors;
        for (uint256 i = 0; i < 3; i++) {
            amounts[i] = balances[topDepositors[i]];
        }
    }
}