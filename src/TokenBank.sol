// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC20.sol";
import "./interfaces/ITokenBank.sol";

/**
 * @title TokenBank
 * @dev 简洁优雅的代币银行合约，支持BaseERC20代币的存取功能
 * @author Senior Smart Contract Engineer
 */
contract TokenBank is ITokenBank {
    /// @dev 关联的ERC20代币合约（不可变）
    IERC20 public immutable token;
    
    /// @dev 用户存款记录映射
    mapping(address => uint256) public deposits;
    
    /// @dev 总存款量
    uint256 public totalDeposits;
    
    /**
     * @dev 构造函数
     * @param _token BaseERC20代币合约地址
     */
    constructor(address _token) {
        require(_token != address(0), "TokenBank: token address cannot be zero");
        token = IERC20(_token);
    }
    
    /**
     * @dev 存入代币
     * @param amount 存入金额
     */
    function deposit(uint256 amount) external override {
        require(amount > 0, "TokenBank: deposit amount must be greater than zero");
        
        // 检查用户授权是否充足
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "TokenBank: insufficient allowance"
        );
        
        // 检查用户余额是否充足
        require(
            token.balanceOf(msg.sender) >= amount,
            "TokenBank: insufficient balance"
        );
        
        // 执行转账（从用户转到合约）
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "TokenBank: transfer failed"
        );
        
        // 更新状态（Checks-Effects-Interactions模式）
        deposits[msg.sender] += amount;
        totalDeposits += amount;
        
        // 触发事件
        emit Deposit(msg.sender, amount);
    }
    
    /**
     * @dev 提取代币
     * @param amount 提取金额
     */
    function withdraw(uint256 amount) external override {
        require(amount > 0, "TokenBank: withdraw amount must be greater than zero");
        require(deposits[msg.sender] >= amount, "TokenBank: insufficient deposit balance");
        
        // 检查合约代币余额是否充足
        require(
            token.balanceOf(address(this)) >= amount,
            "TokenBank: insufficient contract balance"
        );
        
        // 更新状态（防止重入攻击）
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        
        // 执行转账（从合约转到用户）
        require(
            token.transfer(msg.sender, amount),
            "TokenBank: transfer failed"
        );
        
        // 触发事件
        emit Withdraw(msg.sender, amount);
    }
    
    /**
     * @dev 查询用户存款余额
     * @param user 用户地址
     * @return 用户存款余额
     */
    function getBalance(address user) external view override returns (uint256) {
        return deposits[user];
    }
    
    /**
     * @dev 查询合约代币总余额
     * @return 合约代币总余额
     */
    function getContractBalance() external view override returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    /**
     * @dev 批量查询多个用户的存款余额
     * @param users 用户地址数组
     * @return balances 对应的存款余额数组
     */
    function getBatchBalances(address[] calldata users) 
        external 
        view 
        returns (uint256[] memory balances) 
    {
        balances = new uint256[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            balances[i] = deposits[users[i]];
        }
    }
    
    /**
     * @dev 检查用户是否有存款
     * @param user 用户地址
     * @return 是否有存款
     */
    function hasDeposit(address user) external view returns (bool) {
        return deposits[user] > 0;
    }
}