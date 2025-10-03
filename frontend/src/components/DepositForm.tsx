import React, { useState } from 'react';
import { ethers } from 'ethers';
import { useWeb3 } from '../contexts/Web3Context';

interface DepositFormProps {
  onSuccess?: () => void;
}

const DepositForm: React.FC<DepositFormProps> = ({ onSuccess }) => {
  const { tokenContract, tokenBankContract, account } = useWeb3();
  const [amount, setAmount] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handleDeposit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!tokenContract || !tokenBankContract || !account) {
      setError('请先连接钱包');
      return;
    }

    if (!amount || parseFloat(amount) <= 0) {
      setError('请输入有效的存款金额');
      return;
    }

    try {
      setIsLoading(true);
      setError(null);
      setSuccess(null);

      const depositAmount = ethers.parseEther(amount);
      
      // Check if user has enough balance
      const balance = await tokenContract.balanceOf(account);
      if (balance < depositAmount) {
        throw new Error('余额不足');
      }

      // Check current allowance
      const currentAllowance = await tokenContract.allowance(account, await tokenBankContract.getAddress());
      
      // If allowance is insufficient, approve first
      if (currentAllowance < depositAmount) {
        setSuccess('正在授权代币...');
        const approveTx = await tokenContract.approve(await tokenBankContract.getAddress(), depositAmount);
        await approveTx.wait();
      }

      // Perform deposit
      setSuccess('正在存款...');
      const depositTx = await tokenBankContract.deposit(depositAmount);
      await depositTx.wait();

      setSuccess(`成功存入 ${amount} 代币！`);
      setAmount('');
      
      // Call success callback
      if (onSuccess) {
        onSuccess();
      }
    } catch (err: any) {
      console.error('Deposit error:', err);
      setError(err.message || '存款失败');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="card">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">存款</h2>
      
      <form onSubmit={handleDeposit} className="space-y-4">
        <div>
          <label htmlFor="deposit-amount" className="block text-sm font-medium text-gray-700 mb-2">
            存款金额
          </label>
          <div className="relative">
            <input
              id="deposit-amount"
              type="number"
              step="0.0001"
              min="0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="输入存款金额"
              className="form-input"
              disabled={isLoading}
            />
            <div className="absolute inset-y-0 right-0 flex items-center pr-3">
              <span className="text-gray-500 text-sm">ETH</span>
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={isLoading || !amount}
          className="btn btn-success w-full flex items-center justify-center space-x-2"
        >
          {isLoading ? (
            <>
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              <span>处理中...</span>
            </>
          ) : (
            <>
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              <span>存款</span>
            </>
          )}
        </button>
      </form>

      {error && (
        <div className="mt-4 p-3 text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg">
          {error}
        </div>
      )}

      {success && (
        <div className="mt-4 p-3 text-sm text-green-600 bg-green-50 border border-green-200 rounded-lg">
          {success}
        </div>
      )}
    </div>
  );
};

export default DepositForm;