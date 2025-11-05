// src/hooks/useWeb3.js

import Web3 from "web3";
// 导入投票合约的 JSON 文件（用于 Ballot/Vote 合约的 ABI）
import VoteJSON from "../contract/Vote.json"; 

// 🚨 新的最小 SBT ABI 定义：
// 仅包含前端需要调用的三个函数：hasSBT, issueSBT, batchIssueSBT
const MINIMAL_SBT_ABI = [
  // hasSBT(address) view returns (bool)
  {
    "inputs": [{ "internalType": "address", "name": "", "type": "address" }],
    "name": "hasSBT",
    "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
    "stateMutability": "view",
    "type": "function"
  },
  // issueSBT(address recipient) nonpayable - 单个铸造（供普通用户在 AccountView 绑定）
  {
    "inputs": [{ "internalType": "address", "name": "recipient", "type": "address" }],
    "name": "issueSBT",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  // batchIssueSBT(address[] memory recipients) nonpayable - 批量铸造（供 Host 在 MandateView 分发）
  {
    "inputs": [{ "internalType": "address[]", "name": "recipients", "type": "address[]" }],
    "name": "batchIssueSBT",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

// 投票合约地址（Ballot/Vote Contract）
const CONTRACT_ADDRESS = "0x5C1181Ab2320cF2Bf7a87f04335c79D1Fa88352d"; 

// SBT 合约地址 (VotingSBT Contract) - 使用您已设置成功的地址
const SBT_CONTRACT_ADDRESS = "0x632d4D026f4F5f2bFfc66506b354d3D277aB447b"; 

// Sepolia 测试网的 Chain ID 十六进制
const SEPOLIA_CHAIN_ID_HEX = '0xaa36a7'; 

const useWeb3 = () => {
  // 1. 实例化 Web3 对象
  const web3 = new Web3(Web3.givenProvider); 
  
  if (!Web3.givenProvider) {
      console.error("未检测到 Web3 Provider (如 MetaMask)。");
      // 错误处理，返回 null 合约对象以避免后续崩溃
      return { web3: null, voteContract: null, sbtContract: null, contractAddrress: CONTRACT_ADDRESS, getAccount: async () => null };
  }

  // 2. 实例化投票合约对象 (Ballot.sol)
  const voteContract = new web3.eth.Contract(VoteJSON.abi, CONTRACT_ADDRESS);
  
  // 3. 实例化 SBT 合约对象 (VotingSBT.sol)
  // ⚠️ 核心修正：使用 MINIMAL_SBT_ABI 确保 ABI 接口正确
  const sbtContract = new web3.eth.Contract(MINIMAL_SBT_ABI, SBT_CONTRACT_ADDRESS);


  // 4. 获取连接账户的函数 (包含网络切换逻辑)
  const getAccount = async () => {
    if (!window.ethereum) return null; // 如果没有Provider，直接返回
    
    // 请求连接账户
    const accounts = await web3.eth.requestAccounts();

    // 检查当前网络是否是 Sepolia
    const currentChainId = await web3.eth.getChainId();

    if (currentChainId !== BigInt(SEPOLIA_CHAIN_ID_HEX)) {
        try {
            // 尝试切换到 Sepolia
            await window.ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: SEPOLIA_CHAIN_ID_HEX }],
            });
            // 切换成功后重新获取账户
            const newAccounts = await web3.eth.requestAccounts();
            return newAccounts[0];
        } catch (switchError) {
            // 错误处理：用户取消或链不存在等
            console.error("切换网络失败:", switchError);
            if (switchError.code === 4902) {
                // Sepolia 链 ID 4902 错误，通常需要添加链
                alert("请在 MetaMask 中添加 Sepolia 测试网。");
            }
            // 即使切换失败，仍返回当前连接的账户（但合约调用可能会失败）
            return accounts[0]; 
        }
    }
    
    return accounts[0];
  };

  return {
    web3,
    voteContract,
    sbtContract,         // 🚀 修正：SBT 合约实例已导出
    contractAddrress: CONTRACT_ADDRESS,
    sbtContractAddress: SBT_CONTRACT_ADDRESS,
    getAccount,
  };
};

export default useWeb3;