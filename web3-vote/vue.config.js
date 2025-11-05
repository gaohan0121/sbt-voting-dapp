const { defineConfig } = require("@vue/cli-service");
const { VantResolver } = require("unplugin-vue-components/resolvers");
const ComponentsPlugin = require("unplugin-vue-components/webpack");

module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: './', // ✅ 保证构建资源使用相对路径，防止 GitHub Pages 白屏
  configureWebpack: {
    plugins: [
      ComponentsPlugin({
        resolvers: [VantResolver()],
      }),
    ],
  },
});
