#!/bin/sh
. "$(dirname $0)/env.sh"

# Bilibili Live Danmu Proxy Docker 构建脚本
# 此脚本进入 docker 目录并构建 Docker 镜像

echo "========================================"
echo "Bilibili Live Danmu Proxy Docker 构建"
echo "========================================"
echo "项目根目录: $ROOT"
echo "Docker 目录: $ROOT/docker"
echo ""

# 检查 Docker 是否已安装
if ! command -v docker > /dev/null; then
    echo "❌ 错误：Docker 未安装或不在 PATH 中"
    exit 1
fi

# 检查 Docker Compose 是否已安装
if ! command -v docker-compose > /dev/null; then
    echo "❌ 错误：Docker Compose 未安装或不在 PATH 中"
    exit 1
fi

echo ""
echo "📦 开始构建 Docker 镜像..."
echo ""

# 进入 Docker 目录构建
cd "$ROOT/docker"
docker-compose build

echo ""
echo "✅ Docker 镜像构建完成！"
echo ""
echo "接下来可以运行以下命令启动容器："
echo "  ./script/docker_run.sh"
echo "或"
echo "  cd docker && docker-compose up -d"
