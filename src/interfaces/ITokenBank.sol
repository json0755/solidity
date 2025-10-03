// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";

/**
 * @title ITokenBank
 * @dev TokenBank合约的接口定义
 */
interface ITokenBank {
    /**
     * @dev 存款事件
     * @param user 存款用户地址
     * @param amount 存款金额
     */
    event Deposit(address indexed user, uint256 amount);
    
    /**
     * @dev 提取事件
     * @param user 提取用户地址
     * @param amount 提取金额
     */
    event Withdraw(address indexed user, uint256 amount);
    
    /**
     * @dev 存入代币
     * @param amount 存入金额
     */
    function deposit(uint256 amount) external;
    
    /**
     * @dev 提取代币
     * @param amount 提取金额
     */
    function withdraw(uint256 amount) external;
    
    /**
     * @dev 查询用户存款余额
     * @param user 用户地址
     * @return 用户存款余额
     */
    function getBalance(address user) external view returns (uint256);
    
    /**
     * @dev 查询合约代币总余额
     * @return 合约代币总余额
     */
    function getContractBalance() external view returns (uint256);
    
    /**
     * @dev 查询用户存款记录
     * @param user 用户地址
     * @return 用户存款金额
     */
    function deposits(address user) external view returns (uint256);
    
    /**
     * @dev 查询总存款量
     * @return 总存款量
     */
    function totalDeposits() external view returns (uint256);
    
    /**
     * @dev 查询关联的代币合约地址
     * @return 代币合约地址
     */
    function token() external view returns (IERC20);
}