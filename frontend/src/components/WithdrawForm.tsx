import React, { useState } from 'react';
import { ethers } from 'ethers';
import { useWeb3 } from '../contexts/Web3Context';

interface WithdrawFormProps {
  onSuccess?: () => void;
}

const WithdrawForm: React.FC<WithdrawFormProps> = ({ onSuccess }) => {
  const { tokenBankContract, account } = useWeb3();
  const [amount, setAmount] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handleWithdraw = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!tokenBankContract || !account) {
      setError('请先连接钱包');
      return;
    }

    if (!amount || parseFloat(amount) <= 0) {
      setError('请输入有效的取款金额');
      return;
    }

    try {
      setIsLoading(true);
      setError(null);
      setSuccess(null);

      const withdrawAmount = ethers.parseEther(amount);
      
      // Check if user has enough balance in bank
      const bankBalance = await tokenBankContract.getBalance(account);
      if (bankBalance < withdrawAmount) {
        throw new Error('银行存款余额不足');
      }

      // Perform withdrawal
      setSuccess('正在取款...');
      const withdrawTx = await tokenBankContract.withdraw(withdrawAmount);
      await withdrawTx.wait();

      setSuccess(`成功取出 ${amount} 代币！`);
      setAmount('');
      
      // Call success callback
      if (onSuccess) {
        onSuccess();
      }
    } catch (err: any) {
      console.error('Withdraw error:', err);
      setError(err.message || '取款失败');
    } finally {
      setIsLoading(false);
    }
  };

  const handleMaxWithdraw = async () => {
    if (!tokenBankContract || !account) return;

    try {
      const bankBalance = await tokenBankContract.getBalance(account);
      const maxAmount = ethers.formatEther(bankBalance);
      setAmount(maxAmount);
    } catch (err) {
      console.error('Error getting max balance:', err);
    }
  };

  return (
    <div className="card">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">取款</h2>
      
      <form onSubmit={handleWithdraw} className="space-y-4">
        <div>
          <label htmlFor="withdraw-amount" className="block text-sm font-medium text-gray-700 mb-2">
            取款金额
          </label>
          <div className="relative">
            <input
              id="withdraw-amount"
              type="number"
              step="0.0001"
              min="0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="输入取款金额"
              className="form-input"
              disabled={isLoading}
            />
            <div className="absolute inset-y-0 right-0 flex items-center pr-3 space-x-2">
              <button
                type="button"
                onClick={handleMaxWithdraw}
                className="text-xs text-primary-600 hover:text-primary-700 font-medium"
                disabled={isLoading}
              >
                最大
              </button>
              <span className="text-gray-500 text-sm">ETH</span>
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={isLoading || !amount}
          className="btn btn-warning w-full flex items-center justify-center space-x-2"
        >
          {isLoading ? (
            <>
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              <span>处理中...</span>
            </>
          ) : (
            <>
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
              </svg>
              <span>取款</span>
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

export default WithdrawForm;