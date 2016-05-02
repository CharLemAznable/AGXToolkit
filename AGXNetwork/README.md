# AGXNetwork

HTTP访问组件.

#####Constants

- AGXDataEncoding

    参数编码类型.

- AGXRequestState

    HTTP请求状态.

- AGXCachePolicy

    缓存策略.

- AGXHandler

    回调Block类型.

#####Components

- AGXCache

    缓存对象.

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

- AGXNetworkDelegate

    全局代理, 继承UIApplicationDelegate.

        // 代理设置全局Session配置
        -application:defaultSessionConfiguration:
        -application:ephemeralSessionConfiguration:
        -application:backgroundSessionConfiguration:

- AGXRequest

    HTTP请求对象.

        // 鉴权属性.
        username
        password
        clientCertificate
        clientCertificatePassword

        // 缓存策略.
        cachePolicy

        // 参数编码.
        parameterEncoding

        // 下载目标地址.
        downloadPath

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

- AGXService

    HTTP服务对象.

        // 属性
        hostString // 域名
        isSecureService // 是否使用https
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
        -requestWithPath:params:httpMethod:
        -requestWithPath:params:httpMethod:bodyData:
        -requestWithPath:params:httpMethod:bodyData:useSSL:

        // 请求开始.
        -startRequest:
        -startUploadRequest:
        -startDownloadRequest:

#####Categories

- NSHTTPURLResponse+AGXNetwork

        // 添加属性, 获取响应头字段值.
        lastModified
        eTag
        cacheControl
        maxAge
        noCache
        expiresTimeSinceNow
