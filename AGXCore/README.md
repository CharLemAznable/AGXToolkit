# AGXCore

日常开发核心工具代码.

#####Constant

* 判断当前设备类型.

        AGX_IS_IPHONEX

* 根据设备类型获取视口变化比例.

        AGX_DeviceScale

* 屏幕逻辑尺寸

        AGX_LogicScreenSize

* 适配设备缩放的一像素点值

        AGX_SinglePixel

* 判断当前系统版本.

        AGX_BEFORE_IOSX
        AGX_IOSX_OR_LATER

* 调试输出宏

        AGXLog(fmt, ...) // 预定义AGX_DEBUG, 则打印日志

#####Components

- AGXCategory

    添加Category工具宏, 用于定义Category并自动加载.

        // 定义Category
        @category_interface(className, categoryName)

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
        [MySingleton shareInstance]

- AGXMath

        添加数据类型适配方法
        CGFloat cgfabs(CGFloat)
        CGFloat cgceil(CGFloat)
        CGFloat cgfloor(CGFloat)
        CGFloat cground(CGFloat)
        long int cglround(CGFloat)

- AGXGeometry

    添加方向枚举.

        AGXDirection

    添加二维坐标工具方法.

        CGRect AGX_CGRectMake(CGPoint origin, CGSize size);
        CGSize AGX_CGSizeFromUIOffset(UIOffset offset);
        UIOffset AGX_UIOffsetFromCGSize(CGSize size);
        CGVector AGX_CGVectorFromDirection(AGXDirection direction);

- AGXDirectory

    添加应用目录工具, 使用点语法调用: AGXDirectory.caches.subpathAs(@"...").imageWithFile(@"...");

        // 应用根目录.
        +document
        +caches
        +temporary

        // 默认使用Documents目录.
        +subpathAs(NSString*)
        +filePath(NSString*)
        +createPathOfFile(NSString*)
        +fileExists(NSString*)
        +plistFileExists(NSString*)
        +imageFileExists(NSString*)
        +deleteFile(NSString*)
        +deletePlistFile(NSString*)
        +deleteImageFile(NSString*)
        +contentWithFile(NSString*)
        +dataWithFile(NSString*)
        +arrayWithFile(NSString*)
        +dictionaryWithFile(NSString*)
        +imageWithFile(NSString*)
        +writeToFileWithContent(NSString*, id<NSCoding>)
        +writeToFileWithData(NSString*, NSData*)
        +writeToFileWithArray(NSString*, NSArray*)
        +writeToFileWithDictionary(NSString*, NSDictionary*)
        +writeToFileWithImage(NSString*, UIImage*)
        +directoryPath(NSString*)
        +directoryExists(NSString*)
        +deleteDirectory(NSString*)
        +createDirectory(NSString*)

        // 指定使用其他根目录
        -subpathAs(NSString*)
        -filePath(NSString*)
        -createPathOfFile(NSString*)
        -fileExists(NSString*)
        -plistFileExists(NSString*)
        -imageFileExists(NSString*)
        -deleteFile(NSString*)
        -deletePlistFile(NSString*)
        -deleteImageFile(NSString*)
        -contentWithFile(NSString*)
        -dataWithFile(NSString*)
        -arrayWithFile(NSString*)
        -dictionaryWithFile(NSString*)
        -imageWithFile(NSString*)
        -writeToFileWithContent(NSString*, id<NSCoding>)
        -writeToFileWithData(NSString*, NSData*)
        -writeToFileWithArray(NSString*, NSArray*)
        -writeToFileWithDictionary(NSString*, NSDictionary*)
        -writeToFileWithImage(NSString*, UIImage*)
        -directoryPath(NSString*)
        -directoryExists(NSString*)
        -deleteDirectory(NSString*)
        -createDirectory(NSString*)

- AGXBundle

    资源bundle工具, 使用点语法调用: AGXBundle.appBundle.subpathAs(@"...").imageWithFile(@"...");

        // 获取当前App Bundle.
        +appBundle

        // 默认使用当前AppBundle.
        +bundleNameAs(NSString*) // 使用指定名称的bundle
        +subpathAs(NSString*)
        +filePath(NSString*)
        +fileURL(NSString*)
        +contentWithFile(NSString*)
        +dataWithFile(NSString*)
        +arrayWithFile(NSString*)
        +dictionaryWithFile(NSString*)
        +imageWithFile(NSString*)

        // 指定资源bundle
        -bundleNameAs(NSString*)
        -subpathAs(NSString*)
        -filePath(NSString*)
        -fileURL(NSString*)
        -contentWithFile(NSString*)
        -dataWithFile(NSString*)
        -arrayWithFile(NSString*)
        -dictionaryWithFile(NSString*)
        -imageWithFile(NSString*)

        // AppBundle工具方法
        +appInfoDictionary
        +appIdentifier
        +appVersion
        +viewControllerBasedStatusBarAppearance

- AGXColorSet

    颜色集合类, 用于加载配置文件中的颜色表.

#####Category (Foundation)

* NSObject+AGXCore

        // 创建对象实例, 使用-init方法
        +instance

        // 创建对象副本, 对象需遵循NSCoding协议否则返回nil
        -duplicate

        // 封装Selector添加方法
        +addInstanceMethodWithSelector:andBlock:andTypeEncoding:
        +addOrReplaceInstanceMethodWithSelector:andBlock:andTypeEncoding:
        +addClassMethodWithSelector:andBlock:andTypeEncoding:
        +addOrReplaceClassMethodWithSelector:andBlock:andTypeEncoding:

        // 封装Selector替换方法.
        +swizzleInstanceOriSelector:withNewSelector:
        +swizzleInstanceOriSelector:withNewSelector:fromClass:
        +swizzleClassOriSelector:withNewSelector:
        +swizzleClassOriSelector:withNewSelector:fromClass:

        // 多键添加/移除KVO方法.
        -addObserver:forKeyPaths:options:context:
        -removeObserver:forKeyPaths:context:
        -removeObserver:forKeyPaths:

        // 关联对象方法, 添加实例变量.
        -assignPropertyForAssociateKey:
        -setAssignProperty:forAssociateKey:
        -setKVOAssignProperty:forAssociateKey:
        -retainPropertyForAssociateKey:
        -setRetainProperty:forAssociateKey:
        -setKVORetainProperty:forAssociateKey:
        -copyPropertyForAssociateKey:
        -setCopyProperty:forAssociateKey:
        -setKVOCopyProperty:forAssociateKey:

        // 将对象转化为PropertyList格式数据.
        -plistData
        -plistString

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

        // 将PropertyList数据转化为对象.
        -objectFromPlist

- NSString+AGXCore

        // 数字化方法
        -unsignedIntegerValue

        // 简易初始化方法
        +stringWithData:encoding:

        // 判断空字符串.
        -isEmpty
        -isNotEmpty

        // 裁剪空白字符串.
        -trim
        -trimToNil

        // 首字母大写, 其它字母不变. (-capitalizedString方法有此bug)
        -capitalized

        //  版本号字符串比较方法.
        -compareToVersionString:

        // 判断是否包含子字符串.
        -containsString:
        -containsCharactersFromSet:
        -containsAnyOfStringInArray:
        -containsAllOfStringInArray:

        // 定位子字符串.
        -indexOfString:
        -indexOfCharactersFromSet:
        -lastIndexOfString:
        -lastIndexOfCharactersFromSet:
        -indexOfString:fromIndex:
        -indexOfCharactersFromSet:fromIndex:
        -lastIndexOfString:fromIndex:
        -lastIndexOfCharactersFromSet:fromIndex:

        // 截取子字符串, 如果不包含子字符串则返回原文拷贝.
        -substringFromFirstString:
        -substringFromFirstCharactersFromSet:
        -substringToFirstString:
        -substringToFirstCharactersFromSet:
        -substringFromLastString:
        -substringFromLastCharactersFromSet:
        -substringToLastString:
        -substringToLastCharactersFromSet:

        // 切割字符串.
        -arraySeparatedByString:filterEmpty:
        -arraySeparatedByCharactersInSet:filterEmpty:
        -dictionarySeparatedByString:keyValueSeparatedByString:filterEmpty:
        -dictionarySeparatedByCharactersInSet:keyValueSeparatedByCharactersInSet:filterEmpty:

        // 归并集合为字符串.
        +stringWithArray:usingComparator:separator:filterEmpty:
        +stringWithDictionary:usingKeysComparator:separator:keyValueSeparator:filterEmpty:

        // 追加对象到字符串末尾.
        -appendWithObjects:

        // 替换字符串.
        -stringByReplacingString:withString:
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

        // 生成UUID字符串
        +uuidString

        // 参数化字符串方法, 替换字符串中的"${key}"为[object valueForKey:@"key"].
        -parametricStringWithObject:

        // 计算字符串占据的尺寸(适配IOS7及以上的系统)
        -agxSizeWithFont:constrainedToSize:

        // 将PropertyList字符串转化为对象.
        -objectFromPlist

        //  比较字符串.(忽略大小写)
        -isCaseInsensitiveEqual:
        -isCaseInsensitiveEqualToString:
        -hasCaseInsensitivePrefix:
        -hasCaseInsensitiveSuffix:

        // 判断是否包含子字符串.(忽略大小写)
        -containsCaseInsensitiveString:
        -containsCaseInsensitiveCharactersFromSet:
        -containsAnyOfCaseInsensitiveStringInArray:
        -containsAllOfCaseInsensitiveStringInArray:

        // 定位子字符串.(忽略大小写)
        -indexOfCaseInsensitiveString:
        -indexOfCaseInsensitiveCharactersFromSet:
        -lastIndexOfCaseInsensitiveString:
        -lastIndexOfCaseInsensitiveCharactersFromSet:
        -indexOfCaseInsensitiveString:fromIndex:
        -indexOfCaseInsensitiveCharactersFromSet:fromIndex:
        -lastIndexOfCaseInsensitiveString:fromIndex:
        -lastIndexOfCaseInsensitiveCharactersFromSet:fromIndex:

        // 截取子字符串, 如果不包含子字符串则返回原文拷贝.(忽略大小写)
        -substringFromFirstCaseInsensitiveString:
        -substringFromFirstCaseInsensitiveCharactersFromSet:
        -substringToFirstCaseInsensitiveString:
        -substringToFirstCaseInsensitiveCharactersFromSet:
        -substringFromLastCaseInsensitiveString:
        -substringFromLastCaseInsensitiveCharactersFromSet:
        -substringToLastCaseInsensitiveString:
        -substringToLastCaseInsensitiveCharactersFromSet:

        // 替换字符串.(忽略大小写)
        -stringByReplacingCaseInsensitiveString:withString:

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
        -deepCopy               // 不可变深拷贝, 数组项需要遵循<NSCoding>协议
        -mutableDeepCopy        // 容器可变深拷贝, 仅顶层数组改为可变, 数组项需要遵循<NSCoding>协议
        -deepMutableCopy        // 内容可变深拷贝, 仅数组项改为可变, 数组项需要实现-mutableCopy方法
        -mutableDeepMutableCopy // 可变深拷贝, 数组与数组项都改为可变, 数组项需要实现-mutableCopy方法

        // 取数组元素值方法, 可指定默认返回值.
        -objectAtIndex:defaultValue:

        // 倒序数组.
        -reverseArray

* NSDictionary+AGXCore

        // 深拷贝字典.
        -deepCopy               // 不可变深拷贝, 键值项需要遵循<NSCoding>协议
        -mutableDeepCopy        // 容器可变深拷贝, 仅顶层字典改为可变, 键值项需要遵循<NSCoding>协议
        -deepMutableCopy        // 内容可变深拷贝, 仅各项值改为可变, 各项值需要实现-mutableCopy方法
        -mutableDeepMutableCopy // 可变深拷贝, 字典与各项值都改为可变, 各项值需要实现-mutableCopy方法

        // 取字典元素值方法, 可指定默认返回值.
        -objectForKey:defaultValue:

        // 取字典元素值方法, 忽略Key大小写.
        -objectForCaseInsensitiveKey:

        // 根据Key数组取子字典方法. (区别于-dictionaryWithValuesForKeys:方法, 字典中不包含的Key不会放入子字典.)
        -subDictionaryForKeys:

        // 向字典添加对象, 不覆盖原有键值.
        -addAbsenceEntriesFromDictionary:

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
        monthCountInYear
        dayCountInMonth
        dayCountInYear

        // 时间格式化工具方法.
        -stringWithDateFormat:

        // RFC1123 format
        +dateFromRFC1123:
        -rfc1123String

        // 添加秒数据类型box/unbox方法. (NSNumber)
        +numberWithTimeInterval:
        -initWithTimeInterval:
        -timeIntervalValue

        // 添加毫秒数据类型box/unbox方法. (NSNumber)
        +numberWithMills:
        -initWithMills:
        -millsValue

        // 字符串格式时间工具方法. (NSString)
        -dateWithDateFormat:

        // 添加字符串数字化方法. (NSString)
        -timeIntervalValue
        -millsValue

- NSURLRequest+AGXCore

        // 是否跳转
        -isNewRequestFromURL:

#####Category (UIKit)

- UIDevice+AGXCore

        // 添加读取设备型号方法.
        -fullModelString    // 如: iPhone7,1
        -purifyModelString  // 如: iPhone 6Plus

        // 添加读取浏览器UserAgent
        -webkitVersionString // AppleWebKit/XXX

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

        // 添加编码解码方法
        -agxDecode:
        -agxEncode:

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

        // 添加截图方法.
        -imageRepresentation
        // 添加设置Frame方法.
        -resizeFrame:

- UIWindow+AGXCore

        // 简便方法, 获取当前主窗口
        +sharedKeyWindow

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

        // 新增重复点击时间间隔属性设置, 默认0.2
        acceptEventInterval

- UIButton+AGXCore

        // 添加-forState:方法
        -backgroundColorForState:
        -setBackgroundColor:forState:

        // 自定义样式方法
        +backgroundImageForState:
        +setBackgroundImage:forState:
        +backgroundColorForState:
        +setBackgroundColor:forState:

- UILabel+AGXCore

        // 添加行间距属性
        linesSpacing

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

        // 添加AGXDirectory分类, 文件名自动按设备添加后缀
        +imageForCurrentDeviceWithFile(NSString*)
        +writeToFileWithImageForCurrentDevice(NSString*, UIImage*)
        -imageForCurrentDeviceWithFile(NSString*)
        -writeToFileWithImageForCurrentDevice(NSString*, UIImage*)

        // 添加AGXBundle分类, 文件名自动按设备添加后缀
        +imageForCurrentDeviceWithFile(NSString*)
        -imageForCurrentDeviceWithFile(NSString*)

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

        // 添加只读属性
        rgbaCGColorRef // 获取RGBA ColorSpace的CGColorRef.
        colorAlpha // 获取Alpha值
        colorShade // 判断颜色深浅, 透明返回AGXColorShadeUnmeasured

        // 判断颜色是否相同, 使用rgbaCGColorRef实现比较.
        -isEqualToColor:

- UINavigationBar+AGXCore

        // 添加属性, 获取Bar所属的UINavigationController.
        navigationController

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

        +backgroundImageForBarPosition:barMetrics:
        +setBackgroundImage:forBarPosition:barMetrics:

        -currentBackgroundImage

        -defaultBackgroundColor
        -setDefaultBackgroundColor:
        +defaultBackgroundColor
        +setDefaultBackgroundColor:

        -backgroundColorForBarMetrics:
        -setBackgroundColor:forBarMetrics:
        +backgroundColorForBarMetrics:
        +setBackgroundColor:forBarMetrics:

        -backgroundColorForBarPosition:barMetrics:
        -setBackgroundColor:forBarPosition:barMetrics:
        +backgroundColorForBarPosition:barMetrics:
        +setBackgroundColor:forBarPosition:barMetrics:

        -currentBackgroundColor

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

- UINavigationItem+AGXCore

        // 修复leftItemsSupplementBackButton属性在Coding序列化/反序列化时丢失的Bug.

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

        // 简便实例化方法
        +tabBarItemWithTitle:image:selectedImage:

        // 添加自定义样式方法, 可自定义文字位置偏移.
        +titlePositionAdjustment
        +setTitlePositionAdjustment:

- UIActionSheet+AGXCore

        // 简便实例化方法
        +actionSheetWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:

- UIAlertView+AGXCore

        // 简便实例化方法
        +alertViewWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:

- UIViewController+AGXCore

        // 全局变量
        AGXStatusBarStyleSettingDuration // 状态栏设置动画时长, 当UIViewControllerBasedStatusBarAppearance为YES时有效

        // 添加属性.
        statusBarStyle
        statusBarHidden
        navigationBar
        navigationBarHidden

        // 添加方法.
        -setStatusBarStyle:animated:
        -setStatusBarHidden:animated:
        -setNavigationBarHidden:animated:

        // 修改默认值
        automaticallyAdjustsScrollViewInsets // Defaults to NO
