#!/usr/bin/env dart

import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart update_workspace.dart <root_path> [module_path]');
    exit(1);
  }

  final rootPath = arguments[0];
  final modulePath =
      arguments.length > 1 && arguments[1].isNotEmpty ? arguments[1] : null;

  // 更新子模块的 pubspec.yaml（如果提供了路径）
  if (modulePath != null) {
    updateModulePubspec(modulePath);
  }

  // 更新根目录的 pubspec.yaml
  updateRootPubspec(rootPath, modulePath);
}

void updateModulePubspec(String modulePath) {
  final pubspecFile = File('$modulePath/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Warning: Module pubspec.yaml not found at $modulePath');
    return;
  }

  final content = pubspecFile.readAsStringSync();

  // 检查是否已存在 resolution
  if (content.contains('resolution:')) {
    print('resolution: workspace already exists in $modulePath/pubspec.yaml');
    return;
  }

  final lines = content.split('\n');
  final updatedLines = <String>[];
  var environmentFound = false;
  var resolutionAdded = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    updatedLines.add(line);

    // 找到 environment 节
    if (!resolutionAdded && line.trimLeft().startsWith('environment:')) {
      environmentFound = true;
      final environmentIndent = line.substring(0, line.indexOf('environment:'));

      // 跳过 environment 的内容
      var j = i + 1;
      while (j < lines.length &&
          lines[j].trim().isNotEmpty &&
          (lines[j].startsWith('$environmentIndent  ') ||
              lines[j].trim().startsWith('#'))) {
        updatedLines.add(lines[j]);
        j++;
      }
      i = j - 1;

      // 添加空行和 resolution
      updatedLines.add('');
      updatedLines.add('${environmentIndent}resolution: workspace');
      resolutionAdded = true;
    }
  }

  // 如果没找到 environment
  if (!environmentFound) {
    print('Warning: No environment section found in $modulePath/pubspec.yaml');
    return;
  }

  if (resolutionAdded) {
    pubspecFile.writeAsStringSync(updatedLines.join('\n'));
    print('Added resolution: workspace to $modulePath/pubspec.yaml');
  }
}

void updateRootPubspec(String rootPath, String? newModulePath) {
  final pubspecFile = File('$rootPath/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: Root pubspec.yaml not found at $rootPath');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final lines = content.split('\n');

  // 解析现有的 workspace 条目
  final workspaceSet = <String>{};
  var inWorkspaceSection = false;

  for (final line in lines) {
    if (line.trimLeft().startsWith('workspace:')) {
      inWorkspaceSection = true;
      continue;
    }
    if (inWorkspaceSection) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ')) {
        workspaceSet.add(trimmed.substring(2).trim());
      } else if (!trimmed.isEmpty && !line.startsWith('  ')) {
        inWorkspaceSection = false;
      }
    }
  }

  // 添加新模块（如果提供）
  if (newModulePath != null) {
    // 转换为相对于根目录的路径
    final relativePath = newModulePath.startsWith(rootPath)
        ? newModulePath.substring(rootPath.length + 1)
        : newModulePath;
    workspaceSet.add(relativePath);
  }

  // 排序
  final sortedWorkspace = workspaceSet.toList()..sort();

  // 重建 pubspec.yaml
  final updatedLines = <String>[];
  var environmentFound = false;
  var workspaceFound = false;
  var environmentIndent = '';
  var skipUntilNextSection = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmedLine = line.trimLeft();

    // 跳过旧的 workspace 块
    if (trimmedLine.startsWith('workspace:')) {
      workspaceFound = true;
      skipUntilNextSection = true;
      continue;
    }

    if (skipUntilNextSection) {
      // 如果是列表项或空行，继续跳过
      if (line.trim().isEmpty || trimmedLine.startsWith('- ')) {
        continue;
      } else if (!line.startsWith('  ') &&
          !line.startsWith('\t') &&
          line.trim().isNotEmpty) {
        // 遇到下一个顶级节，停止跳过
        skipUntilNextSection = false;
      } else {
        continue;
      }
    }

    // 找到 environment 节
    if (trimmedLine.startsWith('environment:')) {
      environmentFound = true;
      environmentIndent = line.substring(0, line.indexOf('environment:'));
      updatedLines.add(line);

      // 添加 environment 的内容
      var j = i + 1;
      while (j < lines.length) {
        final nextLine = lines[j];
        if (nextLine.trim().isEmpty) {
          j++;
          continue;
        }
        if (nextLine.startsWith('$environmentIndent  ') ||
            nextLine.trim().startsWith('#')) {
          updatedLines.add(nextLine);
          j++;
        } else {
          break;
        }
      }
      i = j - 1;

      // 在 environment 后添加 workspace（如果还没有添加）
      if (!workspaceFound && sortedWorkspace.isNotEmpty) {
        updatedLines.add('');
        updatedLines.add('${environmentIndent}workspace:');
        for (final path in sortedWorkspace) {
          updatedLines.add('$environmentIndent  - $path');
        }
        updatedLines.add('');
        workspaceFound = true;
      }
      continue;
    }

    updatedLines.add(line);
  }

  // 如果没有找到 environment 但有 workspace 条目要添加
  if (!environmentFound && sortedWorkspace.isNotEmpty) {
    print('Warning: No environment section found in root pubspec.yaml');
  }

  pubspecFile.writeAsStringSync(updatedLines.join('\n'));
  print('Updated root pubspec.yaml with workspace entries');
}
