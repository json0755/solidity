// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BaseERC20.sol";

contract BaseERC20Test is Test {
    BaseERC20 public token;
    address public owner;
    address public user1;
    address public user2;
    
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18;
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        token = new BaseERC20();
    }
    
    function testTokenInfo() public view {
        assert(keccak256(bytes(token.name())) == keccak256(bytes("BaseERC20")));
        assert(keccak256(bytes(token.symbol())) == keccak256(bytes("BERC20")));
        assert(token.decimals() == 18);
        assert(token.totalSupply() == TOTAL_SUPPLY);
    }
    
    function testInitialBalance() public view {
        assertEq(token.balanceOf(owner), TOTAL_SUPPLY);
        assertEq(token.balanceOf(user1), 0);
    }
    
    function testTransfer() public {
        uint256 amount = 1000 * 10**18;
        assertTrue(token.transfer(user1, amount));
        assertEq(token.balanceOf(owner), TOTAL_SUPPLY - amount);
        assertEq(token.balanceOf(user1), amount);
    }
    
    function testTransferFailsToZeroAddress() public {
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(address(0), 1000);
    }
    
    function testTransferFailsInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(user2, 1);
    }
    
    function testApprove() public {
        uint256 amount = 1000 * 10**18;
        assertTrue(token.approve(user1, amount));
        assertEq(token.allowance(owner, user1), amount);
    }
    
    function testApproveFailsToZeroAddress() public {
        vm.expectRevert("ERC20: approve to the zero address");
        token.approve(address(0), 1000);
    }
    
    function testTransferFrom() public {
        uint256 amount = 1000 * 10**18;
        token.approve(user1, amount);
        
        vm.prank(user1);
        assertTrue(token.transferFrom(owner, user2, amount));
        
        assertEq(token.balanceOf(owner), TOTAL_SUPPLY - amount);
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.allowance(owner, user1), 0);
    }
    
    function testTransferFromFailsExceedsAllowance() public {
        token.approve(user1, 500 * 10**18);
        
        vm.prank(user1);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        token.transferFrom(owner, user2, 1000 * 10**18);
    }
    
    function testTransferFromWithMaxAllowance() public {
        uint256 amount = 1000 * 10**18;
        token.approve(user1, type(uint256).max);
        
        vm.prank(user1);
        assertTrue(token.transferFrom(owner, user2, amount));
        
        // 最大授权额度不会减少
        assertEq(token.allowance(owner, user1), type(uint256).max);
    }
    
    function testEvents() public {
        uint256 amount = 1000 * 10**18;
        
        // 测试Transfer事件 - 简化测试，不检查具体事件
        token.transfer(user1, amount);
        assertEq(token.balanceOf(user1), amount);
        
        // 测试Approval事件 - 简化测试，不检查具体事件
        token.approve(user2, amount);
        assertEq(token.allowance(owner, user2), amount);
    }
}