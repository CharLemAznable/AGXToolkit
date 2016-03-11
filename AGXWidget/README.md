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

#####Components

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

        // 进度设置方法.
        -setProgress:animated:

- AGXWebView

    扩展UIWebView, 嵌入JS与ObjC交互.

        // 添加全局设置, 嵌入的JS对象名, 默认为AGXB.
        AGXBridgeInjectJSObjectName

        // 添加属性
        autoEmbedJavascript // 默认为YES, 自动向页面内嵌入JS代码
        progressColor // 进度条颜色, 默认(22, 126, 251, 255)

        // 实例方法
        // 指定JS嵌入处理回调, 需要在页面加载前调用, 页面加载完成后可使用AGXB.handlerName方法调用ObjC代码
        -registerHandlerName:handler:selector:
        // 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即调用注册的Block
        -registerTriggerAt:withBlock:
        // 注册ObjC触发器, 在指定类中添加实例方法, 调用此方法即在页面内执行指定JavaScript代码
        -registerTriggerAt:withJavascript:

        // 初始添加JS方法
        AGXB.reload()
        AGXB.stopLoading()
        AGXB.goBack()
        AGXB.goForward()
        AGXB.canGoBack(function(boolValue) {})
        AGXB.canGoForward(function(boolValue) {})
        AGXB.isLoading(function(boolValue) {})
        AGXB.scaleFit()
        AGXB.setBounces(boolValue)
        AGXB.setBounceHorizontal(boolValue)
        AGXB.setBounceVertical(boolValue)
        AGXB.setShowHorizontalScrollBar(boolValue)
        AGXB.setShowVerticalScrollBar(boolValue)

- AGXWebViewController

    默认的AGXWebView控制器.

        // 实例方法
        -registerHandlerName:handler:selector:
        -registerTriggerAt:withBlock:
        -registerTriggerAt:withJavascript:

        // 初始添加JS方法
        AGXB.setTitle("string")
        AGXB.setPrompt("string")
        AGXB.setBackTitle("string")
        AGXB.setLeftButton({ "title" : "string", "callback" : function() {} })
        AGXB.setRightButton({ "title" : "string", "callback" : function() {} })

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
