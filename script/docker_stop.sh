#!/bin/bash

# Bilibili Live Danmu Proxy Docker 停止脚本
# 此脚本停止并删除 Docker 容器

set -e  # 遇到错误立即退出

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 项目根目录
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Docker 目录
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "========================================"
echo "Bilibili Live Danmu Proxy Docker 停止"
echo "========================================"
echo ""

# 检查 Docker Compose 是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误：Docker Compose 未安装或不在 PATH 中"
    exit 1
fi

# 进入 Docker 目录
cd "$DOCKER_DIR"

echo "🛑 停止并删除 Docker 容器..."
echo ""

# 停止并删除容器
docker-compose down

echo ""
echo "✅ 容器已停止并删除！"
