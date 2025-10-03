// Contract addresses configuration
export interface ContractAddresses {
  tokenBank: string;
  baseERC20: string;
}

// Default addresses (will be updated by deployment script)
export const contractAddresses: ContractAddresses = {
  tokenBank: '0x71f94c1b164b86c1c05ea5469696b9793487d471',
  baseERC20: '0x966b857352c49F1178cfaDDd07E42f1159389E3c',
};

// Network configuration
export const NETWORK_CONFIG = {
  chainId: 11155111, // Sepolia testnet
  name: 'Sepolia Testnet',
  rpcUrl: 'https://sepolia.infura.io/v3/YOUR_INFURA_KEY',
};

// Update contract addresses (called by deployment script)
export const updateContractAddresses = (addresses: ContractAddresses) => {
  contractAddresses.tokenBank = addresses.tokenBank;
  contractAddresses.baseERC20 = addresses.baseERC20;
};