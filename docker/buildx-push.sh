#!/bin/bash

# Docker Buildx 构建并推送到 Docker Hub 脚本
# 支持 arm64 和 amd64 架构，修复标签格式问题，增强健壮性
# 用法: ./buildx-push.sh [Docker Hub 用户名] [镜像名] [标签1] [标签2...]
# 示例: ./buildx-push.sh myusername myimage latest
#      ./buildx-push.sh myusername myimage v1.0.0 stable

set -euo pipefail  # 增强错误处理：未定义变量报错、管道失败直接终止（比 set -e 更严格）

# 色彩输出（保持原风格，优化显示效果）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录（修复符号链接场景下的路径问题）
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." &>/dev/null && pwd)  # 简化上级目录获取

# 参数处理（保持原逻辑，优化错误提示）
if [ $# -lt 3 ]; then
    echo -e "\n${RED}❌ 错误: 参数不足！至少需要 3 个参数${NC}"
    echo -e "\n${BLUE}📋 用法:${NC}"
    echo "  $0 <Docker Hub 用户名> <镜像名> <标签1> [标签2...]"
    echo -e "\n${BLUE}🌟 示例:${NC}"
    echo "  $0 myusername myimage latest"
    echo "  $0 myusername myimage v1.0.0 stable prod"
    echo ""
    exit 1
fi

DOCKER_USER="$1"
IMAGE_NAME="$2"
shift 2
IMAGE_TAGS=("$@")

# 核心优化1：显式添加 Docker Hub 域名（docker.io），避免标签格式错误
# 解决之前「AoEiuV020 被当作域名」的解析问题
declare -a IMAGE_REFS
for tag in "${IMAGE_TAGS[@]}"; do
    # 格式：docker.io/用户名/镜像名:标签（Docker Hub 标准格式，强制显式指定）
    IMAGE_REFS+=("docker.io/${DOCKER_USER}/${IMAGE_NAME}:${tag}")
done

# 打印配置信息（优化排版，更清晰）
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}🚀 Docker Buildx 多架构构建推送工具${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "📦 Docker Hub 用户名: ${GREEN}${DOCKER_USER}${NC}"
echo -e "📌 镜像名称:         ${GREEN}${IMAGE_NAME}${NC}"
echo -e "🏷️  镜像标签:         ${GREEN}${IMAGE_TAGS[*]}${NC}"
echo -e "💻 目标架构:         ${GREEN}linux/amd64, linux/arm64${NC}"
echo -e "📂 项目根目录:       ${GREEN}${PROJECT_ROOT}${NC}"
echo -e "📄 Dockerfile 路径:  ${GREEN}${SCRIPT_DIR}/Dockerfile${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# 检查 Docker 服务是否运行（新增：避免因 Docker 未启动导致的隐藏错误）
echo -e "${YELLOW}🔍 检查 Docker 服务状态...${NC}"
if ! docker info &>/dev/null; then
    echo -e "${RED}❌ 错误: Docker 服务未启动！请先启动 Docker${NC}"
    exit 1
fi

# 检查用户是否登录 Docker Hub（优化检查逻辑：精准匹配 docker.io 登录状态）
echo -e "${YELLOW}🔍 检查 Docker Hub 登录状态...${NC}"
if ! docker login --get-login docker.io &>/dev/null; then
    echo -e "${YELLOW}ℹ️  未登录 Docker Hub，请输入账号密码登录${NC}"
    docker login docker.io  # 显式指定登录 docker.io，避免混淆其他仓库
fi
echo -e "${GREEN}✅ Docker Hub 已登录${NC}\n"

# 检查 docker buildx 是否可用（保持原逻辑，优化错误提示）
echo -e "${YELLOW}🔍 检查 Docker Buildx 可用性...${NC}"
if ! docker buildx version &>/dev/null; then
    echo -e "${RED}❌ 错误: Docker Buildx 未安装或不可用！${NC}"
    echo -e "${BLUE}💡 解决方案:${NC}"
    echo "  1. Docker 版本需 ≥ 19.03（推荐 20.10+）"
    echo "  2. 启用 Buildx: docker buildx create --use"
    echo "  3. 参考官方文档: https://docs.docker.com/build/buildx/"
    exit 1
fi

# 检查或创建 builder 实例（优化：强制使用 --driver docker-container，支持多架构）
BUILDER_NAME="multiarch-builder"
echo -e "${YELLOW}🔍 检查 Buildx Builder 实例...${NC}"
# 改进检测逻辑：检查 builder 是否存在（不依赖 grep，避免格式问题）
if docker buildx ls --format "{{.Name}}" | grep -q "^${BUILDER_NAME}$"; then
    echo -e "${GREEN}✅ 使用现有 Builder 实例: ${BUILDER_NAME}${NC}"
    docker buildx use "$BUILDER_NAME" >/dev/null 2>&1 || {
        # 如果 use 失败，尝试删除旧的并重新创建
        echo -e "${YELLOW}ℹ️  重建 Builder 实例...${NC}"
        docker buildx rm "$BUILDER_NAME" --force 2>/dev/null || true
        docker buildx create --name "$BUILDER_NAME" --driver docker-container --use || {
            echo -e "${RED}❌ 创建 Builder 实例失败！${NC}"
            exit 1
        }
    }
else
    echo -e "${YELLOW}ℹ️  创建 Buildx Builder 实例: ${BUILDER_NAME}${NC}"
    # --driver docker-container：支持多架构构建（默认 driver 可能不支持）
    docker buildx create --name "$BUILDER_NAME" --driver docker-container --use || {
        echo -e "${RED}❌ 创建 Builder 实例失败！${NC}"
        exit 1
    }
fi

# 构建前预热 Builder（新增：避免首次构建因镜像拉取超时失败）
echo -e "${YELLOW}ℹ️  预热 Builder 环境...${NC}"
docker buildx inspect --bootstrap >/dev/null  # 确保 builder 就绪
echo -e "${GREEN}✅ Builder 环境就绪${NC}\n"

# 构建 docker buildx 命令（优化：拆分参数，避免 eval 潜在风险）
echo -e "${YELLOW}🚀 开始构建并推送多架构镜像...${NC}\n"
BUILD_ARGS=(
    docker buildx build
    --platform linux/amd64,linux/arm64  # 目标架构
    --push                              # 直接推送
    --progress=plain                    # 显示详细构建日志
    --file "${SCRIPT_DIR}/Dockerfile"   # 指定 Dockerfile 路径
    "${PROJECT_ROOT}"                   # 构建上下文
)

# 添加所有镜像标签（替代 eval，更安全）
for ref in "${IMAGE_REFS[@]}"; do
    BUILD_ARGS+=(--tag "$ref")
done

# 执行构建（直接执行数组，避免 eval 注入风险）
"${BUILD_ARGS[@]}"

# 检查构建结果（保持原逻辑，优化输出）
BUILD_EXIT_CODE=$?
echo -e "\n${YELLOW}========================================${NC}"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}🎉 构建并推送成功！${NC}"
    echo -e "${YELLOW}========================================${NC}\n"
    echo -e "${BLUE}📦 推送的镜像列表:${NC}"
    for ref in "${IMAGE_REFS[@]}"; do
        echo -e "  ${GREEN}✔️  ${ref}${NC}"
    done
    echo -e "\n${BLUE}💡 拉取镜像命令示例:${NC}"
    for ref in "${IMAGE_REFS[@]}"; do
        echo "  docker pull ${ref}"
    done
else
    echo -e "${RED}❌ 构建或推送失败！退出码: ${BUILD_EXIT_CODE}${NC}"
    echo -e "${BLUE}💡 排查建议:${NC}"
    echo "  1. 检查 Docker Hub 账号是否有推送权限"
    echo "  2. 确认网络通畅（国内可配置 Docker 加速器）"
    echo "  3. 查看上方详细日志，定位构建失败原因"
    echo -e "${YELLOW}========================================${NC}"
    exit $BUILD_EXIT_CODE
fi

echo -e "\n${GREEN}👌 脚本执行完成！${NC}"