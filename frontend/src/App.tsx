import React, { useState } from 'react';
import { Web3Provider } from './contexts/Web3Context';
import WalletConnection from './components/WalletConnection';
import TokenBalance from './components/TokenBalance';
import DepositForm from './components/DepositForm';
import WithdrawForm from './components/WithdrawForm';

function App() {
  const [refreshKey, setRefreshKey] = useState(0);

  const handleTransactionSuccess = () => {
    // Force refresh balances by updating key
    setRefreshKey(prev => prev + 1);
  };

  return (
    <Web3Provider>
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="container mx-auto px-4 py-8">
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold text-gray-800 mb-2">Token Bank</h1>
            <p className="text-gray-600">安全的代币存储和管理平台</p>
          </div>

          {/* Wallet Connection */}
          <div className="flex justify-center mb-8">
            <WalletConnection />
          </div>

          {/* Main Content */}
          <div className="max-w-6xl mx-auto">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Balance Display */}
              <div className="lg:col-span-1">
                <TokenBalance key={refreshKey} />
              </div>

              {/* Transaction Forms */}
              <div className="lg:col-span-2 space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <DepositForm onSuccess={handleTransactionSuccess} />
                  <WithdrawForm onSuccess={handleTransactionSuccess} />
                </div>

                {/* Info Card */}
                <div className="bg-white rounded-xl shadow-lg p-6">
                  <h3 className="text-lg font-semibold text-gray-800 mb-3">使用说明</h3>
                  <div className="space-y-2 text-sm text-gray-600">
                    <p>• 首次使用需要连接 MetaMask 钱包</p>
                    <p>• 存款前需要授权代币给合约</p>
                    <p>• 所有交易都在区块链上执行，请确保有足够的 Gas 费</p>
                    <p>• 存款和取款操作会实时更新余额显示</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="text-center mt-12 text-gray-500 text-sm">
            <p>Powered by Ethereum & Foundry</p>
          </div>
        </div>
      </div>
    </Web3Provider>
  );
}

export default App;
