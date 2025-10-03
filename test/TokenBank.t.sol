// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";
import "../src/BaseERC20.sol";
import "../src/interfaces/ITokenBank.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    BaseERC20 public token;
    
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18;
    uint256 public constant DEPOSIT_AMOUNT = 1000 * 10**18;
    uint256 public constant LARGE_AMOUNT = 10000 * 10**18;
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        
        // 部署BaseERC20代币
        token = new BaseERC20();
        
        // 部署TokenBank
        tokenBank = new TokenBank(address(token));
        
        // 给测试用户分发代币
        token.transfer(user1, LARGE_AMOUNT);
        token.transfer(user2, LARGE_AMOUNT);
        token.transfer(user3, LARGE_AMOUNT);
    }
    
    // ========== 构造函数测试 ==========
    function testConstructor() public view {
        assertEq(address(tokenBank.token()), address(token));
        assertEq(tokenBank.totalDeposits(), 0);
    }
    
    function testConstructorWithZeroAddress() public {
        vm.expectRevert("TokenBank: token address cannot be zero");
        new TokenBank(address(0));
    }
    
    // ========== 存款功能测试 ==========
    function testDeposit() public {
        vm.startPrank(user1);
        
        // 授权TokenBank使用代币
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        
        // 记录存款前状态
        uint256 userBalanceBefore = token.balanceOf(user1);
        uint256 contractBalanceBefore = token.balanceOf(address(tokenBank));
        uint256 userDepositBefore = tokenBank.deposits(user1);
        uint256 totalDepositsBefore = tokenBank.totalDeposits();
        
        // 执行存款
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        // 验证状态变化
        assertEq(token.balanceOf(user1), userBalanceBefore - DEPOSIT_AMOUNT);
        assertEq(token.balanceOf(address(tokenBank)), contractBalanceBefore + DEPOSIT_AMOUNT);
        assertEq(tokenBank.deposits(user1), userDepositBefore + DEPOSIT_AMOUNT);
        assertEq(tokenBank.totalDeposits(), totalDepositsBefore + DEPOSIT_AMOUNT);
        assertEq(tokenBank.getBalance(user1), DEPOSIT_AMOUNT);
        assert(tokenBank.hasDeposit(user1));
        
        vm.stopPrank();
    }
    
    function testDepositZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("TokenBank: deposit amount must be greater than zero");
        tokenBank.deposit(0);
    }
    
    function testDepositInsufficientAllowance() public {
        vm.prank(user1);
        // 不进行授权直接存款
        vm.expectRevert("TokenBank: insufficient allowance");
        tokenBank.deposit(DEPOSIT_AMOUNT);
    }
    
    function testDepositInsufficientBalance() public {
        vm.startPrank(user1);
        
        // 授权超过余额的金额
        uint256 excessiveAmount = token.balanceOf(user1) + 1;
        token.approve(address(tokenBank), excessiveAmount);
        
        vm.expectRevert("TokenBank: insufficient balance");
        tokenBank.deposit(excessiveAmount);
        
        vm.stopPrank();
    }
    
    function testMultipleDeposits() public {
        vm.startPrank(user1);
        
        // 第一次存款
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        // 第二次存款
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        // 验证累计存款
        assertEq(tokenBank.deposits(user1), DEPOSIT_AMOUNT * 2);
        assertEq(tokenBank.totalDeposits(), DEPOSIT_AMOUNT * 2);
        
        vm.stopPrank();
    }
    
    // ========== 提取功能测试 ==========
    function testWithdraw() public {
        // 先存款
        vm.startPrank(user1);
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        // 记录提取前状态
        uint256 userBalanceBefore = token.balanceOf(user1);
        uint256 contractBalanceBefore = token.balanceOf(address(tokenBank));
        uint256 userDepositBefore = tokenBank.deposits(user1);
        uint256 totalDepositsBefore = tokenBank.totalDeposits();
        
        uint256 withdrawAmount = DEPOSIT_AMOUNT / 2;
        
        // 执行提取
        tokenBank.withdraw(withdrawAmount);
        
        // 验证状态变化
        assertEq(token.balanceOf(user1), userBalanceBefore + withdrawAmount);
        assertEq(token.balanceOf(address(tokenBank)), contractBalanceBefore - withdrawAmount);
        assertEq(tokenBank.deposits(user1), userDepositBefore - withdrawAmount);
        assertEq(tokenBank.totalDeposits(), totalDepositsBefore - withdrawAmount);
        
        vm.stopPrank();
    }
    
    function testWithdrawAll() public {
        vm.startPrank(user1);
        
        // 存款
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        // 提取全部
        tokenBank.withdraw(DEPOSIT_AMOUNT);
        
        // 验证状态
        assertEq(tokenBank.deposits(user1), 0);
        assertEq(tokenBank.getBalance(user1), 0);
        assert(!tokenBank.hasDeposit(user1));
        
        vm.stopPrank();
    }
    
    function testWithdrawZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("TokenBank: withdraw amount must be greater than zero");
        tokenBank.withdraw(0);
    }
    
    function testWithdrawInsufficientDeposit() public {
        vm.prank(user1);
        vm.expectRevert("TokenBank: insufficient deposit balance");
        tokenBank.withdraw(DEPOSIT_AMOUNT);
    }
    
    function testWithdrawExceedsDeposit() public {
        vm.startPrank(user1);
        
        // 存款
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        // 尝试提取超过存款的金额
        vm.expectRevert("TokenBank: insufficient deposit balance");
        tokenBank.withdraw(DEPOSIT_AMOUNT + 1);
        
        vm.stopPrank();
    }
    
    // ========== 查询功能测试 ==========
    function testGetBalance() public {
        assertEq(tokenBank.getBalance(user1), 0);
        
        vm.startPrank(user1);
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assertEq(tokenBank.getBalance(user1), DEPOSIT_AMOUNT);
    }
    
    function testGetContractBalance() public {
        assertEq(tokenBank.getContractBalance(), 0);
        
        vm.startPrank(user1);
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assertEq(tokenBank.getContractBalance(), DEPOSIT_AMOUNT);
    }
    
    function testGetBatchBalances() public {
        // 多个用户存款
        vm.startPrank(user1);
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        vm.startPrank(user2);
        token.approve(address(tokenBank), DEPOSIT_AMOUNT * 2);
        tokenBank.deposit(DEPOSIT_AMOUNT * 2);
        vm.stopPrank();
        
        // 批量查询
        address[] memory users = new address[](3);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;
        
        uint256[] memory balances = tokenBank.getBatchBalances(users);
        
        assertEq(balances[0], DEPOSIT_AMOUNT);
        assertEq(balances[1], DEPOSIT_AMOUNT * 2);
        assertEq(balances[2], 0);
    }
    
    function testHasDeposit() public {
        assert(!tokenBank.hasDeposit(user1));
        
        vm.startPrank(user1);
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assert(tokenBank.hasDeposit(user1));
        
        vm.prank(user1);
        tokenBank.withdraw(DEPOSIT_AMOUNT);
        
        assert(!tokenBank.hasDeposit(user1));
    }
    
    // ========== 复杂场景测试 ==========
    function testMultipleUsersDepositAndWithdraw() public {
        uint256 amount1 = 1000 * 10**18;
        uint256 amount2 = 2000 * 10**18;
        uint256 amount3 = 500 * 10**18;
        
        // 用户1存款
        vm.startPrank(user1);
        token.approve(address(tokenBank), amount1);
        tokenBank.deposit(amount1);
        vm.stopPrank();
        
        // 用户2存款
        vm.startPrank(user2);
        token.approve(address(tokenBank), amount2);
        tokenBank.deposit(amount2);
        vm.stopPrank();
        
        // 用户3存款
        vm.startPrank(user3);
        token.approve(address(tokenBank), amount3);
        tokenBank.deposit(amount3);
        vm.stopPrank();
        
        // 验证总存款
        assertEq(tokenBank.totalDeposits(), amount1 + amount2 + amount3);
        assertEq(tokenBank.getContractBalance(), amount1 + amount2 + amount3);
        
        // 用户1部分提取
        vm.prank(user1);
        tokenBank.withdraw(amount1 / 2);
        
        // 验证状态
        assertEq(tokenBank.deposits(user1), amount1 / 2);
        assertEq(tokenBank.deposits(user2), amount2);
        assertEq(tokenBank.deposits(user3), amount3);
        assertEq(tokenBank.totalDeposits(), amount1 / 2 + amount2 + amount3);
    }
    
    function testDepositWithdrawCycle() public {
        vm.startPrank(user1);
        
        uint256 initialBalance = token.balanceOf(user1);
        
        // 存款 -> 提取 -> 再存款 -> 再提取
        token.approve(address(tokenBank), DEPOSIT_AMOUNT * 2);
        
        tokenBank.deposit(DEPOSIT_AMOUNT);
        assertEq(tokenBank.deposits(user1), DEPOSIT_AMOUNT);
        
        tokenBank.withdraw(DEPOSIT_AMOUNT / 2);
        assertEq(tokenBank.deposits(user1), DEPOSIT_AMOUNT / 2);
        
        tokenBank.deposit(DEPOSIT_AMOUNT);
        assertEq(tokenBank.deposits(user1), DEPOSIT_AMOUNT + DEPOSIT_AMOUNT / 2);
        
        tokenBank.withdraw(DEPOSIT_AMOUNT + DEPOSIT_AMOUNT / 2);
        assertEq(tokenBank.deposits(user1), 0);
        
        // 验证最终余额
        assertEq(token.balanceOf(user1), initialBalance);
        
        vm.stopPrank();
    }
    
    // ========== 边界值测试 ==========
    function testDepositMaxAmount() public {
        uint256 maxAmount = token.balanceOf(user1);
        
        vm.startPrank(user1);
        token.approve(address(tokenBank), maxAmount);
        tokenBank.deposit(maxAmount);
        
        assertEq(tokenBank.deposits(user1), maxAmount);
        assertEq(token.balanceOf(user1), 0);
        vm.stopPrank();
    }
    
    function testWithdrawAfterTokenTransfer() public {
        vm.startPrank(user1);
        
        // 存款
        token.approve(address(tokenBank), DEPOSIT_AMOUNT);
        tokenBank.deposit(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
        
        // 模拟合约代币被意外转出的情况
        vm.prank(address(tokenBank));
        token.transfer(owner, DEPOSIT_AMOUNT);
        
        // 尝试提取应该失败
        vm.prank(user1);
        vm.expectRevert("TokenBank: insufficient contract balance");
        tokenBank.withdraw(DEPOSIT_AMOUNT);
    }
}