#!/usr/bin/env bash
# 推送到私服 Nexus npm 仓库
# 敏感信息从 .env.publish 读取，该文件已加入 .gitignore（不提交到 GitHub）

set -e

# 加载私服配置（优先从 .env.publish 读取，也可直接设置环境变量）
ENV_FILE=".env.publish"
if [ -f "${ENV_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

# 必填项检查
: "${NEXUS_REGISTRY:?请设置 NEXUS_REGISTRY（私服地址）}"
: "${NEXUS_USERNAME:?请设置 NEXUS_USERNAME（用户名）}"
: "${NEXUS_PASSWORD:?请设置 NEXUS_PASSWORD（密码）}"

# 生成 Base64 认证信息
AUTH_TOKEN=$(echo -n "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" | base64)

# 写入临时 .npmrc
NPMRC_FILE=".npmrc-private"
cat > "${NPMRC_FILE}" <<EOF
registry=${NEXUS_REGISTRY}/
//${NEXUS_REGISTRY#https://}:_auth=${AUTH_TOKEN}
//${NEXUS_REGISTRY#https://}:always-auth=true
EOF

echo ">>> 构建项目..."
npm run build

echo ">>> 推送到私服：${NEXUS_REGISTRY}"
npm publish --registry "${NEXUS_REGISTRY}" --userconfig "${NPMRC_FILE}"

# 清理临时文件
rm -f "${NPMRC_FILE}"

echo ">>> 发布成功！"
