# AGXNetwork

HTTP访问组件.

#####Constants

- AGXDataEncoding

    参数编码类型.

- AGXRequestState

    HTTP请求状态.

- AGXCachePolicy

    缓存策略.

#####Components

- AGXNetworkUtils

```objective-c
添加由域名解析IP地址的工具方法
NSString * parseIPAddressByHostName(NSString * )
```

- AGXCache

    缓存对象.

```objective-c
// 属性
directoryPath // 缓存文件路径, 位于用户缓存目录下.
memoryCost // 缓存大小.

// 构造方法
+cacheWithDirectoryPath:memoryCost:
-initWithDirectoryPath:memoryCost:

// 清除缓存文件
-clean

// 缓存访问
-objectForKey:
-setObject:forKey:
-objectForKeyedSubscript:
-setObject:forKeyedSubscript:
```

- AGXNetworkDelegate

    全局代理, 继承UIApplicationDelegate.

```objective-c
// 代理设置全局Session配置
-application:defaultSessionConfiguration:
-application:ephemeralSessionConfiguration:
-application:backgroundSessionConfiguration:
```

- AGXRequest

    HTTP请求对象.

```objective-c
// 鉴权属性.
username
password
clientCertificate
clientCertificatePassword

// 缓存策略.
cachePolicy

// 参数编码.
parameterEncoding

// 下载目标地址, 默认为AGXResources.document/[request.hash]
downloadDestination
downloadFileName

// 请求状态.
state

// 内部实现.
request               (NSURLRequest)
multipartFormData     (NSData)
response              (NSHTTPURLResponse)
responseData          (NSData)
responseDataAsString  (NSString)
responseDataAsJSON    (id)
error                 (NSError)

// 构造方法.
+requestWithURLString:params:httpMethod:bodyData:
-initWithURLString:params:httpMethod:bodyData:

// 设置方法.
-addParams:
-addHeaders:
-setAuthorizationHeaderValue:forAuthType:
-attachFile:forName:mimeType:
-attachData:forName:mimeType:fileName:
-addCompletionHandler:
-addUploadProgressChangedHandler:
-addDownloadProgressChangedHandler:

// 请求未开始时可以取消.
-cancel
```

- AGXService

    HTTP服务对象.

```objective-c
// 属性
hostString // 域名
isSecureService // 是否使用安全访问(不使用永久持存cookie/证书/缓存的配置)
defaultParameterEncoding // 默认参数编码

// 构造方法.
-service
-serviceWithHost:
-init
-initWithHost:

// 缓存设置, 默认不开启缓存
-enableCache
-enableCacheWithDirectoryPath:inMemoryCost:

// 设置默认请求头.
-addDefaultHeaders:

// 构造服务请求.
-requestWithPath:
-requestWithPath:params:
-requestWithPath:httpMethod:
-requestWithPath:params:httpMethod:
-requestWithPath:params:httpMethod:bodyData:

// 请求开始.
-startRequest:
-startUploadRequest:
-startDownloadRequest:
```

- AGXCentralManager

    CBCentralManager代理组件.

```objective-c
// 全局设置, 连接外设超时时间, 默认且至少为3秒
AGXConnectPeripheralTimeout

// 属性
centralManager
discoveredPeripherals
connectedPeripheral
state
delegate

// 初始化
+centralManager;
+centralManagerWithQueue:
+centralManagerWithQueue:options:
-init
-initWithQueue:
-initWithQueue:options:

// 实例方法
-scanForPeripheralsWithServices:options:
-retrievePeripheralWithIdentifier:
-connectPeripheral:options:
-disconnectPeripheral
-stopScan

// AGXCentralManagerDelegate
-centralManagerDidUpdateState:
-centralManager:shouldDiscoverPeripheral:advertisementData:RSSI:
-centralManager:didDiscoverPeripheral:advertisementData:RSSI:
-centralManager:connectPeripheralTimeout:
-centralManager:didConnectPeripheral:
-centralManager:didFailToConnectPeripheral:error:
-centralManager:didDisconnectPeripheral:error:
```

- AGXPeripheral

    CBPeripheral代理组件.

```objective-c
// 全局设置, 查询蓝牙超时时间, 默认且至少为3秒
AGXDiscoverServicesTimeout
AGXDiscoverIncludedServicesTimeout
AGXDiscoverCharacteristicsTimeout
AGXDiscoverDescriptorsTimeout

// 属性
peripheral
identifier
name
state
services
RSSI
delegate

// 初始化
+peripheralWithPeripheral:
-initWithPeripheral:

// 实例方法
-readRSSI
-discoverServices:
-discoverIncludedServices:forService:
-discoverCharacteristics:forService:
-discoverDescriptorsForCharacteristic:
-readValueForCharacteristic:
-writeValue:forCharacteristic:type:
-setNotifyValue:forCharacteristic:
-readValueForDescriptor:
-writeValue:forDescriptor:

// AGXPeripheralDelegate
-peripheral:didReadRSSI:error:
-peripheralDiscoverServicesTimeout:
-peripheral:didDiscoverServices:
-peripheral:discoverIncludedServicesTimeout:
-peripheral:didDiscoverIncludedServicesForService:error:
-peripheral:discoverCharacteristicsTimeout:
-peripheral:didDiscoverCharacteristicsForService:error:
-peripheral:discoverDescriptorsTimeout:
-peripheral:didDiscoverDescriptorsForCharacteristic:error:
-peripheral:didUpdateValueForCharacteristic:error:
-peripheral:didWriteValueForCharacteristic:error:
-peripheral:didUpdateNotificationStateForCharacteristic:error:
-peripheral:didUpdateValueForDescriptor:error:
-peripheral:didWriteValueForDescriptor:error:
```

- AGXBLEService

    CBService代理组件.

```objective-c
// 属性
service
UUID
isPrimary
includedServices
characteristics

// 初始化
+serviceWithService:andOwnPeripheral:
-initWithService:andOwnPeripheral:

// 实例方法
-discoverIncludedServices:
-discoverCharacteristics:
```

- AGXCharacteristic

    CBCharacteristic代理组件.

```objective-c
// 属性
characteristic
service
UUID
properties
value
descriptors
isBroadcasted
isNotifying

// 初始化
+characteristicWithCharacteristic:andOwnPeripheral:
-initWithCharacteristic:andOwnPeripheral:

// 实例方法
-discoverDescriptors
-readValue
-writeValue:type:
-setNotifyValue:
```

- AGXDescriptor

    CBDescriptor代理组件.

```objective-c
// 属性
descriptor
characteristic
UUID
value

// 初始化
+descriptorWithDescriptor:andOwnPeripheral:
-initWithDescriptor:andOwnPeripheral:

// 实例方法
-readValue
-writeValue:
```

#####Categories

- NSHTTPURLResponse+AGXNetwork

```objective-c
// 添加属性, 获取响应头字段值.
lastModified
eTag
cacheControl
maxAge
noCache
expiresTimeSinceNow
```

- NSUUID+AGXNetwork

```objective-c
// 添加简便初始化方法
+UUIDWithUUIDString:
+UUIDWithUUIDBytes:
```
