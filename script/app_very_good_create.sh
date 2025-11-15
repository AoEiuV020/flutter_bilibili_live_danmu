#!/bin/sh
. "$(dirname $0)/env.sh"

name=$1

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
very_good create flutter_app --org-name "$organization" "$name"
cd "$name"
# sed -i '' '2,$d' analysis_options.yaml
# cat "$script_dir"/analyzer_custom.yaml >>analysis_options.yaml

# 更新 workspace 配置
update_workspace "$ROOT" "$apps_dir/$name"

"$script_dir"/prepare.sh
