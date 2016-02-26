# AGXWidget

自定义页面组件.

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

#####Categories

- UIView+AGXWidget

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
