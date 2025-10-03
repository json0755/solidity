import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { useWeb3 } from '../contexts/Web3Context';

const TokenBalance: React.FC = () => {
  const { tokenContract, tokenBankContract, account, isConnected } = useWeb3();
  const [tokenBalance, setTokenBalance] = useState<string>('0');
  const [bankBalance, setBankBalance] = useState<string>('0');
  const [tokenSymbol, setTokenSymbol] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const fetchBalances = async () => {
    if (!tokenContract || !tokenBankContract || !account) return;

    try {
      setLoading(true);
      
      // Get token balance
      const tokenBal = await tokenContract.balanceOf(account);
      setTokenBalance(ethers.formatEther(tokenBal));
      
      // Get bank balance
      const bankBal = await tokenBankContract.getBalance(account);
      setBankBalance(ethers.formatEther(bankBal));
      
      // Get token symbol
      const symbol = await tokenContract.symbol();
      setTokenSymbol(symbol);
    } catch (error) {
      console.error('Error fetching balances:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isConnected) {
      fetchBalances();
    }
  }, [isConnected, tokenContract, tokenBankContract, account]);

  if (!isConnected) {
    return null;
  }

  return (
    <div className="card">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">余额信息</h2>
      
      {loading ? (
        <div className="flex items-center justify-center py-8">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
        </div>
      ) : (
        <div className="space-y-4">
          <div className="flex justify-between items-center p-4 bg-gray-50 rounded-lg">
            <div>
              <p className="text-sm text-gray-600">钱包余额</p>
              <p className="text-lg font-semibold text-gray-800">
                {parseFloat(tokenBalance).toFixed(4)} {tokenSymbol}
              </p>
            </div>
            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center">
              <svg className="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
          </div>
          
          <div className="flex justify-between items-center p-4 bg-primary-50 rounded-lg">
            <div>
              <p className="text-sm text-gray-600">银行存款</p>
              <p className="text-lg font-semibold text-gray-800">
                {parseFloat(bankBalance).toFixed(4)} {tokenSymbol}
              </p>
            </div>
            <div className="w-12 h-12 bg-primary-200 rounded-full flex items-center justify-center">
              <svg className="w-6 h-6 text-primary-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
          </div>
        </div>
      )}
      
      <button
          onClick={fetchBalances}
          disabled={loading}
          className="btn btn-primary w-full"
        >
          {loading ? '刷新中...' : '刷新余额'}
        </button>
    </div>
  );
};

export default TokenBalance;