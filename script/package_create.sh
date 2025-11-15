#!/bin/sh
. "$(dirname $0)/env.sh"

name=$1
exec=$2

# 检查包名是否提供
if [ -z "$name" ] || [ "$name" = "." ]; then
    echo "Error: Package name is required"
    exit 1
fi

# 检查并创建目录
if [ ! -d "$packages_dir" ]; then
    echo "Directory $packages_dir does not exist. Creating..."
    mkdir -p "$packages_dir"
fi
cd "$packages_dir"
if [ "$exec" = "flutter" ]; then
    flutter create --template=package "$name"
else
    dart create --template=package "$name"
fi
cd "$name"
if [ -f "$ROOT/LICENSE" ]; then
    cp -f "$ROOT/LICENSE" .
fi
if [ "$exec" = "flutter" ]; then
    echo 'include: package:flutter_lints/flutter.yaml' >analysis_options.yaml
else
    echo 'include: package:lints/recommended.yaml' >analysis_options.yaml
fi
cat "$script_dir"/analyzer_custom.yaml >>analysis_options.yaml

# 更新 workspace 配置
update_workspace "$ROOT" "$packages_dir/$name"

"$script_dir"/prepare.sh
