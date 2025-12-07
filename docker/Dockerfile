FROM ubuntu:20.04 AS build

# 设置非交互式环境，避免交互提示
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    sudo \
    python3 \
    python3-pip \
    cmake \
    ninja-build \
    pkg-config \
    clang \
    # 安装 Flutter Linux 开发依赖
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-10-dev \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Flutter SDK 到 /opt/flutter
RUN git clone --depth 1 --branch 3.38.4 https://github.com/flutter/flutter.git /opt/flutter

# 设置 Flutter 到 PATH
ENV PATH=/opt/flutter/bin:$PATH

WORKDIR /opt/flutter

# 进入 Flutter 目录并配置
RUN flutter config --no-analytics

# 预缓存 Linux 构建依赖
RUN flutter precache --linux

# 创建非 root 用户用于构建，家目录为 /app
RUN useradd -m -d /app -u 1000 app

# 设置 flutter 目录权限
RUN chown -R app:app /opt/flutter

# 切换到非 root 用户
USER app

# 设置工作目录
WORKDIR /app

# 复制整个工作区到容器中
COPY --chown=app:app . .

# 解析依赖
WORKDIR /app/apps/bilibili_live_danmu_proxy
RUN dart pub get

# 编译应用程序为独立可执行文件
RUN dart compile exe bin/bilibili_live_danmu_proxy.dart -o /app/server

FROM frolvlad/alpine-glibc

# 设置工作目录
WORKDIR /app

# 从构建阶段复制编译的可执行文件
COPY --from=build /app/server .

# 公开默认端口
EXPOSE 8080

# 设置入口点
# 配置文件应该挂载到 /app/config.properties
CMD ["/app/server", "-c", "/app/config.properties"]
