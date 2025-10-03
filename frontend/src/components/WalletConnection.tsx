import React from 'react';
import { useWeb3 } from '../contexts/Web3Context';

const WalletConnection: React.FC = () => {
  const { account, isConnected, isConnecting, connectWallet, disconnectWallet, error } = useWeb3();

  const formatAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  if (isConnected && account) {
    return (
      <div className="flex items-center space-x-4">
        <div className="flex items-center space-x-2">
          <div className="w-3 h-3 bg-green-500 rounded-full"></div>
          <span className="text-sm font-medium text-gray-700">
            {formatAddress(account)}
          </span>
        </div>
        <button
          onClick={disconnectWallet}
          className="btn btn-danger text-sm"
        >
          断开连接
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center space-y-4">
      <button
        onClick={connectWallet}
        disabled={isConnecting}
        className="btn btn-primary"
      >
        {isConnecting ? '连接中...' : '连接钱包'}
      </button>
      
      {error && (
        <div className="p-3 text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg">
          {error}
        </div>
      )}
      
      {!window.ethereum && (
        <div className="p-3 text-sm text-amber-600 bg-amber-50 border border-amber-200 rounded-lg">
          请安装 <a href="https://metamask.io" target="_blank" rel="noopener noreferrer" className="underline">MetaMask</a> 钱包
        </div>
      )}
    </div>
  );
};

export default WalletConnection;