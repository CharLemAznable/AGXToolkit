# AGXHUD

ProgressHUD工具代码.

#####Components

- AGXProgressHUD

    重命名MBProgressHUD: Created by Matej Bukovinski, Version 0.9.1.

#####Categories

    扩展AGXProgressHUD, 增加UIView类别方法, 用于显隐AGXProgressHUD视图.

- UIView+AGXHUD

        // 在当前视图内显隐HUD的简易方法:
        -mbProgressHUD
        -showIndeterminateHUDWithText:
        -showTextHUDWithText:hideAfterDelay:
        -showTextHUDWithText:detailText:hideAfterDelay:
        -hideHUD:

- UIView+AGXHUDRecursive

        // 在当前视图及其子视图内显隐HUD的简易方法:
        -recursiveMBProgressHUD
        -showIndeterminateRecursiveHUDWithText:
        -showTextRecursiveHUDWithText:hideAfterDelay:
        -showTextRecursiveHUDWithText:detailText:hideAfterDelay:
        -hideRecursiveHUD:
