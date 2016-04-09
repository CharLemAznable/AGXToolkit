# AGXWidget

自定义页面组件.

#####Constants

- AGXAnimateType

    动画类型枚举, 如平移/透明/翻页/缩放等.

- AGXAnimateDirection

    动画方向枚举, 指定平移/翻页动画方向.

- AGXAnimation

    动画设置结构体, 定义动画类型&方向&持续时间&延迟时间.

- AGXAnimationMake & AGXImmediateAnimationMake

    动画构造方法.

- AGXTransitionType

    转场动画类型枚举.

        AGXTransitionFade // 交叉淡化过渡(不支持过渡方向)
        AGXTransitionPush // 新视图把旧视图推出去
        AGXTransitionMoveIn // 新视图移到旧视图上面
        AGXTransitionReveal // 将旧视图移开,显示下面的新视图
        AGXTransitionCube // 立方体翻滚效果
        AGXTransitionOglFlip // 上下左右翻转效果
        AGXTransitionSuckEffect // 收缩效果，如一块布被抽走(不支持过渡方向)
        AGXTransitionRippleEffect // 波纹效果(不支持过渡方向)
        AGXTransitionPageCurl // 向上翻页效果
        AGXTransitionPageUnCurl // 向下翻页效果
        AGXTransitionCameraIrisHollowOpen // 相机镜头打开效果(不支持过渡方向)
        AGXTransitionCameraIrisHollowClose // 相机镜头关上效果(不支持过渡方向)

- AGXTransitionDirection

    转场动画方向枚举, 指定平移/翻页动画方向.

- AGXTransition

    转场动画设置结构体, 定义转场动画类型&方向&持续时间.

- AGXTransitionMake

    转场动画构造方法.

- AGXDefaultPushTransition

    导航控制器Push操作默认转场动画.

- AGXDefaultPopTransition

    导航控制器Pop操作默认转场动画.

#####Components

- AGXLine

    自适应线条视图.

        // 属性
        lineColor
        lineDirection // 指定线条方向
        lineWidth // 指定宽度像素值
        ceilAdjust // 绘制线条时会因反锯齿效果导致线条失真, 默认向下调整线条位置, 设置此值为真则改为向上调整
        dashPhase // 虚线设置
        dashLengths // 虚线设置

- AGXLabel

    扩展UILabel, 可复制文本内容.

        // 统一默认设置
        self.backgroundColor = [UIColor clearColor];

        // 添加长按手势弹出菜单.

        // 添加属性
        canCopy // 是否长按弹出复制菜单

        // 添加属性
        linesSpacing // 文本行距

        // 弹出菜单数据源
        id<AGXLabelDataSource> dataSource

        AGXLabelDataSource
        -menuTitleStringOfCopyInLabel:
        -menuLocationPointInLabel:

- AGXImageView

    扩展UIImageView, 可复制/保存图片.

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

- AGXRefreshView

    滚动刷新工具视图.

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

- AGXPageControl

    分页指示器.

        // 添加属性
        pageIndicatorColor // 默认指示色
        currentPageIndicatorColor // 当前页指示色

- AGXSearchBar

    搜索栏组件.

- AGXProgressHUD

    重命名MBProgressHUD: Created by Matej Bukovinski, Version 0.9.1.

    增加UIView分类:

    UIView+AGXHUD

        // 在当前视图内显隐HUD的简易方法:
        -mbProgressHUD
        -showIndeterminateHUDWithText:
        -showTextHUDWithText:hideAfterDelay:
        -showTextHUDWithText:detailText:hideAfterDelay:
        -hideHUD:

    UIView+AGXHUDRecursive

        // 在当前视图及其子视图内显隐HUD的简易方法:
        -recursiveMBProgressHUD
        -showIndeterminateRecursiveHUDWithText:
        -showTextRecursiveHUDWithText:hideAfterDelay:
        -showTextRecursiveHUDWithText:detailText:hideAfterDelay:
        -hideRecursiveHUD:

- AGXProgressBar

    进度条组件.

        // 添加属性.
        progressColor // default (22, 126, 251, 255)
        progressDuration // default 0.3
        fadingDuration // default 0.3
        fadeDelay // default 0.1
        progress // 进度值, 0.0..1.0

        // 样式设置
        +progressColor
        +setProgressColor:

        // 进度设置方法.
        -setProgress:animated:

- AGXWebView

    扩展UIWebView, 嵌入JS与ObjC交互.

        // 添加全局设置, 嵌入JS完成事件名称, 默认为agxbloaded
        AGXBridgeLoadedEventName

        // 添加全局设置, 嵌入的JS对象名, 默认为AGXB.
        AGXBridgeInjectJSObjectName

        // 添加属性
        autoEmbedJavascript // 默认为YES, 自动向页面内嵌入JS代码
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
        // 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即调用注册的Block
        -registerTriggerAt:withBlock:
        // 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即在页面内执行指定JavaScript代码
        -registerTriggerAt:withJavascript:

        // 初始添加JS方法
        AGXB.reload() // 重新载入
        AGXB.stopLoading() // 停止载入
        AGXB.goBack() // 后退
        AGXB.goForward() // 前进
        AGXB.canGoBack(function(boolValue) {}) // 检查是否可后退
        AGXB.canGoForward(function(boolValue) {}) // 检查是否可前进
        AGXB.isLoading(function(boolValue) {}) // 检查是否加载中
        AGXB.scaleFit() // 缩放页面以适应窗口
        AGXB.setBounces(boolValue) // 设置页面是否可拖拽超出边框
        AGXB.setBounceHorizontal(boolValue) // 设置页面是否可水平拖拽超出边框
        AGXB.setBounceVertical(boolValue) // 设置页面是否可垂直拖拽超出边框
        AGXB.setShowHorizontalScrollBar(boolValue) // 设置是否展示水平滚动条
        AGXB.setShowVerticalScrollBar(boolValue) // 设置是否展示垂直滚动条

        // 注: 页面加载完成并完成JS嵌入后才可调用嵌入的JS方法
        // JS嵌入完成事件: "agxbloaded"
        document.addEventListener("agxbloaded", function() {
          ...
        });

- AGXWebViewController

    默认的AGXWebView控制器.

        // 添加全局设置, 本地资源存放的Bundle名称.
        AGXLocalResourceBundleName

        // 添加属性
        useDocumentTitle // 默认为YES, 使用加载的Web文档的title作为导航栏标题

        // 实例方法
        -registerHandlerName:handler:selector:
        -registerTriggerAt:withBlock:
        -registerTriggerAt:withJavascript:

        // 桥接设置
        -defaultPushViewControllerClass // 桥接控制导航推入页面时, 使用的默认视图控制器类, 默认为AGXWebViewController

        // 初始添加JS方法
        AGXB.setTitle("string") // 设置导航栏标题
        AGXB.setPrompt("string") // 设置导航栏标注
        AGXB.setBackTitle("string") // 设置下级页面返回按钮展示文字
        AGXB.setLeftButton({ "title" : "string", "system":"string", "callback" : function() {} }) // 设置导航左侧按钮标题或系统图标与回调函数
        AGXB.setRightButton({ "title" : "string", "system":"string", "callback" : function() {} }) // 设置导航右侧按钮标题或系统图标与回调函数
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
        AGXB.toggleNavigationBar({ "hide" : boolValue, "animate" : boolValue }) // 显隐导航栏, 不传hide值则自动切换显隐状态, 默认启用动画效果
        AGXB.pushWebView({ "url/file" : "string, http url or local file path", "animate" : boolValue, "hideNav" : boolValue, "type" : "string, native controller class name" }) // 导航至指定URL或本地Html, 默认启用动画效果, 默认展示导航栏, 默认使用当前类的defaultPushViewControllerClass设置
        AGXB.popOut({ "count" : intValue, "animate" : boolValue }) // 导航退出指定数量的页面, 默认count为1, 默认启用动画效果
        AGXB.alert({ "style" : "string", "title" : "string", "message" : "string", "button" : "string", "callback" : function() {} }) // 警告弹窗, style默认为AlertView样式, 可设置为"sheet"使用ActionSheet样式
        AGXB.confirm({ "style" : "string", "title" : "string", "message" : "string", "cancelButton" : "string", "cancelCallback" : function() {}, "confirmButton" : "string", "confirmCallback" : function() {} }) // 确认弹窗, style默认为AlertView样式, 可设置为"sheet"使用ActionSheet样式, 注: AlertView中, cancelButton为靠左的按钮, confirmButton为靠右的按钮
        AGXB.HUDMessage({ "title" : "string", "message" : "string", "delay" : "number(second)", "fullScreen" : boolValue }) // 展示透明提示信息, 默认delay为2(s), 默认不全屏覆盖
        AGXB.HUDLoading({ "message" : "string", "fullScreen" : boolValue }) // 展示透明进度提示, 使用HUDLoaded关闭提示, 默认不全屏覆盖
        AGXB.HUDLoaded() // 关闭透明进度提示

#####Categories

- UIView+AGXWidgetBadge

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

- UIView+AGXWidgetAnimation

        // 自定义动画
        -agxAnimate:
        -agxAnimate:completion:

- UIWindow+AGXWidgetAnimation

        // 启动画面结束时的动画设置.
        -showSplashLaunchWithAnimation:
        -showSplashImage:withAnimation:
        -showSplashView:withAnimation:

- UINavigationController+AGXWidget

        // 导航控制方法, 可设定转场动画, 并添加动画开始结束回调Block

        -pushViewController:animated:started:finished:
        -pushViewController:transition:
        -pushViewController:transition:started:finished:

        -popViewControllerAnimated:started:finished:
        -popViewControllerTransition:
        -popViewControllerTransition:started:finished:

        -popToViewController:animated:started:finished:
        -popToViewController:transition:
        -popToViewController:transition:started:finished:

        -popToRootViewControllerAnimated:started:finished:
        -popToRootViewControllerTransition:
        -popToRootViewControllerTransition:started:finished:

        -setViewControllers:animated:started:finished:
        -setViewControllers:transition:
        -setViewControllers:transition:started:finished:

        -replaceWithViewController:animated:
        -replaceWithViewController:animated:started:finished:
        -replaceWithViewController:transition:
        -replaceWithViewController:transition:started:finished:

        -replaceToViewController:animated:
        -replaceToViewController:animated:started:finished:
        -replaceToViewController:transition:
        -replaceToViewController:transition:started:finished:

        -replaceToRootViewControllerWithViewController:animated:
        -replaceToRootViewControllerWithViewController:animated:started:finished:
        -replaceToRootViewControllerWithViewController:transition:
        -replaceToRootViewControllerWithViewController:transition:started:finished:

        // 注: UIViewController在UINavigationController控制中可直接调用以上方法和原有的导航方法
        -pushViewController:animated:
        -popViewControllerAnimated:
        -popToViewController:animated:
        -popToRootViewControllerAnimated:
        -setViewControllers:animated:
