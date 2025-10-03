// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC20
 * @dev ERC20标准接口
 */
interface IERC20 {
    /**
     * @dev 返回代币总供应量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回指定地址的代币余额
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 转移代币到指定地址
     * 返回布尔值表示操作是否成功
     * 触发 Transfer 事件
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev 返回授权额度
     * 返回 owner 授权给 spender 的代币数量
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 授权指定地址消费代币
     * 返回布尔值表示操作是否成功
     * 触发 Approval 事件
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 从指定地址转移代币
     * 使用授权机制，从 from 地址转移代币到 to 地址
     * 返回布尔值表示操作是否成功
     * 触发 Transfer 事件
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /**
     * @dev 转账事件
     * 当代币被转移时触发，包括零值转账
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev 授权事件
     * 当调用 approve 函数时触发
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}