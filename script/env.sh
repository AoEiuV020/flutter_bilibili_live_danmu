#!/bin/sh
set -e
script_dir=$(cd $(dirname $0);pwd)
ROOT=$(dirname "$script_dir")
project_name=$(basename "$ROOT")
app_name=$(echo "$project_name" | tr -d '_')
apps_dir="$ROOT"/apps
packages_dir="$ROOT"/packages
organization=com.aoeiuv020

# 更新 workspace 配置的函数
update_workspace() {
  local root_path="${1:-$ROOT}"
  local module_path="${2:-}"
  
  dart "$script_dir/update_workspace.dart" "$root_path" "$module_path"
}
