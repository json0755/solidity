// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Bank.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BigBank is Bank, Ownable {
    uint256 public constant MIN_DEPOSIT = 0.001 ether;
    
    modifier minDeposit() {
        require(msg.value >= MIN_DEPOSIT, "Deposit must be at least 0.001 ether");
        _;
    }
    
    constructor(address initialOwner) Ownable(initialOwner) {}
    
    function owner() public view override(Bank, Ownable) returns (address) {
        return Ownable.owner();
    }
    
    receive() external payable override minDeposit {
        _deposit();
    }
    
    fallback() external payable override minDeposit {
        _deposit();
    }
    
    function withdraw(uint256 amount) external override {
        require(msg.sender == owner(), "Only owner can withdraw");
        require(address(this).balance > 0, "No funds to withdraw");
        
        uint256 withdrawAmount = amount == 0 ? address(this).balance : amount;
        require(withdrawAmount <= address(this).balance, "Insufficient contract balance");
        
        emit Withdraw(msg.sender, withdrawAmount);
        
        (bool success, ) = payable(msg.sender).call{value: withdrawAmount}("");
        require(success, "Withdrawal failed");
    }
    
    // 为了兼容测试，添加这些函数
    function getBalance(address account) external view override returns (uint256) {
        return balances[account];
    }
    
    function getContractBalance() external view override returns (uint256) {
        return address(this).balance;
    }
}
