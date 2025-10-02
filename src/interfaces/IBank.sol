// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBank {
    event Deposit(address indexed depositor, uint256 amount, uint256 newBalance);
    event Withdraw(address indexed admin, uint256 amount);
    event TopDepositorsUpdated(address[3] newTopDepositors);
    
    function withdraw(uint256 amount) external;
    function getBalance(address user) external view returns (uint256);
    function getContractBalance() external view returns (uint256);
    function getTopDepositors() external view returns (address[3] memory);
    function getTopDepositorsWithAmounts() external view returns (address[3] memory, uint256[3] memory);
    function owner() external view returns (address);
    function balances(address user) external view returns (uint256);
    function totalDeposits() external view returns (uint256);
}
