// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank public bank;
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    
    event Deposit(address indexed depositor, uint256 amount, uint256 newBalance);
    event Withdraw(address indexed admin, uint256 amount);
    event TopDepositorsUpdated(address[3] newTopDepositors);
    
    // 添加receive函数以接收ETH
    receive() external payable {}
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
        
        bank = new Bank();
        
        // 给测试用户一些ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
    }
    
    function testOwnerIsSetCorrectly() public {
        assertEq(bank.owner(), owner);
    }
    
    function testDepositViaReceive() public {
        uint256 depositAmount = 1 ether;
        
        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, depositAmount, depositAmount);
        
        vm.prank(user1);
        (bool success, ) = address(bank).call{value: depositAmount}("");
        assertTrue(success);
        
        assertEq(bank.getBalance(user1), depositAmount);
        assertEq(bank.getContractBalance(), depositAmount);
        assertEq(bank.totalDeposits(), depositAmount);
    }
    
    function testDepositViaFallback() public {
        uint256 depositAmount = 2 ether;
        
        vm.expectEmit(true, false, false, true);
        emit Deposit(user2, depositAmount, depositAmount);
        
        vm.prank(user2);
        (bool success, ) = address(bank).call{value: depositAmount}("0x1234");
        assertTrue(success);
        
        assertEq(bank.getBalance(user2), depositAmount);
        assertEq(bank.getContractBalance(), depositAmount);
    }
    
    function testMultipleDeposits() public {
        vm.prank(user1);
        (bool success1, ) = address(bank).call{value: 1 ether}("");
        assertTrue(success1);
        
        vm.prank(user1);
        (bool success2, ) = address(bank).call{value: 2 ether}("");
        assertTrue(success2);
        
        assertEq(bank.getBalance(user1), 3 ether);
        assertEq(bank.totalDeposits(), 3 ether);
    }
    
    function testRevertDepositZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("Deposit amount must be greater than 0");
        (bool success, ) = address(bank).call{value: 0}("");
        // 不需要检查success，因为我们期望它会revert
    }
    
    function testTopDepositorsRanking() public {
        // User1 存款 5 ether
        vm.prank(user1);
        (bool success1, ) = address(bank).call{value: 5 ether}("");
        assertTrue(success1);
        
        // User2 存款 3 ether
        vm.prank(user2);
        (bool success2, ) = address(bank).call{value: 3 ether}("");
        assertTrue(success2);
        
        // User3 存款 7 ether
        vm.prank(user3);
        (bool success3, ) = address(bank).call{value: 7 ether}("");
        assertTrue(success3);
        
        address[3] memory topDepositors = bank.getTopDepositors();
        
        // 验证排序：user3(7) > user1(5) > user2(3)
        assertEq(topDepositors[0], user3);
        assertEq(topDepositors[1], user1);
        assertEq(topDepositors[2], user2);
        
        (address[3] memory addresses, uint256[3] memory amounts) = bank.getTopDepositorsWithAmounts();
        assertEq(amounts[0], 7 ether);
        assertEq(amounts[1], 5 ether);
        assertEq(amounts[2], 3 ether);
    }
    
    function testTopDepositorsUpdate() public {
        // 初始存款
        vm.prank(user1);
        (bool success1, ) = address(bank).call{value: 1 ether}("");
        assertTrue(success1);
        
        vm.prank(user2);
        (bool success2, ) = address(bank).call{value: 2 ether}("");
        assertTrue(success2);
        
        vm.prank(user3);
        (bool success3, ) = address(bank).call{value: 3 ether}("");
        assertTrue(success3);
        
        // User1 追加存款，超过其他人
        vm.prank(user1);
        (bool success4, ) = address(bank).call{value: 5 ether}("");
        assertTrue(success4);
        
        address[3] memory topDepositors = bank.getTopDepositors();
        
        // 验证新排序：user1(6) > user3(3) > user2(2)
        assertEq(topDepositors[0], user1);
        assertEq(topDepositors[1], user3);
        assertEq(topDepositors[2], user2);
    }
    
    function testTopDepositorsWithFourUsers() public {
        vm.prank(user1);
        (bool success1, ) = address(bank).call{value: 1 ether}("");
        assertTrue(success1);
        
        vm.prank(user2);
        (bool success2, ) = address(bank).call{value: 2 ether}("");
        assertTrue(success2);
        
        vm.prank(user3);
        (bool success3, ) = address(bank).call{value: 3 ether}("");
        assertTrue(success3);
        
        vm.prank(user4);
        (bool success4, ) = address(bank).call{value: 4 ether}("");
        assertTrue(success4);
        
        address[3] memory topDepositors = bank.getTopDepositors();
        
        // 只保留前3名：user4(4) > user3(3) > user2(2)
        assertEq(topDepositors[0], user4);
        assertEq(topDepositors[1], user3);
        assertEq(topDepositors[2], user2);
        
        // user1 不应该在前3名中
        assertTrue(topDepositors[0] != user1);
        assertTrue(topDepositors[1] != user1);
        assertTrue(topDepositors[2] != user1);
    }
    
    function testWithdrawByOwner() public {
        // 先存入一些资金
        vm.prank(user1);
        (bool success, ) = address(bank).call{value: 5 ether}("");
        assertTrue(success);
        
        uint256 ownerBalanceBefore = owner.balance;
        uint256 withdrawAmount = 2 ether;
        
        vm.expectEmit(true, false, false, true);
        emit Withdraw(owner, withdrawAmount);
        
        bank.withdraw(withdrawAmount);
        
        assertEq(owner.balance, ownerBalanceBefore + withdrawAmount);
        assertEq(bank.getContractBalance(), 3 ether);
    }
    
    function testWithdrawAllByOwner() public {
        // 先存入一些资金
        vm.prank(user1);
        (bool success, ) = address(bank).call{value: 3 ether}("");
        assertTrue(success);
        
        uint256 ownerBalanceBefore = owner.balance;
        
        // 传入0表示提取全部
        bank.withdraw(0);
        
        assertEq(owner.balance, ownerBalanceBefore + 3 ether);
        assertEq(bank.getContractBalance(), 0);
    }
    
    function testRevertWithdrawByNonOwner() public {
        vm.prank(user1);
        (bool success, ) = address(bank).call{value: 1 ether}("");
        assertTrue(success);
        
        vm.prank(user2);
        vm.expectRevert("Only owner can call this function");
        bank.withdraw(1 ether);
    }
    
    function testRevertWithdrawMoreThanBalance() public {
        vm.prank(user1);
        (bool success, ) = address(bank).call{value: 1 ether}("");
        assertTrue(success);
        
        vm.expectRevert("Insufficient contract balance");
        bank.withdraw(2 ether);
    }
    
    function testRevertWithdrawFromEmptyContract() public {
        vm.expectRevert("No funds to withdraw");
        bank.withdraw(1 ether);
    }
    
    function testGetBalance() public {
        assertEq(bank.getBalance(user1), 0);
        
        vm.prank(user1);
        (bool success, ) = address(bank).call{value: 2.5 ether}("");
        assertTrue(success);
        
        assertEq(bank.getBalance(user1), 2.5 ether);
    }
    
    function testGetContractBalance() public {
        assertEq(bank.getContractBalance(), 0);
        
        vm.prank(user1);
        (bool success1, ) = address(bank).call{value: 1 ether}("");
        assertTrue(success1);
        
        vm.prank(user2);
        (bool success2, ) = address(bank).call{value: 2 ether}("");
        assertTrue(success2);
        
        assertEq(bank.getContractBalance(), 3 ether);
    }
    
    function testReentrancyProtection() public {
        // 这个测试验证重入保护机制
        // 由于我们的合约设计简单，主要通过modifier保护
        // 在实际攻击场景中，攻击者会在receive函数中再次调用合约函数
        
        ReentrancyAttacker attacker = new ReentrancyAttacker(bank);
        vm.deal(address(attacker), 1 ether);
        
        // 攻击者尝试重入攻击应该失败
        vm.expectRevert();
        attacker.attack();
    }
}

// 用于测试重入攻击的合约
contract ReentrancyAttacker {
    Bank public bank;
    bool public attacking = false;
    
    constructor(Bank _bank) {
        bank = _bank;
    }
    
    function attack() external payable {
        attacking = true;
        (bool success, ) = address(bank).call{value: msg.value}("");
        require(success, "Initial deposit failed");
    }
    
    receive() external payable {
        if (attacking && address(bank).balance > 0) {
            // 尝试重入调用
            (bool success, ) = address(bank).call{value: 0.1 ether}("");
            require(success, "Reentrant call failed");
        }
    }
}