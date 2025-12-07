# 第一阶段：使用 cirrusci/flutter:stable 构建可执行文件
FROM cirrusci/flutter:stable as builder

WORKDIR /app

# 复制整个项目
COPY . .

# 进入代理项目目录并获取依赖
WORKDIR /app/apps/bilibili_live_danmu_proxy

RUN dart pub get

# 编译为独立的可执行文件
RUN dart compile exe bin/bilibili_live_danmu_proxy.dart -o /app/build/bilibili_live_danmu_proxy

# 第二阶段：使用 alpine 基础镜像，仅包含运行时依赖
FROM alpine:latest

# 安装 glibc 以支持 Dart 编译的二进制文件
RUN apk add --no-cache \
    glibc \
    glibc-bin

# 创建应用目录
WORKDIR /app

# 从构建阶段复制编译好的可执行文件
COPY --from=builder /app/build/bilibili_live_danmu_proxy /app/

# 创建默认配置文件目录
RUN mkdir -p /app/config

# 设置环境变量
ENV CONFIG_PATH=/app/config/config.properties
ENV LISTEN_ADDRESS=0.0.0.0
ENV LISTEN_PORT=8080

# 暴露端口
EXPOSE 8080

# 启动应用，支持通过环境变量或命令行参数传入配置文件路径
ENTRYPOINT ["/app/bilibili_live_danmu_proxy"]
CMD ["--config", "${CONFIG_PATH}"]
