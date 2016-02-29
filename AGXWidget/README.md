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
