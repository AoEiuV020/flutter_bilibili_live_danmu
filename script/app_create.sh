#!/bin/sh
. "$(dirname $0)/env.sh"

name=$1
type=$2

# 检查包名是否提供
if [ -z "$name" ] || [ "$name" = "." ]; then
    echo "Error: Package name is required"
    exit 1
fi

# 检查并创建目录
if [ ! -d "$apps_dir" ]; then
    echo "Directory $apps_dir does not exist. Creating..."
    mkdir -p "$apps_dir"
fi
cd "$apps_dir"
if [ "$type" = "console" ]; then
    dart create "$name" "${@:3}"
    cd "$name"
else
    # 删除各平台代码
    rm -rf windows/ macos/ linux/ ios/ android/ web/
    flutter create --org "$organization" --template=app "$name" "${@:2}"
    cd "$name"
fi
if [ "$type" = "console" ]; then
    echo 'include: package:lints/recommended.yaml' >analysis_options.yaml
else
    echo 'include: package:flutter_lints/flutter.yaml' >analysis_options.yaml
fi
cat "$script_dir"/analyzer_custom.yaml >>analysis_options.yaml

# 更新 workspace 配置
update_workspace "$ROOT" "$apps_dir/$name"

"$script_dir"/prepare.sh
