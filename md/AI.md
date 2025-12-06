
1. packages/bilibili_live_api/lib/src/utils 添加一个日志封装，简单的，不依赖flutter，
1. 全局搜索debugPrint，替换为这个日志封装,
1. 全局搜索print，替换为这个日志封装,


1. 日志级别处理好，不要都用debug, 另外加上info级别，


1. packages/bilibili_live_api/pubspec.yaml 改成dart package,不依赖flutter，
1. packages/bilibili_live_api搜索所有flutter相关的import，删除掉，要编译通过不报错，

