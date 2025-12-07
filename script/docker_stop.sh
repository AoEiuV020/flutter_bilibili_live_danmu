#!/bin/sh
. "$(dirname $0)/env.sh"

# Bilibili Live Danmu Proxy Docker 停止脚本
# 此脚本停止并删除 Docker 容器

echo "========================================"
echo "Bilibili Live Danmu Proxy Docker 停止"
echo "========================================"
echo ""

# 检查 Docker Compose 是否已安装
if ! command -v docker-compose > /dev/null; then
    echo "❌ 错误：Docker Compose 未安装或不在 PATH 中"
    exit 1
fi

# 进入 Docker 目录
cd "$ROOT/docker"

echo "🛑 停止并删除 Docker 容器..."
echo ""

# 停止并删除容器
docker-compose down

echo ""
echo "✅ 容器已停止并删除！"
