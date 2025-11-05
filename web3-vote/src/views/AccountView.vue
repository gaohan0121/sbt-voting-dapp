<script setup>
import { ref, onMounted, computed } from "vue";
import { showToast } from "vant"; 
// 🚨 假设 useWeb3 已经导出了 sbtContract 实例
import useWeb3 from "@/hooks/useWeb3";

// ⚠️ 注意：这里假设 useWeb3 已经集成了 sbtContract
const { web3, voteContract, getAccount, sbtContract } = useWeb3();

const account = ref("");
// 选民信息，对应 Solidity 的 Voter 结构体
const voterInfo = ref({
  weight: 0,
  delegate: '0x0000000000000000000000000000000000000000',
  voted: false,
  vote: 0,
});

// 受托人地址
const delegatorAddress = ref("");

// SBT 绑定状态
const isSbtBound = ref(false);

// 格式化后的信息显示
const delegateStatus = computed(() => {
  if (!voterInfo.value.delegate || voterInfo.value.delegate === '0x0000000000000000000000000000000000000000') {
    return '未委托';
  }
  return voterInfo.value.delegate;
});

const isVotedStatus = computed(() => {
  return voterInfo.value.voted ? '是' : '否';
});


// 1. 获取选民信息 (包含票数、委托、投票状态)
const getVoteInfo = async () => {
    account.value = await getAccount();
    if (!account.value || !voteContract) return;

    try {
        // 1.1 获取投票合约信息
        voterInfo.value = await voteContract.methods.voters(account.value).call();
        // 1.2 检查 SBT 绑定状态
        if (sbtContract) {
            isSbtBound.value = await sbtContract.methods.hasSBT(account.value).call();
        }

    } catch(error) {
        console.error("获取选民信息失败:", error);
    }
};

// 3. 委托函数
const delegate = async () => {
    if (!isSbtBound.value) {
        return showToast("请先绑定 SBT 身份才能进行委托！");
    }
    // 确保 web3 对象已加载且地址有效
    if (!web3 || !delegatorAddress.value || !web3.utils.isAddress(delegatorAddress.value)) {
        return showToast("请输入有效的受托人地址！");
    }

    let loadingToast = null;
    try {
        // 🚀 修正 1: Vant Toast 兼容性
        loadingToast = showToast({ 
            type: 'loading',
            message: '正在发送委托交易...', 
            forbidClick: true,
            duration: 0,
        });
        
        await voteContract.methods
            .delegate(delegatorAddress.value)
            // 🚀 修正 2: Gas Limit 过高问题
            .send({ 
                from: account.value,
                gas: '3000000' // 设置合理的 Gas Limit
            });
            
        if (loadingToast) loadingToast.close();
        showToast('委托成功！');
        // 刷新信息
        await getVoteInfo();

    } catch(error) {
        console.error("委托失败:", error);
        if (loadingToast) loadingToast.close();
        showToast('委托失败，请检查交易日志或委托环路。');
    }
};


onMounted(async () => {
  await getVoteInfo();
});
</script>

<template>
  <div class="box2">
    <van-divider>账户信息</van-divider>
    <van-space direction="vertical" fill>
        <van-cell-group inset>
            <van-cell title="当前账户" :value="account" />
            <van-cell title="SBT 绑定状态">
                <template #value>
                    <van-tag :type="isSbtBound ? 'success' : 'danger'">
                        {{ isSbtBound ? '已绑定' : '未绑定' }}
                    </van-tag>
                </template>
            </van-cell>
            <van-cell title="账户票数 (weight)" :value="voterInfo.weight" />
            
            <van-cell title="委托账户 (delegate)">
                 <template #value>
                    <p class="address">{{ delegateStatus }}</p>
                 </template>
            </van-cell>

            <van-cell title="是否已投票 (voted)" :value="isVotedStatus" />

            <van-cell v-if="voterInfo.voted" title="已投提案ID (vote)" :value="voterInfo.vote" />
        </van-cell-group>

    </van-space>
    
    <van-divider>委托投票</van-divider>
    
    <van-cell-group inset>
      <van-field
        v-model="delegatorAddress"
        rows="1"
        autosize
        label="受托人地址"
        type="textarea"
        placeholder="请输入受托人的钱包地址"
      />
    </van-cell-group>
    
    <div class="btn-box">
      <van-button 
         type="primary" 
         size="large" 
         :disabled="voterInfo.voted || !isSbtBound"
         @click="delegate"
      >
        委托投票
      </van-button>
      <p style="color: red; text-align: center; margin-top: 10px;" v-if="voterInfo.voted">🚨 您已投票，无法再委托。</p>
      <p style="color: red; text-align: center; margin-top: 10px;" v-else-if="!isSbtBound">🚨 请先绑定 SBT 身份才能进行委托。</p>
    </div>
  </div>
</template>

<style lang="less"></style>