// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BigBank.sol";

contract BigBankTest is Test {
    BigBank public bigBank;
    address public owner;
    address public user1;
    address public user2;
    
    // 添加receive函数以接收ETH
    receive() external payable {}
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        bigBank = new BigBank(owner);
        
        // 给测试用户一些ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }
    
    function testMinDepositRequirement() public {
        // 测试小于最小存款金额的交易应该失败
        vm.prank(user1);
        vm.expectRevert("Deposit must be at least 0.001 ether");
        address(bigBank).call{value: 0.0005 ether}("");
    }
    
    function testValidDeposit() public {
        // 测试有效存款
        vm.prank(user1);
        (bool success, ) = address(bigBank).call{value: 0.001 ether}("");
        assertTrue(success);
        
        assertEq(bigBank.getBalance(user1), 0.001 ether);
        assertEq(bigBank.getContractBalance(), 0.001 ether);
    }
    
    function testLargeDeposit() public {
        // 测试大额存款
        vm.prank(user1);
        (bool success, ) = address(bigBank).call{value: 1 ether}("");
        assertTrue(success);
        
        assertEq(bigBank.getBalance(user1), 1 ether);
        assertEq(bigBank.getContractBalance(), 1 ether);
    }
    
    function testOnlyOwnerCanWithdraw() public {
        // 先存入一些资金
        vm.prank(user1);
        (bool success, ) = address(bigBank).call{value: 1 ether}("");
        assertTrue(success);
        
        // 测试非管理员无法提取
        vm.prank(user2);
        vm.expectRevert();
        bigBank.withdraw(0.5 ether);
        
        // 测试管理员可以提取
        uint256 initialBalance = owner.balance;
        bigBank.withdraw(0.5 ether);
        assertEq(owner.balance, initialBalance + 0.5 ether);
    }
    
    function testWithdrawAll() public {
        // 存入资金
        vm.prank(user1);
        (bool success, ) = address(bigBank).call{value: 2 ether}("");
        assertTrue(success);
        
        // 提取全部资金
        uint256 initialBalance = owner.balance;
        bigBank.withdraw(0); // 0表示提取全部
        assertEq(owner.balance, initialBalance + 2 ether);
        assertEq(bigBank.getContractBalance(), 0);
    }
    
    function testTopDepositorsWithMinDeposit() public {
        // 测试排行榜功能与最小存款限制的结合
        vm.prank(user1);
        (bool success1, ) = address(bigBank).call{value: 0.001 ether}("");
        assertTrue(success1);
        
        vm.prank(user2);
        (bool success2, ) = address(bigBank).call{value: 0.002 ether}("");
        assertTrue(success2);
        
        address[3] memory topDepositors = bigBank.getTopDepositors();
        assertEq(topDepositors[0], user2);
        assertEq(topDepositors[1], user1);
    }
    
    function testInheritedFunctionality() public {
        // 测试继承的Bank功能
        vm.prank(user1);
        (bool success, ) = address(bigBank).call{value: 1 ether}("");
        assertTrue(success);
        
        // 测试继承的getter函数
        assertEq(bigBank.balances(user1), 1 ether);
        assertEq(bigBank.totalDeposits(), 1 ether);
        assertEq(bigBank.owner(), owner);
    }
}
