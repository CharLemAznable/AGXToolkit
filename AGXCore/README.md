# AGXCore

日常开发核心工具代码.

#####Constant

* 判断当前设备类型.

        IS_IPHONEX

* 根据设备类型获取视口变化比例.

        DeviceScale

* 判断当前系统版本.

        BEFORE_IOSX
        IOSX_OR_LATER

* IOS7及其后, 状态栏透明, 顶级视图需在顶部增加20个Point高度的空白.

        statusBarHeight

* IOS7之前, 状态栏不透明, 全屏视图需上移20个Point, 隐藏在状态栏后.

        statusBarFix

* 调试输出宏

        AGXLog(fmt, ...)

#####Components

- AGXCategory

    添加Category工具宏, 用于定义Category并自动加载.

        // 定义Category
        @category_interface(className, categoryName)
        // 定义包含泛型的Category
        @category_interface_generic(className, genericParam, categoryName)

        // 实现Category
        @category_implementation(className, categoryName)

        // 添加的分类将于__attribute__((constructor))时自动加载,
        // 所以可以省略Other Linker Flags: "-all_load -ObjC"

- AGXSingleton

    添加单例宏.

        // 定义单例类
        @singleton_interface(className, superClassName)

        // 实现单例类
        @singleton_implementation(className)

        // 单例类定义示例
        @singleton_interface(MySingleton, NSObject)
        @end
        @singleton_implementation(MySingleton)
        @end

        // 单例使用示例
        [MySingleton shareMySingleton]

- AGXGeometry

    添加二维坐标工具方法.

        CGRect AGX_CGRectMake(CGPoint, CGSize);
        CGSize AGX_CGSizeFromUIOffset(UIOffset offset);
        UIOffset AGX_UIOffsetFromCGSize(CGSize size);

- AGXDirectory

    添加应用目录工具.

        // 默认使用Documents目录.
        +fullFilePath:
        +fileExists:
        +deleteAllFiles
        +directoryExists:
        +createDirectory:

        // 指定使用其他目录, 如Library/Caches或tmp目录.
        // 使用枚举AGXDirectoryType指定目录类型.
        +fullFilePath:inDirectory:
        +fileExists:inDirectory:
        +deleteAllFilesInDirectory:
        +directoryExists:inDirectory:
        +createDirectory:inDirectory:

        // 指定子目录.
        +fullFilePath:inDirectory:subpath:
        +fileExists:inDirectory:subpath:
        +deleteAllFilesInDirectory:subpath:
        +directoryExists:inDirectory:subpath:
        +createDirectory:inDirectory:subpath:

        // 应用根目录.
        // 使用枚举AGXDirectoryType指定目录类型.
        +documentDirectoryRoot
        +cachesDirectoryRoot
        +temporaryDirectoryRoot
        +directoryRoot:

- AGXBundle

    资源bundle工具.
    当不指定bundle参数或bundle参数为nil时, 在当前App Bundle中寻找资源文件; 否则在对应bundle中的子目录中寻找.
    当subpath参数为nil时, 在bundle根目录中寻找.

        // 获取当前App Bundle.
        +appBundle

        // 读入bundle中的图片对象.
        +imageWithName:
        +imageWithName:bundle:
        +imageWithName:bundle:subpath:

        // 获取bundle中plist文件的完整路径.
        +plistPathWithName:
        +plistPathWithName:bundle:
        +plistPathWithName:bundle:subpath:

        // 获取bundle中音频文件URL.
        // 用于AudioServicesCreateSystemSoundID(CFURLRef, SystemSoundID*)
        +audioURLWithName:type:
        +audioURLWithName:type:bundle:
        +audioURLWithName:type:bundle:subpath:

- AGXColorSet

    颜色集合类, 用于加载配置文件中的颜色表.

#####Category (Foundation)

* NSObject+AGXCore

        // 封装Selector替换方法.
        +swizzleInstanceOriSelector:withNewSelector:
        +swizzleInstanceOriSelector:withNewSelector:fromClass:
        +swizzleClassOriSelector:withNewSelector:
        +swizzleClassOriSelector:withNewSelector:fromClass:

        // 多键添加/移除KVO方法.
        -addObserver:forKeyPaths:options:context:
        -removeObserver:forKeyPaths:context:
        -removeObserver:forKeyPaths:

        // 关联对象方法, 添加实例变量, 内存管理策略OBJC_ASSOCIATION_RETAIN_NONATOMIC.
        -propertyForAssociateKey:
        -setProperty:forAssociateKey:
        -assignProperty:forAssociateKey: // 直接赋值, 不触发KVO

* NSNull+AGXCore

        //封装判断空对象方法.
        +isNull:
        +isNotNull:

* NSNumber+AGXCore

        // 添加NSNumber与CGFloat兼容方法.
        +numberWithCGFloat:
        -initWithCGFloat:
        -cgfloatValue

        // 添加字符串数字化方法. (NSString)
        -cgfloatValue

* NSCoder+AGXCore

        // 添加NSCoder与CGFloat兼容方法.
        -encodeCGFloat:forKey:
        -decodeCGFloatForKey:

- NSData+AGXCore

        // Base64转码方法.
        -base64EncodedString
        +dataWithBase64String:

- NSString+AGXCore

        // 判断空字符串.
        -isEmpty
        -isNotEmpty

        // 裁剪空白字符串.
        -trim
        -trimToNil

        // 首字母大写, 其它字母不变. (-capitalizedString方法有此bug)
        -capitalized

        //  判断字符串相等(忽略大小写).
        -isCaseInsensitiveEqual:
        -isCaseInsensitiveEqualToString:

        //  版本号字符串比较方法.
        -compareToVersionString:

        // 定位子字符串.
        -indexOfString:
        -indexCaseInsensitiveOfString:
        -indexOfString:fromIndex:
        -indexCaseInsensitiveOfString:fromIndex:

        // 判断是否包含子字符串.
        -containsString:
        -containsCaseInsensitiveString:
        -containsAnyOfStringInArray:
        -containsAnyOfCaseInsensitiveStringInArray:
        -containsAllOfStringInArray:
        -containsAllOfCaseInsensitiveStringInArray:

        // 切割字符串为数组.
        -arraySplitedByString:
        -arraySplitedByCharactersInSet:
        -arraySplitedByString:filterEmptyItem:
        -arraySplitedByCharactersInSet:filterEmptyItem:

        // 类构造方法, 根据NSArray构造字符串.
        +stringWithArray:
        +stringWithArray:separator:

        // 追加对象到字符串末尾.
        -appendWithObjects:

        // 替换字符串.
        -stringByReplacingString:withString:
        -stringByCaseInsensitiveReplacingString:withString:
        -stringByReplacingCharactersInSet:withString:
        -stringByReplacingCharactersInSet:withString:mergeContinuous:

        // URL字符串转义方法.
        -stringByEscapingForURLQuery
        -stringByUnescapingFromURLQuery

        // 计算MD5.
        -MD5Sum

        // 计算SHA1.
        -SHA1Sum

        // Base64转码方法.
        -base64EncodedString
        +stringWithBase64String:

        // Unicode/UTF8互转方法.
        +replaceUnicodeToUTF8:
        +replaceUTF8ToUnicode:

        // 参数化字符串方法, 替换字符串中的"${key}"为[object valueForKey:@"key"].
        -parametricStringWithObject:

        // 计算字符串占据的尺寸(适配IOS7及以上的系统)
        -agxSizeWithFont:constrainedToSize:

- NSValue+AGXCore

        // 增加NSValue对结构类型的KVC处理.
        -valueForKey:
        -valueForKeyPath:

        // 增加自定义结构体boxed分类定义/实现宏.
        struct_boxed_interface(structType)
        struct_boxed_implementation(structType)

        // 自定义结构体boxed示例
        typedef struct {
          ...
        } CustomStruct;
        @struct_boxed_interface(CustomStruct)
        @struct_boxed_implementation(CustomStruct)

        // 调用示例
        CustomStruct customStruct = { ... };
        NSValue * structValue = [NSValue valueWithCustomStruct:customStruct];
        CustomStruct customStruct2 = [structValue CustomStructValue];

* NSArray+AGXCore

        // 深拷贝数组.
        -deepCopy

        // 可变深拷贝数组.
        -deepMutableCopy

        // 取数组元素值方法, 可指定默认返回值.
        -objectAtIndex:defaultValue:

        // 在SDK < 6.0时, 添加下标读写方法.
        // (NSArray)
        -objectAtIndexedSubscript:
        // (NSMutableArray)
        -setObject:atIndexedSubscript:

        // 读取应用程序沙盒/Bundle中的文件.
        +arrayWithContentsOfUserFile:
        +arrayWithContentsOfUserFile:subpath:
        +arrayWithContentsOfUserFile:inDirectory:
        +arrayWithContentsOfUserFile:inDirectory:subpath:
        +arrayWithContentsOfUserFile:bundle:
        +arrayWithContentsOfUserFile:bundle:subpath:

        -initWithContentsOfUserFile:
        -initWithContentsOfUserFile:subpath:
        -initWithContentsOfUserFile:inDirectory:
        -initWithContentsOfUserFile:inDirectory:subpath:
        -initWithContentsOfUserFile:bundle:
        -initWithContentsOfUserFile:bundle:subpath:

        // 写入应用程序沙盒中的文件.
        -writeToUserFile:
        -writeToUserFile:inDirectory:
        -writeToUserFile:inDirectory:subpath:

* NSDictionary+AGXCore

        // 深拷贝字典.
        -deepCopy

        // 可变深拷贝字典.
        -deepMutableCopy

        // 取字典元素值方法, 可指定默认返回值.
        -objectForKey:defaultValue:

        // 根据Key数组取子字典方法. (区别于-dictionaryWithValuesForKeys:方法, 字典中不包含的Key不会放入子字典.)
        -subDictionaryForKeys:

        // 在SDK < 6.0时, 添加下标读写方法.
        // (NSDictionary)
        -objectForKeyedSubscript:
        // (NSMutableDictionary)
        -setObject:forKeyedSubscript:

        // 读取应用程序沙盒/Bundle中的文件.
        +dictionaryWithContentsOfUserFile:
        +dictionaryWithContentsOfUserFile:subpath:
        +dictionaryWithContentsOfUserFile:inDirectory:
        +dictionaryWithContentsOfUserFile:inDirectory:subpath:
        +dictionaryWithContentsOfUserFile:bundle:
        +dictionaryWithContentsOfUserFile:bundle:subpath:

        -initWithContentsOfUserFile:
        -initWithContentsOfUserFile:subpath:
        -initWithContentsOfUserFile:inDirectory:
        -initWithContentsOfUserFile:inDirectory:subpath:
        -initWithContentsOfUserFile:bundle:
        -initWithContentsOfUserFile:bundle:subpath:

        // 写入应用程序沙盒中的文件.
        -writeToUserFile:
        -writeToUserFile:inDirectory:
        -writeToUserFile:inDirectory:subpath:

- NSExpression+AGXCore

        // NSExpression保留字列表.
        +keywordsArrayInExpressionFormat

        // NSExpression格式化参数构造方法, 替换${keyPath}为%K, 并添加绑定参数keyPath.
        +expressionWithParametricFormat:

- NSDate+AGXCore

        // 添加毫秒数据类型:
        AGXTimeIntervalMills

        // 获得毫秒单位时间间隔.
        -timeIntervalMillsSinceDate:

        // 添加只读属性.
        timeIntervalMillsSinceNow
        timeIntervalMillsSince1970

        // 添加只读属性.
        era
        year
        month
        day
        hour
        minute
        second
        weekday

        // 时间格式化工具方法.
        -stringWithDateFormat:

        // 添加毫秒数据类型box/unbox方法. (NSNumber)
        +numberWithMills:
        -initWithMills:
        -millsValue

        // 字符串格式时间工具方法. (NSString)
        -dateWithDateFormat:

        // 添加字符串数字化方法. (NSString)
        -millsValue

#####Category (UIKit)

- UIDevice+AGXCore

        // 添加读取设备型号方法.
        -fullModelString    // 如: iPhone7,1
        -purifyModelString  // 如: iPhone 6Plus

- UIApplication+AGXCore

        // 远程通知注册与检测方法.
        +registerUserNotificationTypes:
        -registerUserNotificationTypes:
        +registerUserNotificationTypes:categories:
        -registerUserNotificationTypes:categories:
        +notificationTypeRegisted:
        -notificationTypeRegisted:
        +noneNotificationTypeRegisted
        -noneNotificationTypeRegisted

- UIView+AGXCore

        // 添加统一初始化方法
        -agxInitial

        // 添加属性:
        backgroundImage
        masksToBounds
        cornerRadius
        borderWidth
        borderColor
        shadowColor
        shadowOpacity
        shadowOffset
        shadowSize.

        // 添加截图方法.
        -imageRepresentation

        // 自定义样式方法
        +borderWidth
        +setBorderWidth:
        +borderColor
        +setBorderColor:
        +shadowColor
        +setShadowColor:
        +shadowOpacity
        +setShadowOpacity:
        +shadowOffset
        +setShadowOffset:
        +shadowSize
        +setShadowSize:

- UIControl+AGXCore

        // 添加-(someAttribute)ForState:方法
        -borderWidthForState:
        -borderColorForState:
        -shadowColorForState:
        -shadowOpacityForState:
        -shadowOffsetForState:
        -shadowSizeForState:

        // 添加-set(SomeAttribute):forState:方法
        -setBorderWidth:forState:
        -setBorderColor:forState:
        -setShadowColor:forState:
        -setShadowOpacity:forState:
        -setShadowOffset:forState:
        -setShadowSize:forState:

        // 自定义样式方法
        +borderWidthForState:
        +setBorderWidth:forState:
        +borderColorForState:
        +setBorderColor:forState:
        +shadowColorForState:
        +setShadowColor:forState:
        +shadowOpacityForState:
        +setShadowOpacity:forState:
        +shadowOffsetForState:
        +setShadowOffset:forState:
        +shadowSizeForState:
        +setShadowSize:forState:

- UILabel+AGXCore

        // 计算Label合适的尺寸.
        -sizeThatConstraintToSize:

- UIImage+AGXCore

        // 生成点图像并指定颜色.
        +imagePointWithColor:

        // 生成矩形图像并指定颜色.
        +imageRectWithColor:size:

        // 生成渐变矩形图像.
        +imageGradientRectWithStartColor:endColor:direction:size:
        +imageGradientRectWithColors:locations:direction:size:

        // 生成椭圆形图像并指定颜色.
        +imageEllipseWithColor:size:

        // 获取对应当前设备尺寸的图片名称或图片对象.
        // 依据不同尺寸图片命名后缀规则:
        //   - 6P: -800-Portrait-736h
        //   - 6: -800-667h
        //   - 5: -700-568h
        //   - 其他: @2x或无后缀
        +imageForCurrentDeviceNamed:
        +imageNameForCurrentDeviceNamed:

        // 获取图片主色调.
        -dominantColor

        // 读取应用程序沙盒/Bundle中的文件.
        +imageWithContentsOfUserFile:
        +imageWithContentsOfUserFile:subpath:
        +imageWithContentsOfUserFile:inDirectory:
        +imageWithContentsOfUserFile:inDirectory:subpath:
        +imageWithContentsOfUserFile:bundle:
        +imageWithContentsOfUserFile:bundle:subpath:

        // 写入应用程序沙盒中的文件.
        -writeToUserFile:
        -writeToUserFile:inDirectory:
        -writeToUserFile:inDirectory:subpath:

        // 添加从Bundle中读入适应设备尺寸的图片方法.
        -imageForCurrentDeviceWithName:
        -imageForCurrentDeviceWithName:bundle:
        -imageForCurrentDeviceWithName:bundle:subpath:

- UIImageView+AGXCore

        // 简便初始化方法.
        +imageViewWithImage:

- UITextField+AGXCore

        // 限制输入文本内容及长度.
        -shouldChangeCharactersInRange:replacementString:limitWithLength:

- UITextView+AGXCore

        // 限制输入文本内容及长度.
        -shouldChangeCharactersInRange:replacementString:limitWithLength:

- UIColor+AGXCore

        // 根据255格式颜色生成UIColor.
        +colorWithIntegerRed:green:blue:
        +colorWithIntegerRed:green:blue:alpha:

        // 根据十六进制字符串格式颜色生成UIColor.
        +colorWithRGBHexString:
        +colorWithRGBAHexString:

        // 获取RGBA ColorSpace的CGColorRef.
        -rgbaCGColorRef

        // 判断颜色是否相同, 使用rgbaCGColorRef实现比较.
        -isEqualToColor:

- UINavigationBar+AGXCore

        // 添加自定义样式方法, 可自定义透明模式, tint颜色, barTint颜色, 背景颜色/图片, 字体, 字色, 文字阴影.
        +isTranslucent
        +setTranslucent:

        +tintColor
        +setTintColor:

        +barTintColor
        +setBarTintColor:

        -defaultBackgroundImage
        -setDefaultBackgroundImage:
        +defaultBackgroundImage
        +setDefaultBackgroundImage:

        +backgroundImageForBarMetrics:
        +setBackgroundImage:forBarMetrics:

        -defaultBackgroundColor
        -setDefaultBackgroundColor:
        +defaultBackgroundColor
        +setDefaultBackgroundColor:

        -backgroundColorForBarMetrics:
        -setBackgroundColor:forBarMetrics:
        +backgroundColorForBarMetrics:
        +setBackgroundColor:forBarMetrics:

        -textFont
        -setTextFont:
        +textFont
        +setTextFont:

        -textColor
        -setTextColor:
        +textColor
        +setTextColor:

        -textShadowColor
        -setTextShadowColor:
        +textShadowColor
        +setTextShadowColor:

        -textShadowOffset
        -setTextShadowOffset:
        +textShadowOffset
        +setTextShadowOffset:

        -textShadowSize
        -setTextShadowSize:
        +textShadowSize
        +setTextShadowSize:

- UITabBar+AGXCore

        // 添加只读属性, 获取TabBar的TabBarButton集合.
        barButtons

        // 添加自定义样式方法, 可自定义透明模式, 背景图片, 选中项背景图片, 选中项tint颜色, barTint颜色.
        +isTranslucent
        +setTranslucent:

        +tintColor
        +setTintColor:

        +barTintColor
        +setBarTintColor:

        +backgroundImage
        +setBackgroundImage:

        +backgroundColor
        +setBackgroundColor:

        +selectionIndicatorImage
        +setSelectionIndicatorImage:

        -selectionIndicatorColor
        -setSelectionIndicatorColor:
        +selectionIndicatorColor
        +setSelectionIndicatorColor:

        +selectedImageTintColor
        +setSelectedImageTintColor:

- UIBarItem+AGXCore

        // 添加自定义样式方法, 可自定义字体, 字色, 文字阴影.
        -textFontForState:
        -setTextFont:forState:
        +textFontForState:
        +setTextFont:forState:

        -textColorForState:
        -setTextColor:forState:
        +textColorForState:
        +setTextColor:forState:

        -textShadowColorForState:
        -setTextShadowColor:forState:
        +textShadowColorForState:
        +setTextShadowColor:forState:

        -textShadowOffsetForState:
        -setTextShadowOffset:forState:
        +textShadowOffsetForState:
        +setTextShadowOffset:forState:

        -textShadowSizeForState:
        -setTextShadowSize:forState:
        +textShadowSizeForState:
        +setTextShadowSize:forState:

- UIBarButtonItem+AGXCore

        // 添加自定义样式方法.
        // tint颜色
        +tintColor
        +setTintColor:
        +tintColorWhenContainedIn:
        +setTintColor:whenContainedIn:

        // 背景图片/颜色
        -defaultBackgroundImage
        -setDefaultBackgroundImage:

        +defaultBackgroundImage
        +setDefaultBackgroundImage:
        +backgroundImageForState:barMetrics:
        +setBackgroundImage:forState:barMetrics:

        +defaultBackgroundImageWhenContainedIn:
        +setDefaultBackgroundImage:whenContainedIn:
        +backgroundImageForState:barMetrics:whenContainedIn:
        +setBackgroundImage:forState:barMetrics:whenContainedIn:

        -defaultBackgroundColor
        -setDefaultBackgroundColor:
        -backgroundColorForState:barMetrics:
        -setBackgroundColor:forState:barMetrics:

        +defaultBackgroundColor
        +setDefaultBackgroundColor:
        +backgroundColorForState:barMetrics:
        +setBackgroundColor:forState:barMetrics:

        +defaultBackgroundColorWhenContainedIn:
        +setDefaultBackgroundColor:whenContainedIn:
        +backgroundColorForState:barMetrics:whenContainedIn:
        +setBackgroundColor:forState:barMetrics:whenContainedIn:

        -defaultBackgroundImageForStyle:
        -setDefaultBackgroundImage:forStyle:

        +defaultBackgroundImageForStyle:
        +setDefaultBackgroundImage:forStyle:
        +backgroundImageForState:style:barMetrics:
        +setBackgroundImage:forState:style:barMetrics:

        +defaultBackgroundImageForStyle:whenContainedIn:
        +setDefaultBackgroundImage:forStyle:whenContainedIn:
        +backgroundImageForState:style:barMetrics:whenContainedIn:
        +setBackgroundImage:forState:style:barMetrics:whenContainedIn:

        -defaultBackgroundColorForStyle:
        -setDefaultBackgroundColor:forStyle:
        -backgroundColorForState:style:barMetrics:
        -setBackgroundColor:forState:style:barMetrics:

        +defaultBackgroundColorForStyle:
        +setDefaultBackgroundColor:forStyle:
        +backgroundColorForState:style:barMetrics:
        +setBackgroundColor:forState:style:barMetrics:

        +defaultBackgroundColorForStyle:whenContainedIn:
        +setDefaultBackgroundColor:forStyle:whenContainedIn:
        +backgroundColorForState:style:barMetrics:whenContainedIn:
        +setBackgroundColor:forState:style:barMetrics:whenContainedIn:

        // 背景位置偏移
        -defaultBackgroundVerticalPositionAdjustment
        -setDefaultBackgroundVerticalPositionAdjustment:

        +defaultBackgroundVerticalPositionAdjustment
        +setDefaultBackgroundVerticalPositionAdjustment:
        +backgroundVerticalPositionAdjustmentForBarMetrics:
        +setBackgroundVerticalPositionAdjustment:forBarMetrics:

        +defaultBackgroundVerticalPositionAdjustmentWhenContainedIn:
        +setDefaultBackgroundVerticalPositionAdjustment:whenContainedIn:
        +backgroundVerticalPositionAdjustmentForBarMetrics:whenContainedIn:
        +setBackgroundVerticalPositionAdjustment:forBarMetrics:whenContainedIn:

        // 文字位置偏移
        -defaultTitlePositionAdjustment
        -setDefaultTitlePositionAdjustment:

        +defaultTitlePositionAdjustment
        +setDefaultTitlePositionAdjustment:
        +titlePositionAdjustmentForBarMetrics:
        +setTitlePositionAdjustment:forBarMetrics:

        +defaultTitlePositionAdjustmentWhenContainedIn:
        +setDefaultTitlePositionAdjustment:whenContainedIn:
        +titlePositionAdjustmentForBarMetrics:whenContainedIn:
        +setTitlePositionAdjustment:forBarMetrics:whenContainedIn:

        // 返回按钮背景图片/颜色
        -defaultBackButtonBackgroundImage
        -setDefaultBackButtonBackgroundImage:

        +defaultBackButtonBackgroundImage
        +setDefaultBackButtonBackgroundImage:
        +backButtonBackgroundImageForState:barMetrics:
        +setBackButtonBackgroundImage:forState:barMetrics:

        +defaultBackButtonBackgroundImageWhenContainedIn:
        +setDefaultBackButtonBackgroundImage:whenContainedIn:
        +backButtonBackgroundImageForState:barMetrics:whenContainedIn:
        +setBackButtonBackgroundImage:forState:barMetrics:whenContainedIn:

        -defaultBackButtonBackgroundColor
        -setDefaultBackButtonBackgroundColor:
        -backButtonBackgroundColorForState:barMetrics:
        -setBackButtonBackgroundColor:forState:barMetrics:

        +defaultBackButtonBackgroundColor
        +setDefaultBackButtonBackgroundColor:
        +backButtonBackgroundColorForState:barMetrics:
        +setBackButtonBackgroundColor:forState:barMetrics:

        +defaultBackButtonBackgroundColorWhenContainedIn:
        +setDefaultBackButtonBackgroundColor:whenContainedIn:
        +backButtonBackgroundColorForState:barMetrics:whenContainedIn:
        +setBackButtonBackgroundColor:forState:barMetrics:whenContainedIn:

        // 返回按钮背景位置偏移
        -defaultBackButtonBackgroundVerticalPositionAdjustment
        -setDefaultBackButtonBackgroundVerticalPositionAdjustment:

        +defaultBackButtonBackgroundVerticalPositionAdjustment
        +setDefaultBackButtonBackgroundVerticalPositionAdjustment:
        +backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:
        +setBackButtonBackgroundVerticalPositionAdjustment:forBarMetrics:

        +defaultBackButtonBackgroundVerticalPositionAdjustmentWhenContainedIn:
        +setDefaultBackButtonBackgroundVerticalPositionAdjustment:whenContainedIn:
        +backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:whenContainedIn:
        +setBackButtonBackgroundVerticalPositionAdjustment:forBarMetrics:whenContainedIn:

        // 返回按钮文字位置偏移
        -defaultBackButtonTitlePositionAdjustment
        -setDefaultBackButtonTitlePositionAdjustment:

        +defaultBackButtonTitlePositionAdjustment
        +setDefaultBackButtonTitlePositionAdjustment:
        +backButtonTitlePositionAdjustmentForBarMetrics:
        +setBackButtonTitlePositionAdjustment:forBarMetrics:

        +defaultBackButtonTitlePositionAdjustmentWhenContainedIn:
        +setDefaultBackButtonTitlePositionAdjustment:whenContainedIn:
        +backButtonTitlePositionAdjustmentForBarMetrics:whenContainedIn:
        +setBackButtonTitlePositionAdjustment:forBarMetrics:whenContainedIn:

        // 字体, 字色, 文字阴影
        +textFontForState:whenContainedIn:
        +setTextFont:forState:whenContainedIn:

        +textColorForState:whenContainedIn:
        +setTextColor:forState:whenContainedIn:

        +textShadowColorForState:whenContainedIn:
        +setTextShadowColor:forState:whenContainedIn:

        +textShadowOffsetForState:whenContainedIn:
        +setTextShadowOffset:forState:whenContainedIn:

        +textShadowSizeForState:whenContainedIn:
        +setTextShadowSize:forState:whenContainedIn:

- UITabBarItem+AGXCore

        // 实例化方法(适配IOS7以下的系统)
        +tabBarItemWithTitle:image:selectedImage:

        // 添加自定义样式方法, 可自定义文字位置偏移.
        +titlePositionAdjustment
        +setTitlePositionAdjustment:

- UIViewController+AGXCore

        // 添加属性.
        statusBarStyle

        // 添加方法.
        -setStatusBarStyle:animated:

- UINavigationController+AGXCore

        // 添加导航控制方法, 支持导航起始/结束时回调代码块.
        -pushViewController:animated:initialWithBlock:completionWithBlock:
        -popViewControllerAnimated:cleanupWithBlock:completionWithBlock:

    添加分类: UIViewController (AGXCoreUINavigationController)

        // 添加属性.
        navigationBar

        // 添加导航控制方法.
        -pushViewController:animated:
        -popViewControllerAnimated:
        -popToViewController:animated:
        -popToRootViewControllerAnimated:
        -pushViewController:animated:initialWithBlock:completionWithBlock:
        -popViewControllerAnimated:cleanupWithBlock:completionWithBlock:

        // 添加导航控制中回调方法.
        -willNavigatePush:
        -didNavigatePush:
        -willNavigatePop:
        -didNavigatePop:
