# AGXWidget

自定义页面组件.

#####Constants

- AGXAnimateType

    动画类型枚举, 如平移/透明/翻页/缩放等.

- AGXAnimateDirection

    动画方向枚举, 指定平移/翻页动画方向.

- AGXAnimation

    动画设置结构体, 定义动画类型&方向&持续时间&延迟时间.

- AGXAnimationMake

    动画构造方法.

- AGXTransition

    转场动画设置结构体, 定义转场动画类型&方向&持续时间.

- AGXTransitionMake

    转场动画构造方法.

- AGXNavigationDefaultPushTransition

    导航控制器Push操作默认转场动画, 从右侧移入并淡入淡出, 0.3秒.

- AGXNavigationDefaultPopTransition

    导航控制器Pop操作默认转场动画, 向右侧移出并淡入淡出, 0.3秒.

#####Components

- AGXLine

    自适应线条视图.

```objective-c
// 属性
lineColor
lineDirection // 指定线条方向
lineWidth // 指定宽度像素值
ceilAdjust // 绘制线条时会因反锯齿效果导致线条失真, 默认向下调整线条位置, 设置此值为真则改为向上调整
dashPhase // 虚线设置
dashLengths // 虚线设置
```

- AGXLabel

    扩展UILabel, 可复制文本内容.

```objective-c
// 统一默认设置
self.backgroundColor = [UIColor clearColor];

// 添加长按手势弹出菜单.

// 添加属性
canCopy // 是否长按弹出复制菜单

// 弹出菜单数据源
id<AGXLabelDataSource> dataSource

AGXLabelDataSource
-menuTitleStringOfCopyInLabel:
-menuLocationPointInLabel:
```

- AGXImageView

    扩展UIImageView, 可复制/保存图片.

```objective-c
// 添加长按手势弹出菜单.

// 添加属性
canCopy // 是否长按弹出复制菜单
canSave // 是否长按弹出保存菜单

// 弹出菜单数据源
id<AGXImageViewDataSource> dataSource

AGXImageViewDataSource
-menuTitleStringOfCopyInImageView:
-menuTitleStringOfSaveInImageView:
-menuLocationPointInImageView:

// 弹出菜单功能托管
id<AGXImageViewDelegate> delegate

AGXImageViewDelegate
-saveImageSuccessInImageView:
-saveImageFailedInImageView:withError:
```

- AGXRefreshView

    滚动刷新工具视图.

```objective-c
// 属性
direction // 滚动刷新方向
defaultPadding // 初始边界距离
pullingMargin // 刷新边界距离
loadingMargin // 刷新中边界距离

// 可重写方法
-didScrollView:
-didEndDragging:
-didFinishedLoading:
-setRefreshState:

// 托管方法
-refreshViewIsLoading: // 返回当前刷新状态
-refreshViewStartLoad: // 开始刷新回调
```

- AGXPageControl

    分页指示器.

```objective-c
// 添加属性
pageIndicatorColor // 默认指示色
currentPageIndicatorColor // 当前页指示色
```

- AGXSwitch

    开关控件.

```objective-c
// 添加属性
slideHeight // 开关滑道高度
thumbRadius // 开关滑块半径
onColor // 开启状态滑道颜色 default 4cd864
offColor // 关闭状态滑道颜色 default e4e4e4
thumbColor // 滑块颜色 default white
on // 开关状态

// 添加方法
-setOn:animated:
```

- AGXSearchBar

    搜索栏组件.

- AGXProgressHUD

    重命名MBProgressHUD: Created by Matej Bukovinski, Version 0.9.1.

    增加全局设置, 不定时HUD的最短显示时间, 默认0.5秒:
    AGXHUDMinShowTime

    增加分类:

```objective-c
// UIView+AGXHUD

// 在当前视图内的HUD字体属性
hudLabelFont
hudDetailsLabelFont

// 在当前视图内显隐HUD的简易方法:
-agxProgressHUD
-showLoadingHUD:title:
-showLoadingHUD:title:detail:
-showMessageHUD:title:duration:
-showMessageHUD:title:detail:duration: // 第一个参数指定是否阻挡主界面用户交互
-hideHUD
```

```objective-c
// UIView+AGXHUDRecursive

// 在当前视图及其子视图内的HUD字体属性
recursiveHudLabelFont
recursiveHudDetailsLabelFont

// 在当前视图及其子视图内显隐HUD的简易方法:
-recursiveAGXProgressHUD
-showRecursiveLoadingHUD:title:
-showRecursiveLoadingHUD:title:detail:
-showRecursiveMessageHUD:title:duration:
-showRecursiveMessageHUD:title:detail:duration: // 第一个参数指定是否阻挡主界面用户交互
-hideRecursiveHUD
```

```objective-c
// UIApplication+AGXHUD

// 在当前主窗口内显隐HUD的简易方法:
+showLoadingHUD:title:
+showLoadingHUD:title:detail:
+showMessageHUD:title:duration:
+showMessageHUD:title:detail:duration:
+hideHUD
```

```objective-c
// UIApplication+AGXHUDRecursive

// 在当前主窗口及其子视图内显隐HUD的简易方法:
+showRecursiveLoadingHUD:title:
+showRecursiveLoadingHUD:title:detail:
+showRecursiveMessageHUD:title:duration:
+showRecursiveMessageHUD:title:detail:duration:
+hideRecursiveHUD
```

- AGXProgressBar

    进度条组件.

```objective-c
// 添加属性.
progressColor // default 167efb
progressDuration // default 0.3
fadingDuration // default 0.3
fadeDelay // default 0.1
progress // 进度值, 0.0..1.0

// 样式设置
+progressColor
+setProgressColor:

// 进度设置方法.
-setProgress:animated:
```

- AGXWebView

    扩展UIWebView, 嵌入JS与ObjC交互.

```objective-c
// 添加全局设置, 嵌入的JS对象名, 默认为AGXB.
AGXBridgeInjectJSObjectName

// 添加属性
coordinateBackgroundColor // 默认为YES, 使用网页document.body的背景色填充当前视图, 未设置body背景色则默认为#000000
progressColor // 进度条颜色, 默认(22, 126, 251, 255)
progressWidth // 进度条宽度, 默认2

// 样式设置
+progressColor
+setProgressColor:
+progressWidth
+setProgressWidth:

// 实例方法
// 指定JS嵌入处理回调, 需要在页面加载前调用, 页面加载完成后可使用AGXB.handlerName方法调用ObjC代码
-registerHandlerName:handler:selector:
// 指定JS嵌入处理回调, 可指定嵌入的JS对象名, 默认参考AGXBridgeInjectJSObjectName
-registerHandlerName:handler:selector:inScope:
// 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即调用注册的Block
-registerTriggerAt:withBlock:
// 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即在页面内执行指定JavaScript代码
-registerTriggerAt:withJavascript:
// 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即在页面内执行指定JavaScript代码, 并传递paramKeyPath指定的属性值列表为参数列表
-registerTriggerAt:withJavascript:paramKeyPath:...
// 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即在页面内执行指定JavaScript代码, 并传递paramKeyPaths指定的属性值列表为参数列表
-registerTriggerAt:withJavascript:paramKeyPaths:

// 初始添加JS方法
void AGXB.reload() // 重新载入
void AGXB.stopLoading() // 停止载入
void AGXB.goBack() // 后退
void AGXB.goForward() // 前进
bool AGXB.canGoBack() // 检查是否可后退
bool AGXB.canGoForward() // 检查是否可前进
bool AGXB.isLoading() // 检查是否加载中
void AGXB.scaleFit() // 缩放页面以适应窗口
void AGXB.setBounces(boolValue) // 设置页面是否可拖拽超出边框
void AGXB.setBounceHorizontal(boolValue) // 设置页面是否可水平拖拽超出边框
void AGXB.setBounceVertical(boolValue) // 设置页面是否可垂直拖拽超出边框
void AGXB.setShowHorizontalScrollBar(boolValue) // 设置是否展示水平滚动条
void AGXB.setShowVerticalScrollBar(boolValue) // 设置是否展示垂直滚动条
void AGXB.alert({ "style":string, "title":string, "message":string, "button":string, "callback":function(){} }) // 警告弹窗, style默认为AlertView样式, 可设置为"sheet"使用ActionSheet样式
void AGXB.confirm({ "style":string, "title":string, "message":string, "cancelButton":string, "cancelCallback":function(){}, "confirmButton":string, "confirmCallback":function(){} }) // 确认弹窗, style默认为AlertView样式, 可设置为"sheet"使用ActionSheet样式, 注: AlertView中, cancelButton为靠左的按钮, confirmButton为靠右的按钮
void AGXB.HUDMessage({ "title":string, "message":string, "delay":float, "fullScreen":bool, "opaque":bool }) // 展示透明提示信息, 默认delay为2(s), 默认不全屏覆盖, 默认阻挡主界面用户交互
void AGXB.HUDLoading({ "message":string, "fullScreen":bool, "opaque":bool }) // 展示透明进度提示, 使用HUDLoaded关闭提示, 默认不全屏覆盖, 默认阻挡主界面用户交互
void AGXB.HUDLoaded() // 关闭透明进度提示
void AGXB.saveImageToAlbum({ "url":string, "savingTitle":string, "successTitle":string, "failedTitle":string, "savingCallback":jsfunction, "failedCallback":jsfunction('reason'), "successCallback":jsfunction }) // 保存图片到相册, titles参数非必传, 用于指定保存时的透明提示信息, callbacks参数非必传, 用于不同情景的页面回调, 默认展示透明提示信息
void AGXB.loadImageFromAlbum({ "editable":bool, "callback":function(imageURL){}, "title":string, "message":string, "button":string }) // 从相册加载图片, 回调返回图片srcURL字符串, title/message/button指定无权限时弹出的提示信息
void AGXB.loadImageFromCamera({ "editable":bool, "callback":function(imageURL){}, "title":string, "message":string, "button":string }) // 从相机加载图片, 回调返回图片srcURL字符串, title/message/button指定无权限时弹出的提示信息
void AGXB.loadImageFromAlbumOrCamera({ "editable":bool, "callback":function(imageURL){}, "title":string, "message":string, "button":string, "cancelButton":string, "albumButton":string, "cameraButton":string }) // 从相册或相机加载图片, 回调返回图片srcURL字符串, title/message/button指定无权限时弹出的提示信息, cancelButton/cameraButton/albumButton指定弹出选择Sheet的提示信息
string AGXB.recogniseQRCode("image url string") // 识别图片中的二维码, 参数为图片URL字符串, 返回识别的二维码内容字符串 (需引入AGXGcode库以启用)
```

- AGXWebViewController

    默认的AGXWebView控制器.

```objective-c
// 添加全局设置, 本地资源存放的Bundle名称.
AGXLocalResourceBundleName

// 添加属性
useDocumentTitle // 默认为YES, 使用加载的Web文档的title作为导航栏标题
goBackOnBackBarButton // 默认为YES, 返回按钮在网页可返回前一页时触发goBack, 否则弹出当前ViewController
autoAddCloseBarButton // 默认为YES, 自动添加关闭按钮, 用于在导航栈中直接弹出当前ViewController
closeBarButtonTitle // 自动添加的关闭按钮的文字标题
goBackOnPopGesture // 默认为YES, 可以使用从左向右的手势触发goBack
goBackPopPercent // 手势触发goBack时, 操作确认或取消的滑动距离临界值百分比

// 实例方法
-registerHandlerName:handler:selector:
-registerHandlerName:handler:selector:inScope:
-registerTriggerAt:withBlock:
-registerTriggerAt:withJavascript:
-registerTriggerAt:withJavascript:paramKeyPath:...
-registerTriggerAt:withJavascript:paramKeyPaths:

// 桥接设置
-defaultPushViewControllerClass // 桥接控制导航推入页面时, 使用的默认视图控制器类, 默认为AGXWebViewController

// 初始添加JS方法
void AGXB.setTitle("string") // 设置导航栏标题
void AGXB.setPrompt("string") // 设置导航栏标注
void AGXB.setBackTitle("string") // 设置当前页面返回按钮展示文字
void AGXB.setChildBackTitle("string") // 设置下级页面返回按钮展示文字
void AGXB.setLeftButton({ "title/system":string, "callback":function(){} }) // 设置导航左侧按钮标题或系统图标与回调函数
void AGXB.setRightButton({ "title/system":string, "callback":function() {} }) // 设置导航右侧按钮标题或系统图标与回调函数
// 注: system参数可取值为UIBarButtonSystemItem枚举项的后缀部分字符串
"done"           UIBarButtonSystemItemDone
"cancel"         UIBarButtonSystemItemCancel
"edit"           UIBarButtonSystemItemEdit
"save"           UIBarButtonSystemItemSave
"add"            UIBarButtonSystemItemAdd
"flexiblespace"  UIBarButtonSystemItemFlexibleSpace
"fixedspace"     UIBarButtonSystemItemFixedSpace
"compose"        UIBarButtonSystemItemCompose
"reply"          UIBarButtonSystemItemReply
"action"         UIBarButtonSystemItemAction
"organize"       UIBarButtonSystemItemOrganize
"bookmarks"      UIBarButtonSystemItemBookmarks
"search"         UIBarButtonSystemItemSearch
"refresh"        UIBarButtonSystemItemRefresh
"stop"           UIBarButtonSystemItemStop
"camera"         UIBarButtonSystemItemCamera
"trash"          UIBarButtonSystemItemTrash
"play"           UIBarButtonSystemItemPlay
"pause"          UIBarButtonSystemItemPause
"rewind"         UIBarButtonSystemItemRewind
"fastforward"    UIBarButtonSystemItemFastForward
"undo"           UIBarButtonSystemItemUndo
"redo"           UIBarButtonSystemItemRedo
"pagecurl"       UIBarButtonSystemItemPageCurl
void AGXB.toggleNavigationBar({ "hide":bool, "animate":bool }) // 显隐导航栏, 不传hide值则自动切换显隐状态, 默认启用动画效果
void AGXB.pushIn({ "url/file":url string, "animate":bool, "hideNav":bool, "type":native controller class name string }) // 导航至指定URL或本地Html, 默认启用动画效果, 默认展示导航栏, 默认使用当前类的defaultPushViewControllerClass设置
void AGXB.popOut({ "count":int, "animate":bool }) // 导航退出指定数量的页面, 默认count为1, 默认启用动画效果
```

- AGXImagePickerController

    相册/相机图片选择控制器.

```objective-c
// 属性
imagePickerDelegate // 图片选择后的回调代理

// 创建相机控制器实例
+camera

// 使用以下方法展示图片选择控制器
-presentAnimated:completion:

// AGXImagePickerControllerDelegate
-imagePickerController:didFinishPickingImage:
```

- AGXBiometric

    生物识别(指纹)认证组件.

```objective-c
// 属性
delegate // 识别认证回调代理
authenticationReasonString // 提示信息
fallbackTitle // "输入密码"按钮标题

// 执行识别认证
-evaluate

// AGXBiometricDelegate
-biometricSuccess:
-biometricAuthFailed:withError:
-biometricUserCancel:withError:
-biometricUserFallback:withError:
-biometricSystemCancel:withError:
-biometricPasscodeNotSet:withError:
-biometricNotAvailable:withError:
-biometricNotEnrolled:withError:
```

- AGXLocationManager

    定位服务组件.

```objective-c
// 属性
lastLocation // 获取的定位信息
lastError // 获取定位的错误信息
updateBlock // 位置更新回调
errorBlock // 发生错误回调

// 实例化
+locationManager
+locationManagerWithDistanceFilter:desiredAccuracy:
+locationManagerWithDistanceFilter:desiredAccuracy:useInBackground:
-init;
-initWithDistanceFilter:desiredAccuracy:
-initWithDistanceFilter:desiredAccuracy:useInBackground:

// 启停定位更新
-startUpdatingLocation
-stopUpdatingLocation
```

#####Categories

- UIView+AGXWidgetBadge

```objective-c
// 通用badge
-showBadge
-showBadgeWithValue:
-hideBadge

// 通用badge相关属性
badgeTextFont
badgeTextColor
badgeColor
badgeOffset
badgeSize

// badge样式相关方法
+badgeTextFont
+setBadgeTextFont:
+badgeTextColor
+setBadgeTextColor:
+badgeColor
+setBadgeColor:
+badgeOffset
+setBadgeOffset:
+badgeSize
+setBadgeSize:
```

- UIView+AGXWidgetAnimation

```objective-c
// 自定义动画
-agxAnimate:
-agxAnimate:completion:
```

- UIWindow+AGXWidgetAnimation

```objective-c
// 启动画面结束时的动画设置.
-showSplashLaunchWithAnimation:
-showSplashImage:withAnimation:
-showSplashView:withAnimation:
```

- UINavigationController+AGXWidget

```objective-c
// 添加便捷功能
//   导航出入栈时会记录导航栏显隐状态
//   例如当前栈顶控制器A显示导航栏, 此时入栈控制器B并隐藏导航栏, 当B出栈A再次成为栈顶控制器时, 自动还原显示导航栏

// 添加属性
gesturePopPercent // 手势交互弹出栈顶视图时, Pop操作确认或取消的临界值百分比

// 导航控制方法, 可设定转场动画, 并添加动画开始结束回调Block

-pushViewController:animated:started:finished:
-pushViewController:transited:
-pushViewController:transited:started:finished:

-popViewControllerAnimated:started:finished:
-popViewControllerTransited:
-popViewControllerTransited:started:finished:

-popToViewController:animated:started:finished:
-popToViewController:transited:
-popToViewController:transited:started:finished:

-popToRootViewControllerAnimated:started:finished:
-popToRootViewControllerTransited:
-popToRootViewControllerTransited:started:finished:

-setViewControllers:animated:started:finished:
-setViewControllers:transited:
-setViewControllers:transited:started:finished:

-replaceWithViewController:animated:
-replaceWithViewController:animated:started:finished:
-replaceWithViewController:transited:
-replaceWithViewController:transited:started:finished:

-replaceToViewController:animated:
-replaceToViewController:animated:started:finished:
-replaceToViewController:transited:
-replaceToViewController:transited:started:finished:

-replaceToRootViewControllerWithViewController:animated:
-replaceToRootViewControllerWithViewController:animated:started:finished:
-replaceToRootViewControllerWithViewController:transited:
-replaceToRootViewControllerWithViewController:transited:started:finished:

// 注: UIViewController在UINavigationController控制中可直接调用以上方法和原有的导航方法
-pushViewController:animated:
-popViewControllerAnimated:
-popToViewController:animated:
-popToRootViewControllerAnimated:
-setViewControllers:animated:

// UIViewController添加导航相关属性
disablePopGesture // 是否禁用交互弹出栈顶视图手势, 导航栈内子视图设置优先于导航视图设置
hideNavigationBar // 视图展示时是否隐藏导航栏, 生效时机为viewWillAppear方法, 所以需在视图展示前设置
backBarButtonTitle // 返回按钮标题

// UIViewController添加导航相关方法
-navigationShouldPopOnBackBarButton // 点击导航返回按钮时是否弹出当前ViewController, 默认返回YES
```
