
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

1. 添加初始化参数处理，参考 apps/bilibili_live_danmu/lib/options/parse.dart，这是其他项目扣来的代码，没用的都删了， 
1. 实际参数参考 apps/bilibili_live_danmu_proxy/bin/bilibili_live_danmu_proxy.dart apps/bilibili_live_danmu/lib/home_page.dart ，首页填写的都要支持从参数获取，
1. 在apps/bilibili_live_danmu/lib/main.dart添加参数解析，保存为静态变量，方便全局访问，
1. 参数相关代码尽量都放在 apps/bilibili_live_danmu/lib/options 目录下，方便管理，
1. home使用时优先使用参数变量，如果判断参数包含必填项目，就自动点击开始按钮，

1. 参数加上config文件路径，直接读取，优先级比其他参数低，内容和apps/bilibili_live_danmu/assets/config.properties一致，

1. 你™谁叫你把home里的assets/config.properties处理删除了，折合我叫你做的事有任何关系吗，
这个assets是兜底的，优先级最低，不要删，

1. apps/bilibili_live_danmu/lib/home_page.dart:127这个处理不太好， 检查自动连接应该仅启动时，改到 initState 等其他完成后再执行，

1. _initializeTts 改成异步， 实际上initialize本来就是异步的， 然后一起等待都完成了才检查自动连接，

1. 参考packages/bilibili_live_api/lib/src/interceptors/logger_interceptor.dart:6， 所有模块依赖logger,并添加模块内部使用的唯一logger示例， 单独文件存放，
1. 每个logger仅自己模块可见，找到项目内其他所有日志打印， 统一使用这个logger打印，重点搜索print和debugPrint，另外packages/bilibili_live_api/lib/src/utils/logger.dart也处理掉，
1. 两个库模块不要设置printer， 由两个app模块设置统一的defaultPrinter，


1. 继续，
1. 我™是不是说过了， 两个库模块不要设置printer，你为什么非要搞一个？
1. 文件路径怎么不统一一下， 全部放在lib/logger.dart,
1. 改完后对两个app模块build确保正确，


1.  两个库模块啊两个， packages/bilibili_live_api_server/lib/src/logger.dart:6 这个也不要printer,

1. 所有logger.e用的太草率了，如果有error和stacktrace就传入，全部检查一遍，
1. 日志分级啊，别一大堆的.d.i, 该error的用error， 所有catch捕获的错误都用error级别打印， 其他情况按实际情况使用debug/info/warning级别，

1. 我说了两个app模块设置统一的defaultPrinter你到底听没听？defaultPrinter在哪里，
1. defaultPrinter要第一时间处理，否则可能打印时还没初始化，
1. 四个logger文件调整统一lib/src/logger.dart, 全部统一，不要漏了，

1. 你™到底知道不知道defaultPrinter是什么东西，我让你设置defaultPrinter你在干嘛，
```
static LogPrinter Function() defaultPrinter = () => PrettyPrinter();
```
Logger参数的printer全都不传，
1. 继续

1. 你™别偷懒啊， 运行确认一下改好了吗那就结束？


1. apps/bilibili_live_danmu_proxy/bin/bilibili_live_danmu_proxy.dart 挤太多代码了， 功能实现全部放到lib目录下， 只留main函数在这里，
1. 注意import该相对路径，
1. 运行main测试，

1. 还是太挤了， 多拆几个文件， 

1. import src不离谱吗， 做好导出啊，

1. 你™导出一大堆是要干嘛， 实际需要的不就apps/bilibili_live_danmu_proxy/bin/bilibili_live_danmu_proxy.dart:1 这里一个， 

1. 我让你拆代码， 你偷偷改了啥啊， 现在一启动就自动退出了， 
1. 入口肯定要单独一个文件初始化defaultPrinter，否则报错都看不到， 
1. 使用apps/bilibili_live_danmu/assets/config.properties配置运行测试， 

1. 禁用exit，好好退出， 
1. apps/bilibili_live_danmu_proxy/lib/bilibili_live_danmu_proxy.dart:1 不要乱搞了，这里就只放一个main，在这里初始化defaultPrinter，捕获打印所有异常，
1. 所有模块的lib/src/logger.dart中的logger初始化改用late, 不要搞initializeLoggerInstance，

1. 你™怎么就听不懂， main函数逻辑全部放在 apps/bilibili_live_danmu_proxy/lib/bilibili_live_danmu_proxy.dart ， 而apps/bilibili_live_danmu_proxy/bin/bilibili_live_danmu_proxy.dart只复制调用main,
1. 不要apps/bilibili_live_danmu_proxy/lib/src/initializer.dart
1. 你的sleep 3 && pkill 无效，没有正确关闭，
1. 继续，

AI死活改不好，
