# Docker 构建和运行说明

## 快速开始

### 前置条件
- Docker 已安装
- Docker Compose 已安装
- 根目录下需要有 `config.properties` 配置文件

### 文件说明

- `Dockerfile`: 多阶段构建文件
  - 第一阶段：使用 `cirrusci/flutter:stable` 编译 Dart 代码为独立可执行文件
  - 第二阶段：使用 `alpine` 镜像运行，仅包含必要的运行时依赖（glibc）

- `docker-compose.yaml`: Docker Compose 配置文件
  - 自动从项目根目录挂载 `config.properties`
  - 暴露 8080 端口（可修改）
  - 包含日志配置和健康检查

### 构建镜像

```bash
# 方式1：使用脚本（推荐）
./script/docker_build.sh

# 方式2：直接使用 docker-compose
cd docker
docker-compose build
```

### 运行容器

```bash
# 方式1：使用脚本（推荐）
./script/docker_run.sh

# 方式2：直接使用 docker-compose
cd docker
docker-compose up -d
```

### 查看日志

```bash
cd docker
docker-compose logs -f
```

### 停止容器

```bash
cd docker
docker-compose down
```

### 配置文件

在项目根目录创建 `config.properties` 文件，内容示例：

```properties
# 日志级别 (DEBUG, INFO, WARN, ERROR)
log.level=INFO

# API 服务器地址
backend.url=http://api.example.com

# 或使用 Access Key（与 backend.url 二选一）
access.key.id=your_key_id
access.key.secret=your_key_secret
```

### 自定义端口

修改 `docker-compose.yaml` 中的 ports 配置：

```yaml
ports:
  - "9090:8080"  # 将宿主机 9090 端口映射到容器 8080
```

或通过环境变量：

```bash
cd docker
LISTEN_PORT=9090 docker-compose up
```

### 进入容器调试

```bash
docker-compose exec bilibili-live-danmu-proxy sh
```

## 环境变量

可通过 `docker-compose.yaml` 或命令行设置以下环境变量：

- `CONFIG_PATH`: 配置文件路径（默认：`/app/config/config.properties`）
- `LISTEN_ADDRESS`: 监听地址（默认：`0.0.0.0`）
- `LISTEN_PORT`: 监听端口（默认：`8080`）
