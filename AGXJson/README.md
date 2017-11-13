# AGXJson

JSON工具代码.

```objective-c
// 默认使用NSJSONSerialization.
// 设置布尔值AGX_USE_JSONKIT为真值后, 使用JSONKit.
// 修改JSONKit, 支持ARC.

// 将对象转换为JSON时, 若对象不是合法的NSJSONSerialization类型, 将会先尝试转换为合法类型.
// 若转换后仍不是合法类型, 则返回description或其UTF8编码后的NSData对象.

// 将对象转换为JSON时, 可指定AGXJsonOptions选项.
NS_OPTIONS AGXJsonOptions: 指定JSON序列化选项
AGXJsonNone           : 默认值
AGXJsonWriteClassName : 序列化时写入对象类型
```

#####Categories

- NSData+AGXJson

```objective-c
// NSData JSON反序列化工具方法
-agxJsonObject
-agxJsonObjectAsClass:
```

- NSString+AGXJson

```objective-c
// NSString JSON反序列化工具方法
-agxJsonObject
-agxJsonObjectAsClass:
```

- NSObject+AGXJson

```objective-c
// NSObject JSON序列化工具方法
-agxJsonData
-agxJsonDataWithOptions:
-agxJsonString
-agxJsonStringWithOptions:
```

- NSObject+AGXJsonable

```objective-c
// NSObject 由合法的可JSON序列化对象获得一般对象的工具方法
// 遍历对象属性列表, 读取JSON对象并赋值.
// 如果属性由NSObject定义, 则忽略.
// 如果指定的属性为弱引用/只读, 则忽略.
+instanceWithValidJsonObject:
-initWithValidJsonObject:
-setPropertiesWithValidJsonObject:

// NSObject 转换为合法的可JSON序列化对象的工具方法
// 遍历对象属性列表, 生成JSON对象.
// 如果属性由NSObject定义, 则忽略.
// 如果指定的属性为弱引用, 则忽略.
-validJsonObject
-validJsonObjectWithOptions:
```

- NSValue+AGXJsonable

```objective-c
// NSValue 由合法的可JSON序列化对象获得包装对象的工具方法
+valueWithValidJsonObject:

// NSValue 添加与JSON对象互转工具方法的宏
struct_jsonable_interface(structType)
struct_jsonable_implementation(structType)

// 示例:
typedef struct {
  ...
} CustomStruct;
@struct_jsonable_interface(CustomStruct)
@struct_jsonable_implementation(CustomStruct)
- (id)validJsonObjectForCustomStruct {
    ...
    return @{...};
}
+ (NSValue * )valueWithValidJsonObjectForCustomStruct:(id)jsonObject {
    ...
    return [NSValue valueWith...];
}
@end
```

- NSString+AGXJsonable

```objective-c
// NSString/NSMutableString 简易初始化方法
+stringWithValidJsonObject:
```

- NSArray+AGXJsonable

```objective-c
// NSArray/NSMutableArray 简易初始化方法
+arrayWithValidJsonObject:
```

- NSDictionary+AGXJsonable

```objective-c
// NSDictionary/NSMutableDictionary 简易初始化方法
+dictionaryWithValidJsonObject:
```
