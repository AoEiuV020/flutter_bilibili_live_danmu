
1. packages/bilibili_live_api/lib/src/utils 添加一个日志封装，简单的，不依赖flutter，
1. 全局搜索debugPrint，替换为这个日志封装,
1. 全局搜索print，替换为这个日志封装,


1. 日志级别处理好，不要都用debug, 另外加上info级别，


1. packages/bilibili_live_api/pubspec.yaml 改成dart package,不依赖flutter，
1. packages/bilibili_live_api搜索所有flutter相关的import，删除掉，要编译通过不报错，


1. 实现packages/bilibili_live_api_server，效果是监听http端口，转发到packages/bilibili_live_api/lib/src/bilibili_live_api_client.dart，
1. 找个合适的http server库接收请求，
1. 要支持完全一样的功能，一样的参数和返回， 唯独去掉认证，
1. 要避免corss origin问题，允许任意来源请求，
1. 参考 apps/bilibili_live_danmu/assets/config.properties ， 初始化时传入必要的accessKey，剩下的参数可选，用可空类型处理，
1. http请求进入时，已经配置了的参数可以不填，不做错误处理， 直接判断已有且没传入就用已有的，都没有就直接给空字符串''，不要报错，
1. 使用时要支持简单new初始化然后启动就监听端口，端口可选，
1. 要支持主动停止服务，
1. 实现 apps/bilibili_live_danmu_proxy，依赖 packages/bilibili_live_api_server ， 读取配置文件，初始化服务，
1. 配置文件参考 apps/bilibili_live_danmu/assets/config.properties
1. 服务有任何意外不要自动重启，直接退出程序，
1. 监听必要的信号进行优雅关闭，
1. 需要支持命令行参数解析， 配置文件路径可选，文件内的每一个参数都可以通过命令行参数传入覆盖，最终要保证accessKey两个变量一定有值，其他都可选，

