<script setup>
import useWeb3 from "../hooks/useWeb3";
import { ref, onMounted } from "vue";
import { showToast } from "vant"; 

// 🚀 修正：从 useWeb3 中解构出所有需要的实例，包括 sbtContract
const { web3, voteContract, getAccount, sbtContract, contractAddrress } = useWeb3();

// 定义主持人信息
const host = ref("");
// 当前 MetaMask 连接的账户
const currentAccount = ref(""); 
// SBT 合约地址 (用于在 Ballot 合约中设置)
const sbtContractAddressInput = ref("");
// 选民地址输入框 (用于批量分发 SBT)
const voterAddress = ref(""); 

// 增加加载状态
const isLoading = ref(true);

// 获取主持人信息
const getHost = async () => {
  isLoading.value = true;
  currentAccount.value = await getAccount();
  if (!voteContract) {
      isLoading.value = false;
      return;
  }

  try {
    host.value = await voteContract.methods.host().call();
    // 自动读取 Ballot 合约中绑定的 SBT 地址（如果已设置）
    sbtContractAddressInput.value = await voteContract.methods.sbtContract().call();
  } catch (error) {
    console.error("获取主持人地址失败:", error);
    showToast("获取合约信息失败，请检查 ABI 和网络。", { type: 'fail', duration: 5000 });
  } finally {
    isLoading.value = false;
  }
};

// --- 步骤 1: Host 绑定 SBT 合约地址到 Ballot 合约 ---
const setSBTContract = async () => {
    if (!sbtContractAddressInput.value || !web3.utils.isAddress(sbtContractAddressInput.value)) {
        return showToast("请输入有效的 SBT 合约地址");
    }
    if (currentAccount.value.toLowerCase() !== host.value.toLowerCase()) {
         return showToast("只有主持人才能设置 SBT 合约地址！", { type: 'fail' });
    }

    let loadingToast = null;
    try {
        loadingToast = showToast({ type: 'loading', message: '正在设置合约地址...', forbidClick: true, duration: 0 });

        await voteContract.methods
            .setSBTContract(sbtContractAddressInput.value)
            .send({ from: currentAccount.value });
        
        if (loadingToast) loadingToast.close();
        showToast("SBT 合约地址设置成功！", { type: 'success' });
        
    } catch (error) {
        console.error("设置 SBT 合约地址失败:", error);
        if (loadingToast) loadingToast.close();
        showToast("设置 SBT 合约地址失败: 合约已回滚 (可能地址已设置)。", { type: 'fail', duration: 5000 });
    }
};

// --- 步骤 2: 批量分发 SBT 身份 (铸造 SBT) ---
const issueSBTs = async () => {
  // 1. 合约和权限检查
  if (!sbtContract) {
      return showToast("SBT合约未初始化。请检查 useWeb3.js 文件。", { type: 'fail' });
  }
  if (currentAccount.value.toLowerCase() !== host.value.toLowerCase()) {
      return showToast("只有主持人才能批量分发 SBT！", { type: 'fail' });
  }
  
  // 2. 地址解析 (确保输入列表是有效的)
  let arr = [];
  try {
      // 简单解析逗号分隔或 JSON 数组
      if (voterAddress.value.startsWith('[')) {
          arr = JSON.parse(voterAddress.value);
      } else {
          // 清理地址，并检查是否是有效地址
          arr = voterAddress.value.split(',').map(a => a.trim()).filter(a => web3.utils.isAddress(a));
      }
      if (arr.length === 0) {
          return showToast("地址列表为空或格式不正确！", { type: 'fail' });
      }
  } catch (e) {
      return showToast("地址列表格式解析失败！", { type: 'fail' });
  }

  // 3. 发送交易
  let loadingToast = null;
  try {
      loadingToast = showToast({ type: 'loading', message: '正在发送批量分发交易...', forbidClick: true, duration: 0 });
      
      // 🚀 关键：直接使用从 useWeb3 导入的 sbtContract 实例，避免重新实例化
      await sbtContract.methods
          .batchIssueSBT(arr)
          .send({ from: currentAccount.value }); // 当前账户必须是 SBT 合约的 Owner
      
      if (loadingToast) loadingToast.close();
      showToast("批量分发 SBT 成功！", { type: 'success' });

  } catch (error) {
      console.error("批量分发 SBT 失败 (可能权限不足或 EVM 回滚):", error);
      if (loadingToast) loadingToast.close();
      showToast("批量分发 SBT 失败。请检查：1. 当前账户是否为 SBT 合约 Owner。 2. 地址列表是否正确。", { type: 'fail', duration: 5000 });
  }
};


onMounted(async () => {
  await getHost();
});
</script>

<template>
  <div class="box">
    <h2>Host 授权操作 (Host Only)</h2>
    <van-space direction="vertical" fill>
      <van-space>
          <p class="label">主持人地址:</p>
          <p class="address">{{ host || '加载中...' }}</p>
      </van-space>
      <van-space>
          <p class="label">当前连接账户:</p>
          <p class="address">{{ currentAccount || '加载中...' }}</p>
      </van-space>
      <van-space>
          <p class="label">Ballot 合约地址:</p>
          <p class="address">{{ contractAddrress || '加载中...' }}</p>
      </van-space>
      <van-space>
          <p class="label">Ballot 绑定的SBT地址:</p>
          <p class="address">{{ sbtContractAddressInput || '未设置' }}</p>
      </van-space>
    </van-space>
    
    <van-divider></van-divider>

    <div v-if="isLoading" style="text-align: center; padding: 20px;">
        <van-loading type="spinner" size="24px">正在加载权限信息...</van-loading>
    </div>
    <div v-else-if="currentAccount && host && currentAccount.toLowerCase() === host.toLowerCase()">
        
        <van-divider>步骤 1: 绑定 SBT 合约地址</van-divider>
        <van-cell-group inset>
          <van-field
            v-model="sbtContractAddressInput"
            rows="1"
            autosize
            label="SBT 合约地址"
            type="textarea"
            placeholder="请输入您部署的 VotingSBT 合约地址"
          />
        </van-cell-group>
        <div class="btn-box">
          <van-button 
             type="primary" 
             size="large" 
             :disabled="sbtContractAddressInput && sbtContractAddressInput.toLowerCase() !== '0x0000000000000000000000000000000000000000'"
             @click="setSBTContract"
          >
            设置 SBT 合约地址 (Host Only)
          </van-button>
          <p v-if="sbtContractAddressInput && sbtContractAddressInput.toLowerCase() !== '0x0000000000000000000000000000000000000000'" style="color: green; text-align: center; margin-top: 10px;">✅ 地址已设置，无需重复操作。</p>
        </div>

        <van-divider>步骤 2: 批量分发 SBT 身份</van-divider>
        <van-cell-group inset>
          <van-field
            v-model="voterAddress"
            rows="3"
            autosize
            label="投票人地址列表"
            type="textarea"
            placeholder="请输入投票人地址，多个地址用逗号分隔，例如：0x123..., 0x456... (请使用测试网地址)"
          />
        </van-cell-group>
        <div class="btn-box">
          <van-button 
             type="warning" 
             size="large" 
             @click="issueSBTs"
             :disabled="!sbtContractAddressInput || sbtContractAddressInput.toLowerCase() === '0x0000000000000000000000000000000000000000'"
          >
            批量分发 SBT (铸造 SBT)
          </van-button>
        </div>
        
    </div>
    <div v-else style="text-align: center; color: red; padding: 20px;">
        <p v-if="currentAccount && host">您不是主持人，无法进行授权操作。</p>
        <p v-else-if="!currentAccount">请连接钱包。</p>
        <p v-else>权限信息异常。</p>
    </div>
  </div>
</template>

<style lang="less">
.box {
  padding: 10px;
  max-width: 600px;
  margin: 0 auto;
  /* 确保内容可以垂直滚动 */
  overflow-y: auto; 
  /* 🚀 关键修正：在底部增加一个大的内边距，强制将最后一个按钮向上推，避免被截断 */
  padding-bottom: 100px;
}
.btn-box {
  margin-top: 20px;
  padding: 0 16px;
}
.label {
  font-weight: bold;
}
.address {
  word-break: break-all;
  font-family: monospace;
}
</style>