# AGXCore

日常开发核心工具代码

#####Constant

* 判断当前设备类型

```objective-c
AGX_IS_IPHONEX
```

* 根据设备类型获取视口变化比例

```objective-c
AGX_DeviceScale
```

* 屏幕逻辑尺寸

```objective-c
AGX_LogicScreenSize
```

* 适配设备缩放的一像素点值

```objective-c
AGX_SinglePixel
```

* 判断当前系统版本

```objective-c
AGX_BEFORE_IOSX_X
AGX_IOSX_X_OR_LATER
```

* 调试输出宏

```objective-c
AGXLog(fmt, ...)
```

#####Components

- AGXCategory

    添加Category工具宏, 用于定义Category并自动加载.

```objective-c
// 定义Category
@category_interface(className, categoryName)

// 实现Category
@category_implementation(className, categoryName)

// 添加的分类将于__attribute__((constructor))时自动加载,
// 所以可以省略Other Linker Flags: "-all_load -ObjC"
```

- AGXSingleton

    添加单例宏.

```objective-c
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
```

- AGXYCombinator

    添加Y组合子宏.

```objective-c
// 不动点组合子是Lambda演算的一部分, 是一个可以计算函数不动点的高阶函数.
// 最著名的不动点组合子: Y组合子(Y-Combinator), Y = λf.(λx.f(x(x))) (λx.f(x(x))).
// Y组合子的神奇之处在于, 它能够利用匿名函数/Lambda的方式来表述递归调用.

// 详见测试用例: AGXYCombinatorTest.m
AGXRecursiveBlock recursive = AGXYCombinator(^(int n) { if n==0 then finish else recursive_with(n-1) end });
id result = recursive(initial_value);
```

- AGXMath

```objective-c
// 添加数据类型适配方法
CGFloat cgfabs(CGFloat)
CGFloat cgceil(CGFloat)
CGFloat cgfloor(CGFloat)
CGFloat cground(CGFloat)
long int cglround(CGFloat)

CGFloat cgsin(CGFloat)
CGFloat cgcos(CGFloat)
CGFloat cgtan(CGFloat)
CGFloat cgasin(CGFloat)
CGFloat cgacos(CGFloat)
CGFloat cgatan(CGFloat)

CGFloat cgpow(CGFloat, CGFloat)
CGFloat cgsqrt(CGFloat)
```

- AGXGeometry

    添加方向枚举.

```objective-c
AGXDirection
```

    添加二维坐标工具方法.

```objective-c
CGRect AGX_CGRectMake(CGPoint origin, CGSize size);
CGSize AGX_CGSizeFromUIOffset(UIOffset offset);
UIOffset AGX_UIOffsetFromCGSize(CGSize size);
CGVector AGX_CGVectorFromDirection(AGXDirection direction);
```

- AGXDirectory

    添加应用目录工具, 使用点语法调用: `AGXDirectory.caches.subpathAs(@"...").imageWithFile(@"...");`

```objective-c
// 应用根目录
+document
+caches
+temporary

// 默认使用Documents目录
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
+stringWithFile(NSString*, NSStringEncoding)
+arrayWithFile(NSString*)
+dictionaryWithFile(NSString*)
+setWithFile(NSString*)
+imageWithFile(NSString*)
+writeToFileWithContent(NSString*, id<NSCoding>)
+writeToFileWithData(NSString*, NSData*)
+writeToFileWithString(NSString*, NSString*, NSStringEncoding)
+writeToFileWithArray(NSString*, NSArray*)
+writeToFileWithDictionary(NSString*, NSDictionary*)
+writeToFileWithSet(NSString*, NSSet*)
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
-stringWithFile(NSString*, NSStringEncoding)
-arrayWithFile(NSString*)
-dictionaryWithFile(NSString*)
-setWithFile(NSString*)
-imageWithFile(NSString*)
-writeToFileWithContent(NSString*, id<NSCoding>)
-writeToFileWithData(NSString*, NSData*)
-writeToFileWithString(NSString*, NSString*, NSStringEncoding)
-writeToFileWithArray(NSString*, NSArray*)
-writeToFileWithDictionary(NSString*, NSDictionary*)
-writeToFileWithSet(NSString*, NSSet*)
-writeToFileWithImage(NSString*, UIImage*)
-directoryPath(NSString*)
-directoryExists(NSString*)
-deleteDirectory(NSString*)
-createDirectory(NSString*)
```

- AGXBundle

    资源bundle工具, 使用点语法调用: `AGXBundle.appBundle.subpathAs(@"...").imageWithFile(@"...");`

```objective-c
// 获取当前App Bundle
+appBundle

// 默认使用当前AppBundle
+bundleNameAs(NSString*) // 使用指定名称的bundle
+subpathAs(NSString*)
+filePath(NSString*)
+fileURL(NSString*)
+contentWithFile(NSString*)
+dataWithFile(NSString*)
+stringWithFile(NSString*, NSStringEncoding)
+arrayWithFile(NSString*)
+dictionaryWithFile(NSString*)
+setWithFile(NSString*)
+imageWithFile(NSString*)

// 指定资源bundle
-bundleNameAs(NSString*)
-subpathAs(NSString*)
-filePath(NSString*)
-fileURL(NSString*)
-contentWithFile(NSString*)
-dataWithFile(NSString*)
-stringWithFile(NSString*, NSStringEncoding)
-arrayWithFile(NSString*)
-dictionaryWithFile(NSString*)
-setWithFile(NSString*)
-imageWithFile(NSString*)

// AppBundle工具方法
+appInfoDictionary
+appIdentifier
+appVersion
+appBuildNumber
+appBundleName
+viewControllerBasedStatusBarAppearance
```

- AGXColorSet

    颜色集合类, 用于加载配置文件中的颜色表.

- AGXRandom

    随机数生成类, 使用点语法调用.

```objective-c
+BOOLEAN
+INT
+INT_UNDER(unsigned int)
+INT_BETWEEN(unsigned int, unsigned int)
+LONG
+LONG_UNDER(unsigned long)
+LONG_BETWEEN(unsigned long, unsigned long)
+UINTEGER
+UINTEGER_UNDER(NSUInteger)
+UINTEGER_BETWEEN(NSUInteger, NSUInteger)
+FLOAT // default between 0..1
+FLOAT_UNDER(float)
+FLOAT_BETWEEN(float, float)
+DOUBLE // default between 0..1
+DOUBLE_UNDER(double)
+DOUBLE_BETWEEN(double, double)
+CGFLOAT // default between 0..1
+CGFLOAT_UNDER(CGFloat)
+CGFLOAT_BETWEEN(CGFloat, CGFloat)

+ASCII(int)
+NUM(int)
+LETTERS(int)
+ALPHANUMERIC(int)
+CHARACTERS(int, NSString*)

+CGPOINT // default x&y between 0..1
+CGPOINT_IN(CGRect)

+UICOLOR_RGB // default alpha 1
+UICOLOR_RGB_ALL_LIMITIN(CGFloat, CGFloat)
+UICOLOR_RGB_LIMITIN(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
+UICOLOR_RGBA
+UICOLOR_RGBA_ALL_LIMITIN(CGFloat, CGFloat)
+UICOLOR_RGBA_LIMITIN(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)

+UIFONT_NAME
+UIFONT // default size between 10..20
+UIFONT_LIMITIN(CGFloat, CGFloat)
```

#####Category (Foundation)

* NSObject+AGXCore

```objective-c
// 判断类型是否是参数类型的真子类型
+isProperSubclassOfClass:

// 创建对象实例, 使用-init方法
+instance

// 创建对象副本, 对象需遵循NSCoding协议否则返回nil
-duplicate

// 添加类属性, 设置是否静默处理未定义属性的KVC
silentUndefinedKeyValueCoding

// 封装Selector添加方法
+addInstanceMethodWithSelector:andBlock:andTypeEncoding:
+addOrReplaceInstanceMethodWithSelector:andBlock:andTypeEncoding:
+addClassMethodWithSelector:andBlock:andTypeEncoding:
+addOrReplaceClassMethodWithSelector:andBlock:andTypeEncoding:

// 封装Selector替换方法
+swizzleInstanceOriSelector:withNewSelector:
+swizzleInstanceOriSelector:withNewSelector:fromClass:
+swizzleClassOriSelector:withNewSelector:
+swizzleClassOriSelector:withNewSelector:fromClass:

// 多键添加/移除KVO方法
-addObserver:forKeyPaths:options:context:
-removeObserver:forKeyPaths:context:
-removeObserver:forKeyPaths:

// 关联对象方法, 添加实例变量
-assignPropertyForAssociateKey:
-setAssignProperty:forAssociateKey:
-setKVOAssignProperty:forAssociateKey:
-retainPropertyForAssociateKey:
-setRetainProperty:forAssociateKey:
-setKVORetainProperty:forAssociateKey:
-copyPropertyForAssociateKey:
-setCopyProperty:forAssociateKey:
-setKVOCopyProperty:forAssociateKey:

// 将对象转化为PropertyList格式数据
-plistData
-plistString
```

* NSNull+AGXCore

```objective-c
//封装判断空对象方法
+isNull:
+isNotNull:
```

* NSNumber+AGXCore

```objective-c
// 添加NSNumber与CGFloat兼容方法
+numberWithCGFloat:
-initWithCGFloat:
-cgfloatValue

// 添加字符串数字化方法 (NSString)
-cgfloatValue
```

* NSCoder+AGXCore

```objective-c
// 添加NSCoder与CGFloat兼容方法
-encodeCGFloat:forKey:
-decodeCGFloatForKey:
```

- NSData+AGXCore

```objective-c
// Base64转码方法
-base64EncodedString
+dataWithBase64String:

// AES加解密方法
-AES256EncryptedDataUsingKey:
-AES256DecryptedDataUsingKey:

// 将PropertyList数据转化为对象
-objectFromPlist
```

- NSString+AGXCore

```objective-c
// 数字化方法
-unsignedIntegerValue

// 简易初始化方法
+stringWithFormat:arguments:
+stringWithData:encoding:
+stringWithBytes:length:encoding:

// 判断空字符串
-isEmpty
-isNotEmpty

// 裁剪空白字符串
-trim
-trimToNil

// 首字母大写, 其它字母不变 (-capitalizedString方法有此bug)
-capitalized

//  版本号字符串比较方法
-compareToVersionString:

// 判断是否包含
-containsCharacterFromSet:
-containsAnyOfStringInArray:
-containsAllOfStringInArray:

// 定位子字符串
-indexOfString:
-indexOfCharacterFromSet:
-lastIndexOfString:
-lastIndexOfCharacterFromSet:
-indexOfString:fromIndex:
-indexOfCharacterFromSet:fromIndex:
-lastIndexOfString:toIndex:
-lastIndexOfCharacterFromSet:toIndex:

// 截取子字符串, 如果不包含子字符串则返回原文拷贝
-substringFromFirstString:
-substringFromFirstCharacterFromSet:
-substringToFirstString:
-substringToFirstCharacterFromSet:
-substringFromLastString:
-substringFromLastCharacterFromSet:
-substringToLastString:
-substringToLastCharacterFromSet:

// 切割字符串
-arraySeparatedByString:filterEmpty:
-arraySeparatedByCharactersInSet:filterEmpty:
-dictionarySeparatedByString:keyValueSeparatedByString:filterEmpty:
-dictionarySeparatedByCharactersInSet:keyValueSeparatedByCharactersInSet:filterEmpty:

// 归并集合为字符串
+stringWithArray:joinedByString:usingComparator:filterEmpty:
+stringWithDictionary:joinedByString:keyValueJoinedByString:usingKeysComparator:filterEmpty:

// 追加对象到字符串末尾
-appendWithObjects:

// 替换字符串
-stringByReplacingString:withString:
-stringByReplacingCharactersInSet:withString:mergeContinuous:

// URL字符串转义方法
-stringByEscapingForURLQuery
-stringByUnescapingFromURLQuery

// 计算MD5
-MD5Sum

// 计算SHA1
-SHA1Sum

// AES加解密方法
-AES256EncryptedStringUsingKey:
-AES256DecryptedStringUsingKey:

// Base64转码方法
-base64EncodedString
+stringWithBase64String:

// Unicode/UTF8互转方法
+replaceUnicodeToUTF8:
+replaceUTF8ToUnicode:

// 生成UUID字符串
+uuidString

// 参数化字符串方法, 替换字符串中的"${keyPath}"为[object valueForKeyPath:@"keyPath"]
-parametricStringWithObject:

// 计算字符串占据的尺寸(适配IOS7及以上的系统)
-agxSizeWithFont:constrainedToSize:
-agxSizeWithFont:constrainedToSize:lineBreakMode:

// 将PropertyList字符串转化为对象
-objectFromPlist

//  比较字符串 (忽略大小写)
-isCaseInsensitiveEqual:
-isCaseInsensitiveEqualToString:
-hasCaseInsensitivePrefix:
-hasCaseInsensitiveSuffix:

// 判断是否包含子字符串 (忽略大小写)
-containsCaseInsensitiveString:
-containsAnyOfCaseInsensitiveStringInArray:
-containsAllOfCaseInsensitiveStringInArray:

// 定位子字符串 (忽略大小写)
-indexOfCaseInsensitiveString:
-lastIndexOfCaseInsensitiveString:
-indexOfCaseInsensitiveString:fromIndex:
-lastIndexOfCaseInsensitiveString:fromIndex:

// 截取子字符串, 如果不包含子字符串则返回原文拷贝 (忽略大小写)
-substringFromFirstCaseInsensitiveString:
-substringToFirstCaseInsensitiveString:
-substringFromLastCaseInsensitiveString:
-substringToLastCaseInsensitiveString:

// 切割字符串 (忽略大小写)
-componentsSeparatedByCaseInsensitiveString:
-arraySeparatedByCaseInsensitiveString:filterEmpty:
-dictionarySeparatedByCaseInsensitiveString:keyValueSeparatedByCaseInsensitiveString:filterEmpty:

// 替换字符串 (忽略大小写)
-stringByReplacingCaseInsensitiveString:withString:
```

- NSValue+AGXCore

```objective-c
// 增加NSValue对结构类型的KVC处理
-valueForKey:
-valueForKeyPath:

// 增加自定义结构体boxed分类定义/实现宏
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
```

* NSArray+AGXCore

```objective-c
// 判空
-isEmpty
-isNotEmpty

// 深拷贝数组
-deepCopy               // 不可变深拷贝, 数组项需要遵循<NSCoding>协议
-mutableDeepCopy        // 容器可变深拷贝, 仅顶层数组改为可变, 数组项需要遵循<NSCoding>协议
-deepMutableCopy        // 内容可变深拷贝, 仅数组项改为可变, 数组项需要实现-mutableCopy方法
-mutableDeepMutableCopy // 可变深拷贝, 数组与数组项都改为可变, 数组项需要实现-mutableCopy方法

// 取数组元素值方法, 可指定默认返回值
-objectAtIndex:defaultValue:

// 倒序数组
-reverseArray

// 归并为字符串
-stringJoinedByString:usingComparator:filterEmpty:

// 向数组添加对象, 不添加相同对象
-addAbsenceObject:
-addAbsenceObjectsFromArray:
```

* NSDictionary+AGXCore

```objective-c
// 判空
-isEmpty
-isNotEmpty

// 深拷贝字典
-deepCopy               // 不可变深拷贝, 键值项需要遵循<NSCoding>协议
-mutableDeepCopy        // 容器可变深拷贝, 仅顶层字典改为可变, 键值项需要遵循<NSCoding>协议
-deepMutableCopy        // 内容可变深拷贝, 仅各项值改为可变, 各项值需要实现-mutableCopy方法
-mutableDeepMutableCopy // 可变深拷贝, 字典与各项值都改为可变, 各项值需要实现-mutableCopy方法

// 取字典元素值方法, 可指定默认返回值
-objectForKey:defaultValue:

// 取字典元素值方法, 忽略Key大小写
-objectForCaseInsensitiveKey:

// 根据Key数组取子字典方法 (区别于-dictionaryWithValuesForKeys:方法, 字典中不包含的Key不会放入子字典)
-subDictionaryForKeys:

// 归并为字符串
-stringJoinedByString:keyValueJoinedByString:usingKeysComparator:filterEmpty:

// 向字典添加对象, 不覆盖原有键值
-addAbsenceEntriesFromDictionary:
```

- NSSet+AGXCore

```objective-c
// 判空
-isEmpty
-isNotEmpty

// 深拷贝字典
-deepCopy               // 不可变深拷贝, 成员值需要遵循<NSCoding>协议
-mutableDeepCopy        // 容器可变深拷贝, 仅顶层集合改为可变, 成员值需要遵循<NSCoding>协议
-deepMutableCopy        // 内容可变深拷贝, 仅成员值改为可变, 成员值需要实现-mutableCopy方法
-mutableDeepMutableCopy // 可变深拷贝, 集合与成员值都改为可变, 成员值需要实现-mutableCopy方法

// 取集合成员值方法, 可指定默认返回值
-member:defaultValue:

// 归并为字符串
-stringJoinedByString:usingComparator:filterEmpty:
```

- NSExpression+AGXCore

```objective-c
// NSExpression保留字列表
+keywordsArrayInExpressionFormat

// NSExpression格式化参数构造方法, 替换${keyPath}为%K, 并添加绑定参数keyPath
+expressionWithParametricFormat:
```

- NSDate+AGXCore

```objective-c
// 添加毫秒数据类型
AGXTimeIntervalMills

// 获得毫秒单位时间间隔
-timeIntervalMillsSinceDate:

// 添加只读属性
timeIntervalMillsSinceNow
timeIntervalMillsSince1970

// 添加只读属性
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

// 时间格式化工具方法
-stringWithDateFormat:
-stringWithDateFormat:timeZone:

// RFC1123 format
+dateFromRFC1123:
-rfc1123String

// RFC3339 format
+dateFromRFC3339:
-rfc3339String

// 添加秒数据类型box/unbox方法 (NSNumber)
+numberWithTimeInterval:
-initWithTimeInterval:
-timeIntervalValue

// 添加毫秒数据类型box/unbox方法 (NSNumber)
+numberWithMills:
-initWithMills:
-millsValue

// 字符串格式时间工具方法 (NSString)
-dateWithDateFormat:
-dateWithDateFormat:timeZone:

// 添加字符串数字化方法 (NSString)
-timeIntervalValue
-millsValue
```

- NSURLRequest+AGXCore

```objective-c
// 是否跳转
-isNewRequestFromURL:
```

- NSHTTPCookieStorage+AGXCore

```objective-c
// 获取所有cookie, 按名称过滤
-cookiesWithNames:
// 获取所有cookie, 按名称过滤, 生成可放入请求头的字符串
-cookieFieldForRequestHeaderWithNames:
// 获取所有cookie, 按名称过滤, 生成key-value字典
-cookieValuesWithNames:

-cookieWithName:
-cookieFieldForRequestHeaderWithName:
-cookieValueWithName:

// 获取发送到指定URL的cookies
-cookiesForURLString:

-cookiesWithNames:forURLString:
-cookieFieldForRequestHeaderWithNames:forURLString:
-cookieValuesWithNames:forURLString:

-cookieWithName:forURLString:
-cookieFieldForRequestHeaderWithName:forURLString:
-cookieValueWithName:forURLString:
```

- NSError+AGXCore

```objective-c
// 简易初始化方法
+errorWithDomain:code:description:
// 向NSError对象写入内容
+fillError:withDomain:code:description:
// 清除NSError对象的内容
+clearError:
```

#####Category (UIKit)

- UIDevice+AGXCore

```objective-c
// 添加读取设备型号方法
-completeModelString  // 如: iPhone7,1
-purifiedModelString  // 如: iPhone 6Plus
+completeModelString  // 当前设备型号
+purifiedModelString  // 当前设备型号

// 添加读取浏览器UserAgent
-webkitVersionString // AppleWebKit/XXX
+webkitVersionString // 当前设备浏览器
```

- UIApplication+AGXCore

```objective-c
// 远程通知注册与检测方法
+registerUserNotificationTypes:
-registerUserNotificationTypes:
+registerUserNotificationTypes:categories:
-registerUserNotificationTypes:categories:
+getRegistedNotificationTypeWithCompletionHandler:
-getRegistedNotificationTypeWithCompletionHandler:
```

- UIView+AGXCore

```objective-c
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
shadowSize

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

// 添加截图方法
-imageRepresentation
// 添加设置Frame方法
-resizeFrame:
```

- UIWindow+AGXCore

```objective-c
// 简便方法, 获取当前主窗口
+sharedKeyWindow
```

- UIControl+AGXCore

```objective-c
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
```

- UIButton+AGXCore

```objective-c
// 添加-forState:方法
-backgroundColorForState:
-setBackgroundColor:forState:

// 自定义样式方法
+backgroundImageForState:
+setBackgroundImage:forState:
+backgroundColorForState:
+setBackgroundColor:forState:
```

- UILabel+AGXCore

```objective-c
// 添加行间距属性
linesSpacing
```

- UIImage+AGXCore

```objective-c
// 由图片URL生成图像
+imageWithURLString:
+imageWithURLString:scale:

// 生成点图像并指定颜色
+imagePointWithColor:

// 生成矩形图像并指定颜色
+imageRectWithColor:size:

// 生成渐变矩形图像
+imageGradientRectWithStartColor:endColor:direction:size:
+imageGradientRectWithColors:locations:direction:size:

// 生成椭圆形图像并指定颜色
+imageEllipseWithColor:size:

// 生成叉形图片
+imageCrossWithColor:edge:lineWidth:

// 生成省略号形图片
+imageEllipsisWithColor:edge:

// 生成箭头形图片
+imageArrowWithColor:edge:direction:

// 生成验证码图片
+captchaImageWithCaptchaCode:size:

// 添加图片水印
// default:
// direction:AGXDirectionSouthEast
// offset:CGVectorMake(0, 0)
+imageBaseOnImage:watermarkedWithImage:
+imageBaseOnImage:watermarkedWithImage:inDirection:
+imageBaseOnImage:watermarkedWithImage:withOffset:
+imageBaseOnImage:watermarkedWithImage:inDirection:withOffset:

// 添加文字水印
// default:
// direction:AGXDirectionSouthEast
// offset:CGVectorMake(0, 0)
// NSForegroundColorAttributeName:AGX_UIColor(1, 1, 1, .7)
+imageBaseOnImage:watermarkedWithText:
+imageBaseOnImage:watermarkedWithText:withAttributes:
+imageBaseOnImage:watermarkedWithText:inDirection:
+imageBaseOnImage:watermarkedWithText:withOffset:
+imageBaseOnImage:watermarkedWithText:withAttributes:inDirection:
+imageBaseOnImage:watermarkedWithText:withAttributes:withOffset:
+imageBaseOnImage:watermarkedWithText:inDirection:withOffset:
+imageBaseOnImage:watermarkedWithText:withAttributes:inDirection:withOffset:

// 获取对应当前设备尺寸的图片名称或图片对象
// 依据不同尺寸图片命名后缀规则:
//   - X:  -1100-2436h
//   - 6P: -800-Portrait-736h
//   - 6:  -800-667h
//   - 5:  -700-568h
//   - 其他: @2x或无后缀
+imageForCurrentDeviceNamed:
+imageNameForCurrentDeviceNamed:

// 获取对应当前像素比的图片名称, 后缀 @2x 或 @3x
+imageNameForCurrentPixelRatioNamed:

// 获取图片主色调
-dominantColor

// 添加AGXDirectory分类, 文件名自动按设备添加后缀
+imageForCurrentDeviceWithFile(NSString*)
+writeToFileWithImageForCurrentDevice(NSString*, UIImage*)
-imageForCurrentDeviceWithFile(NSString*)
-writeToFileWithImageForCurrentDevice(NSString*, UIImage*)

// 添加AGXBundle分类, 文件名自动按设备添加后缀
+imageForCurrentDeviceWithFile(NSString*)
-imageForCurrentDeviceWithFile(NSString*)
```

- UIImageView+AGXCore

```objective-c
// 简便初始化方法
+imageViewWithImage:
```

- UITextField+AGXCore

```objective-c
// 限制输入文本内容及长度
-shouldChangeCharactersInRange:replacementString:limitWithLength:
```

- UITextView+AGXCore

```objective-c
// 限制输入文本内容及长度
-shouldChangeCharactersInRange:replacementString:limitWithLength:
```

- UIColor+AGXCore

```objective-c
// 根据255格式颜色生成UIColor
+colorWithIntegerRed:green:blue:
+colorWithIntegerRed:green:blue:alpha:

// 根据十六进制字符串格式颜色生成UIColor
+colorWithRGBHexString:
+colorWithRGBAHexString:

// 添加只读属性
rgbaCGColorRef // 获取RGBA ColorSpace的CGColorRef
colorAlpha // 获取Alpha值
colorShade // 判断颜色深浅, 透明返回AGXColorShadeUnmeasured

// 判断颜色是否相同, 使用rgbaCGColorRef实现比较
-isEqualToColor:

// 添加简易初始化函数
UIColor* AGXColor(NSUInteger, NSUInteger, NSUInteger)
UIColor* AGXColor(NSUInteger, NSUInteger, NSUInteger, NSUInteger);
UIColor* AGXColor(NSString*);
UIColor* AGX_UIColor(CGFloat, CGFloat, CGFloat);
UIColor* AGX_UIColor(CGFloat, CGFloat, CGFloat, CGFloat);
```

- UINavigationBar+AGXCore

```objective-c
// 添加属性, 获取Bar所属的UINavigationController
navigationController

// 添加自定义样式方法, 可自定义BarStyle, 透明模式, tint颜色, barTint颜色, 背景颜色/图片, 字体, 字色, 文字阴影
+barStyle
+setBarStyle:

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
```

- UITabBar+AGXCore

```objective-c
// 添加只读属性, 获取TabBar的TabBarButton集合
barButtons

// 添加自定义样式方法, 可自定义透明模式, 背景图片, 选中项背景图片, 选中项tint颜色, barTint颜色
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

-selectedImageTintColor
-setSelectedImageTintColor:
+selectedImageTintColor
+setSelectedImageTintColor:
```

- UINavigationItem+AGXCore

```objective-c
// 修复leftItemsSupplementBackButton属性在Coding序列化/反序列化时丢失的Bug
```

- UIBarItem+AGXCore

```objective-c
// 添加自定义样式方法, 可自定义字体, 字色, 文字阴影
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
```

- UIBarButtonItem+AGXCore

```objective-c
// 添加自定义样式方法
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
```

- UITabBarItem+AGXCore

```objective-c
// 简便实例化方法
+tabBarItemWithTitle:image:selectedImage:

// 添加自定义样式方法, 可自定义文字位置偏移
+titlePositionAdjustment
+setTitlePositionAdjustment:
```

- UIActionSheet+AGXCore

```objective-c
// 简便实例化方法
+actionSheetWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:
```

- UIAlertView+AGXCore

```objective-c
// 简便实例化方法
+alertViewWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:
```

- UIViewController+AGXCore

```objective-c
// 全局变量
AGXStatusBarStyleSettingDuration // 状态栏设置动画时长, 当UIViewControllerBasedStatusBarAppearance为YES时有效

// 添加属性
viewVisible // 只读, 当前控制器视图是否可见
automaticallyAdjustsStatusBarStyle // 是否自动调整状态栏样式, default to YES
// 自动调整状态栏样式
//   根据当前控制器视图的背景色主色调自动调整状态栏样式
//   如果当前控制器为TabBarController, 则使用selectedViewController的背景色
//   如果当前控制器为NavigationController:
//     如果当前导航栏显示, 则使用导航栏backgroundImage的主色调(或barTintColor的色调)
//     如果当前导航栏隐藏, 则使用topViewController的背景色
//   切换标签栏控制器/显隐导航栏/修改导航栏backgroundImage(或barTintColor)/修改当前控制器视图背景色都将触发自动调整
statusBarStyle // 控制器的状态栏样式
statusBarHidden // 控制器的状态栏显隐
navigationBar // 当控制器在导航栈内时有效
navigationBarHidden // 当控制器在导航栈内时有效
hidesBarsOnSwipe // 当控制器在导航栈内时有效
hidesBarsOnTap // 当控制器在导航栈内时有效

// 添加方法
-setStatusBarStyle:animated:
-setStatusBarHidden:animated:
-setNavigationBarHidden:animated: // 当控制器在导航栈内时有效

// 修改默认值
automaticallyAdjustsScrollViewInsets // Defaults to NO
```

- UIScrollView+AGXCore

```objective-c
// 添加滚动至顶部/底部方法
-scrollToTop:
-scrollToBottom:
```

- UITableView+AGXCore

```objective-c
// 添加滚动至首行/尾行方法
-scrollToTop:
-scrollToBottom:
```

- UIWebView+AGXCore

```objective-c
// 添加简便方法, 加载字符串指定的URL请求
-loadRequestWithURLString:
-loadRequestWithURLString:cachePolicy:
// 添加简便方法, 加载字符串指定的URL请求, 并设置请求头
-loadRequestWithURLString:addHTTPHeaderFields:
-loadRequestWithURLString:cachePolicy:addHTTPHeaderFields:

// 添加简便方法, 加载字符串指定的URL请求, 并附加指定名称的cookies
-loadRequestWithURLString:addCookieFieldWithNames:
-loadRequestWithURLString:cachePolicy:addCookieFieldWithNames:
// 添加简便方法, 加载字符串指定的URL请求, 并附加指定名称的cookies, 同时可设置其他请求头
-loadRequestWithURLString:addCookieFieldWithNames:addHTTPHeaderFields:
-loadRequestWithURLString:cachePolicy:addCookieFieldWithNames:addHTTPHeaderFields:

// 获取当前页面的cookies
-cookiesWithNames:
-cookieFieldForRequestHeaderWithNames:
-cookieValuesWithNames:

-cookieWithName:
-cookieFieldForRequestHeaderWithName:
-cookieValueWithName:

// 获取/设置UserAgent
-userAgent
+userAgent

+setUserAgent:
+addUserAgent:
```

- UIImagePickerController+AGXCore

```objective-c
// 修复UIImagePickerController中automaticallyAdjustsScrollViewInsets为YES
```
