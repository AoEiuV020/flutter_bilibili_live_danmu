#!/bin/sh
. "$(dirname $0)/env.sh"

# Bilibili Live Danmu Proxy Docker 运行脚本
# 此脚本进入 docker 目录并使用 docker-compose 启动容器

echo "========================================"
echo "Bilibili Live Danmu Proxy Docker 运行"
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

# 检查配置文件是否存在
if [ ! -f "$ROOT/docker/config.properties" ]; then
    echo "⚠️  警告：未找到 config.properties 文件"
    echo "请在项目根目录创建 config.properties 文件"
    echo "示例可参考：docker/README.md"
    echo ""
    printf "继续启动容器吗？(y/n) "
    read reply
    if [ "$reply" != "y" ] && [ "$reply" != "Y" ]; then
        echo "已取消"
        exit 1
    fi
fi

# 进入 Docker 目录
cd "$ROOT/docker"

echo "🚀 启动 Docker 容器..."
echo ""

# 启动容器（后台运行）
docker-compose up -d

echo ""
echo "✅ 容器已启动！"
echo ""
echo "有用的命令："
echo "  查看日志:        docker-compose logs -f"
echo "  停止容器:        docker-compose down"
echo "  进入容器:        docker-compose exec bilibili-live-danmu-proxy sh"
echo "  查看容器状态:    docker-compose ps"
echo ""
echo "应用地址: http://localhost:8080"
