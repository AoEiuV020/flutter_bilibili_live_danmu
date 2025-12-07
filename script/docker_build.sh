#!/bin/bash

# Bilibili Live Danmu Proxy Docker 构建脚本
# 此脚本进入 docker 目录并构建 Docker 镜像

set -e  # 遇到错误立即退出

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 项目根目录
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Docker 目录
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "========================================"
echo "Bilibili Live Danmu Proxy Docker 构建"
echo "========================================"
echo "项目根目录: $PROJECT_ROOT"
echo "Docker 目录: $DOCKER_DIR"
echo ""

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误：Docker 未安装或不在 PATH 中"
    exit 1
fi

# 检查 Docker Compose 是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误：Docker Compose 未安装或不在 PATH 中"
    exit 1
fi

# 进入 Docker 目录
cd "$DOCKER_DIR"

echo "📦 开始构建 Docker 镜像..."
echo ""

# 构建镜像
docker-compose build

echo ""
echo "✅ Docker 镜像构建完成！"
echo ""
echo "接下来可以运行以下命令启动容器："
echo "  ./script/docker_run.sh"
echo "或"
echo "  cd docker && docker-compose up -d"
