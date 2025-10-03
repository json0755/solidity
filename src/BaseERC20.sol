// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC20.sol";

/**
 * @title BaseERC20
 * @dev 实现ERC20标准的代币合约
 * 代币名称: BaseERC20
 * 代币符号: BERC20
 * 小数位数: 18
 * 总供应量: 100,000,000
 */
contract BaseERC20 is IERC20 {
    // 代币基本信息
    string public constant name = "BaseERC20";
    string public constant symbol = "BERC20";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply;

    // 余额映射
    mapping(address => uint256) private _balances;
    
    // 授权映射 owner => spender => amount
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev 构造函数
     * 初始化代币总供应量为100,000,000，并全部分配给部署者
     */
    constructor() {
        _totalSupply = 100_000_000 * 10**decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev 返回代币总供应量
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev 返回指定地址的代币余额
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev 转移代币到指定地址
     * @param to 接收地址
     * @param amount 转移数量
     * @return 操作是否成功
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev 返回授权额度
     * @param owner 代币所有者
     * @param spender 被授权者
     * @return 授权数量
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev 授权指定地址消费代币
     * @param spender 被授权地址
     * @param amount 授权数量
     * @return 操作是否成功
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev 从指定地址转移代币
     * @param from 发送地址
     * @param to 接收地址
     * @param amount 转移数量
     * @return 操作是否成功
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 内部转账函数
     * @param from 发送地址
     * @param to 接收地址
     * @param amount 转移数量
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    /**
     * @dev 内部授权函数
     * @param owner 代币所有者
     * @param spender 被授权者
     * @param amount 授权数量
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev 消费授权额度
     * @param owner 代币所有者
     * @param spender 消费者
     * @param amount 消费数量
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}