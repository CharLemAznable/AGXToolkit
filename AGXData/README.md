# AGXData

本地数据(keychain, user defaults, etc)工具代码.

#####Components

- AGXKeychain

    keychain工具, 重构自SFHFKeychainUtils, 支持ARC.

        +passwordForUsername:andService:error:
        +storePassword:forUsername:andService:updateExisting:error:
        +deletePasswordForUsername:andService:error:

- AGXDataBox

    @interface ZUXDataBox

        // 判断App运行历史信息
        +appEverLaunched
        +appFirstLaunch

    @protocol ZUXDataBox

        // 数据同步方法
        -synchronize

        // 自定义用户数据存储在UserDefaults/Keychain中的键名
        // default  : 数据存储在UserDefaults中, 随App卸载而清除
        // keychain : 数据存储在Keychain中, 重装App后仍保留旧数据
        // restrict : 数据存储在Keychain中, 重装App后删除旧数据
        // share    : 数据可被全局访问/修改
        // users    : 数据读写与指定的关键字相关联

        +defaultShareKey
        +keychainShareKey
        +keychainShareDomain
        +restrictShareKey
        +restrictShareDomain

        +defaultUsersKey
        +keychainUsersKey
        +keychainUsersDomain
        +restrictUsersKey
        +restrictUsersDomain

    DataBox工具宏

        // 定义databox, 单例类, 遵循<ZUXDataBox>协议
        @databox_interface(className, superClassName)

        // 实现databox
        @databox_implementation(className)

        // databox实例方法, 读写全局存储数据
        -defaultShareObjectForKey:
        -setDefaultShareObject:forKey:
        -keychainShareObjectForKey:
        -setKeychainShareObject:forKey:
        -restrictShareObjectForKey:
        -setRestrictShareObject:forKey:

        // databox实例方法, 读写关联关键字存储数据
        -defaultUsersObjectForKey:userId:
        -setDefaultUsersObject:forKey:userId:
        -keychainUsersObjectForKey:userId:
        -setKeychainUsersObject:forKey:userId:
        -restrictUsersObjectForKey:userId:
        -setRestrictUsersObject:forKey:userId:

        // 合成全局存储属性
        @default_share(className, property)
        @keychain_share(className, property)
        @restrict_share(className, property)

        // 合成关联关键字存储属性, userIdProperty指定关联的databox属性的关键字
        @default_users(className, property, userIdProperty)
        @keychain_users(className, property, userIdProperty)
        @restrict_users(className, property, userIdProperty)

        // databox定义示例
        // 注: 存储属性的内存管理类型要求为强引用.
        // 注: 存储属性合成时机为App的main方法执行前, 所以在main方法执行前调用属性getter/setter会报错, e. g. , +load方法.
        @databox_interface(UserDefaults, NSObject)
        @property (nonatomic, strong) NSString * userId;
        @property (nonatomic, strong) NSString * name;
        @property (nonatomic, strong) NSString * version;
        @end

        @databox_implementation(UserDefaults)
        @default_share(UserDefaults, userId)
        @keychain_users(UserDefaults, name, userId)
        @restrict_users(UserDefaults, version, userId)
        @end

        // databox调用示例
        [UserDefaults shareUserDefaults].userId = @"111";
        [UserDefaults shareUserDefaults].name = @"aaa";
        [UserDefaults shareUserDefaults].version = @"0.0.1";
        NSLog(@"%@", [UserDefaults shareUserDefaults].userId);  // output: 111
        NSLog(@"%@", [UserDefaults shareUserDefaults].name);    // output: aaa
        NSLog(@"%@", [UserDefaults shareUserDefaults].version); // output: 0.0.1
        [[UserDefaults shareUserDefaults] synchronize];

        [UserDefaults shareUserDefaults].userId = @"222";
        [UserDefaults shareUserDefaults].name = @"bbb";
        [UserDefaults shareUserDefaults].version = @"0.0.2";
        NSLog(@"%@", [UserDefaults shareUserDefaults].userId);  // output: 222
        NSLog(@"%@", [UserDefaults shareUserDefaults].name);    // output: bbb
        NSLog(@"%@", [UserDefaults shareUserDefaults].version); // output: 0.0.2
        [[UserDefaults shareUserDefaults] synchronize];

        [UserDefaults shareUserDefaults].userId = @"111";
        NSLog(@"%@", [UserDefaults shareUserDefaults].userId);  // output: 111
        NSLog(@"%@", [UserDefaults shareUserDefaults].name);    // output: aaa
        NSLog(@"%@", [UserDefaults shareUserDefaults].version); // output: 0.0.1

        [UserDefaults shareUserDefaults].userId = @"222";
        NSLog(@"%@", [UserDefaults shareUserDefaults].userId);  // output: 222
        NSLog(@"%@", [UserDefaults shareUserDefaults].name);    // output: bbb
        NSLog(@"%@", [UserDefaults shareUserDefaults].version); // output: 0.0.2

- AGXAppConfig

    自动读取Bundle中的plist文件作为应用程序配置.

        // 定义配置宏
        @appconfig_interface(className, superClassName)

        // 实现配置宏
        @appconfig_implementation(className)

        // 指定配置文件(.plist)所在Bundle, 默认为应用程序根Bundle
        appconfig_bundle(className, bundleName)

        // 合成配置属性宏
        @appconfig(className, property)

        // 定义示例
        @appconfig_interface(AppConfig, NSObject)
        @property (nonatomic, strong) NSString * key;
        @property (nonatomic, strong) NSString * key1;
        @end
        @appconfig_implementation(AppConfig)
        @appconfig(AppConfig, key)
        @appconfig(AppConfig, key1)
        @end

        @appconfig_interface(BundleConfig, NSObject)
        @property (nonatomic, strong) NSString * key;
        @property (nonatomic, strong) NSString * key2;
        @end
        @appconfig_implementation(BundleConfig)
        appconfig_bundle(BundleConfig, ZUXAppConfig)
        @appconfig(BundleConfig, key)
        @appconfig(BundleConfig, key2)
        @end

        // 使用示例

        // 根目录新建plist文件, 文件名为当前应用的BundleID.
        // 文件内容:
        // <dict>
        //    <key>key1</key>
        //    <string>value1</string>
        // </dict>
        [AppConfig shareAppConfig].key1

        // 新建ZUXAppConfig.Bundle, 在其中根路径新建plist文件, 文件名为当前应用的BundleID.
        // 文件内容:
        // <dict>
        //    <key>key2</key>
        //    <string>value2</string>
        // </dict>
        [BundleConfig shareBundleConfig].key2
