# AGXAnimation

视图动画工具代码.

#####Constants

- AGXAnimateType

    动画类型枚举, 如平移/透明/翻页/缩放等.

- AGXAnimateDirection

    动画方向枚举, 指定平移/翻页动画方向.

- AGXAnimation

    动画设置结构体, 定义动画类型&方向&持续时间&延迟时间.

- AGXAnimationMake & AGXImmediateAnimationMake

    动画构造方法.

#####Categories

- UIView+AGXAnimation

        // 自定义动画
        -agxAnimate:
        -agxAnimate:completion:

- UIWindow+AGXAnimation

        // 启动画面结束时的动画设置.
        -showSplashLaunchWithAnimation:
        -showSplashImage:withAnimation:
        -showSplashView:withAnimation:
