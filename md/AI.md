
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



1. apps/bilibili_live_danmu 找个合适位置添加http服务开关，web端也显示但是不可开启，
1. 在LivePage判断服务是否开启，开启则通过packages/bilibili_live_api_server创建服务，
1. 页面关闭时关闭服务，
1. apps/bilibili_live_danmu/lib/home_page.dart 添加一个输入框，填写后端地址，可空，空了代表默认当前代码的效果，也就是直接使用packages/bilibili_live_api请求官方接口，
1. 后端地址非空的话把地址传进BilibiliLiveApiClient，调整BilibiliLiveApiClient支持可选后端地址参数，同时accessKey也就变成可选了,二选一，accessKey为空时就不需要传递认证，
1. 顺便apps/bilibili_live_danmu_proxy/bin/bilibili_live_danmu_proxy.dart也添加支持配置后端地址，有这个时accessKey可空，没有这个时accessKey必须有值，

1. packages/bilibili_live_api/lib/src/bilibili_live_api_client.dart:43 一大堆empty判断太丑了， 没必要，null判断就够了， 而且你都已经封装getter了当然优先用封装好的isProxyMode，
1. 继续

1. apps/bilibili_live_danmu/lib/live_page.dart:106 code不能乱取， 也得从前一页传入，
1. 首页太挤了， 后端设置和http服务开关放到设置页去， 不过判断如果是web版就显示后端设置，不显示accessKey设置，
1. 添加设置页， 从首页右上角添加齿轮按钮进入，
1. 设置页基本就显示apps/bilibili_live_danmu/lib/widgets/settings_panel.dart， 加个可选参数代表不是工作中，
1. 非工作中才显示新加的http服务开关和后端地址输入框，另外加上服务端口设置，默认你安排一个大于10000的端口号，

1. apps/bilibili_live_danmu/lib/home_page.dart:229 你把这个禁用了干嘛， 让你显示后端设置就是要直接编辑使用的，
1. 考虑同步，进入设置页之前也得保存当前输入，
1. apps/bilibili_live_danmu/lib/widgets/settings_panel.dart:23 非工作状态下这些回调不是必填的， 调整判断，调整设置页不传不需要的回调，
1. apps/bilibili_live_danmu/lib/settings_page.dart:83 别独立出服务设置， 全部放进panel中一视同仁， 只是区分显示不显示而已，

1. apps/bilibili_live_danmu/lib/widgets/settings_panel.dart:45 干嘛非要搞不同， 新加的服务设置板块就给我好好参考原有的设置，添加一个板块不就好了，我说了唯一特殊在于工作状态隐藏ui，其他都可以正常处理，

1. 我™说的不是ui啊， 是settingsManager，你给我看好了其他设置是怎么实现的再重写服务设置， 


1. apps/bilibili_live_danmu/lib/models/settings.dart:272 这块又是url encode又是map的也太坑了， 普通一点， 一个设置一个key，
1. 注意同样内容key要个apps/bilibili_live_danmu/lib/home_page.dart统一，

1. apps/bilibili_live_danmu/lib/models/settings.dart:213 啥玩意儿这一堆key有屁用，和其他设置一样的处理啊， 

1. apps/bilibili_live_danmu/lib/home_page.dart:117 后端地址也得保存， 

1. apps/bilibili_live_danmu/lib/home_page.dart:266 代理模式下app id 和code都可以为空，

1. 你™我只让你改成可空， 没让你禁用掉，

1. apps/bilibili_live_danmu/lib/home_page.dart:166 可空字段使用需要判断， 这还要我教你吗？
1. 而且client.start里这些字段code/appId早该改成可空的了，

1. packages/bilibili_live_api_server/lib/src/bilibili_live_api_server.dart:260 添加针对 packages/bilibili_live_api/lib/src/models/response_parser.dart:2 的处理，
