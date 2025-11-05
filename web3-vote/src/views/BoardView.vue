<script setup>
import useWeb3 from "../hooks/useWeb3";
import { ref, onMounted } from "vue";
import { showToast } from "vant"; // 确保从 vant 导入 showToast
//

const { web3, voteContract, getAccount } = useWeb3();

// 看板信息
const board = ref([]);

//
// src/views/BoardView.vue

const getBoardInfo = async () => {
  if (!voteContract) return;
  try {
      // 🚨 【修正点】: 将 proposalList() 改为 getBoardInfo()
      const result = await voteContract.methods.getBoardInfo().call(); 
      board.value = result;
  } catch(error) {
      console.error("获取看板信息失败:", error);
      showToast("获取投票看板失败，请检查合约和网络连接。");
  }
};

const vote = async (index) => {
  if (!voteContract) return;
  const account = await getAccount();
  if (!account) return showToast("请连接MetaMask！");

  // 🚀 Vant Toast 修正：使用 showToast() 函数调用并指定 type
  let loadingToast = null;
  try {
      // 修正用法：使用 showToast({ type: 'loading', ... }) 替代 showToast.loading()
      loadingToast = showToast({ 
          type: 'loading',
          message: '正在发送投票交易...', 
          forbidClick: true,
          duration: 0,
      });

      await voteContract.methods.vote(index).send({ from: account });
      
      if (loadingToast) loadingToast.close(); // 交易成功后关闭提示
      showToast("投票成功！");
      // 投票成功后刷新看板
      await getBoardInfo(); 
      
  } catch(error) {
      console.error("投票失败:", error);
      if (loadingToast) loadingToast.close(); // 交易失败时关闭提示
      showToast("投票失败，请检查是否有投票权或已投票。");
  } 
};

// ❌ 移除 initEventListen()：您的合约中没有定义事件，该函数被移除。

onMounted(() => {
  getBoardInfo();
});
</script>

<template>
  <div class="box3">
    <van-divider>投票看板</van-divider>
    <van-cell :title="item.name" icon="shop-o" v-for="(item, index) in board" :key="index">
      <template #right-icon>
        <van-button size="small" type="primary" @click="vote(index)">
           投票 ({{ item.voteCount }} 票)
        </van-button>
      </template>
    </van-cell>
    <div v-if="board.length === 0" style="text-align: center; color: #999; padding: 20px;">
      加载中或没有主题
    </div>
  </div>
</template>

<style lang="less">
.box3 {
  padding: 10px;
}
</style>