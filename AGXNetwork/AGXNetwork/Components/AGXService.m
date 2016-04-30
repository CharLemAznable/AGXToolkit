//
//  AGXService.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXService.h"
#import "AGXCache.h"
#import "NSHTTPURLResponse+AGXNetwork.h"
#import "AGXRequest+Private.h"
#import "AGXNetworkResource.h"
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>

static NSString *const agxServiceDefaultCacheDirectory = @"com.agxnetwork.servicecache";

@interface AGXService () <NSURLSessionDelegate>
@property (nonatomic, AGX_STRONG)   AGXCache *respCache;
@property (nonatomic, AGX_STRONG)   AGXCache *dataCache;
@end

@implementation AGXService {
    NSMutableDictionary *_defaultHeaders;
}

+ (AGXService *)service {
    return AGX_AUTORELEASE([[self alloc] init]);
}

+ (AGXService *)serviceWithHost:(NSString *)hostString {
    return AGX_AUTORELEASE([[self alloc] initWithHost:hostString]);
}

- (AGX_INSTANCETYPE)init {
    return [self initWithHost:@""];
}

- (AGX_INSTANCETYPE)initWithHost:(NSString *)hostString {
    if (AGX_EXPECT_T(self = [super init])) {
        _hostString = AGX_RETAIN(hostString);
        _defaultHeaders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_hostString);
    AGX_RELEASE(_defaultHeaders);

    AGX_RELEASE(_respCache);
    AGX_RELEASE(_dataCache);
    AGX_SUPER_DEALLOC;
}

- (void)enableCache {
    [self enableCacheWithDirectoryPath:agxServiceDefaultCacheDirectory inMemoryCost:0];
}

- (void)enableCacheWithDirectoryPath:(NSString *)directoryPath inMemoryCost:(NSUInteger)memoryCost {
    NSString *respCachePath = [NSString stringWithFormat:@"%@/resp", directoryPath];
    _respCache = [[AGXCache alloc] initWithDirectoryPath:respCachePath memoryCost:memoryCost];
    NSString *dataCachePath = [NSString stringWithFormat:@"%@/data", directoryPath];
    _dataCache = [[AGXCache alloc] initWithDirectoryPath:dataCachePath memoryCost:memoryCost];
}

- (void)addDefaultHeaders:(NSDictionary *)defaultHeadersDictionary {
    [_defaultHeaders addEntriesFromDictionary:defaultHeadersDictionary];
}

- (AGXRequest *)requestWithPath:(NSString *)path {
    return [self requestWithPath:path params:nil httpMethod:@"GET" bodyData:nil useSSL:_isSecureService];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params {
    return [self requestWithPath:path params:params httpMethod:@"GET" bodyData:nil useSSL:_isSecureService];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    return [self requestWithPath:path params:params httpMethod:httpMethod bodyData:nil useSSL:_isSecureService];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData {
    return [self requestWithPath:path params:params httpMethod:httpMethod bodyData:bodyData useSSL:_isSecureService];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData useSSL:(BOOL)useSSL {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", useSSL ? @"https" : @"http", _hostString, path];
    AGXRequest *request = [AGXRequest requestWithURLString:urlString params:params httpMethod:httpMethod bodyData:bodyData];
    request.parameterEncoding = _defaultParameterEncoding;
    [request addHeaders:_defaultHeaders];
    return request;
}

- (void)startRequest:(AGXRequest *)request {
    [self prepareCacheHeaders:request];
    [request doBuild];

    if (!request || !request.request) {
        AGXLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }

    if ([self useCacheInsteadOfDoRequest:request]) return;
    NSURLSession *session = request.isSecureRequest ?
    [AGXNetworkResource ephemeralSession] : [AGXNetworkResource defaultSession];
    request.sessionTask = [session dataTaskWithRequest:request.request completionHandler:
                           ^(NSData *data, NSURLResponse *response, NSError *error) {
                               if (request.state == AGXRequestStateCancelled) return;

                               request.response = (NSHTTPURLResponse *)response;
                               request.responseData = data;
                               request.error = error;
                               if (request.response.statusCode >= 400) {
                                   request.error = [NSError errorWithDomain:@"com.agxnetwork.httperrordomain"
                                                                       code:request.response.statusCode
                                                                   userInfo:@{@"response": response,
                                                                              @"error": error}];
                               }

                               if (request.isCacheable && !request.errorResponding) {
                                   _respCache[@(request.hash)] = request.response;
                                   _dataCache[@(request.hash)] = request.responseData;
                               }
                               request.state = request.errorResponding ? AGXRequestStateError : AGXRequestStateCompleted;
                           }];
    request.state = AGXRequestStateStarted;
}

- (void)startUploadRequest:(AGXRequest *)request {
    [self prepareCacheHeaders:request];
    [request doBuild];

    if (!request || !request.request) {
        AGXLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }

    request.sessionTask = [[AGXNetworkResource backgroundSession]
                           uploadTaskWithRequest:request.request
                           fromData:request.multipartFormData];
    request.state = AGXRequestStateStarted;
}

- (void)startDownloadRequest:(AGXRequest *)request {
    [self prepareCacheHeaders:request];
    [request doBuild];

    if (!request || !request.request) {
        AGXLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }

    [request addCompletionHandler:^(AGXRequest *request) {
        if (request.state != AGXRequestStateCompleted) return;
        if (request.isCacheable && !request.errorResponding) {
            _respCache[@(request.hash)] = request.response;
        }
    }];
    if ([self useCacheInsteadOfDoRequest:request]) return;
    request.sessionTask = [[AGXNetworkResource backgroundSession]
                           downloadTaskWithRequest:request.request];
    request.state = AGXRequestStateStarted;
}

#pragma mark - private methods

- (void)prepareCacheHeaders:(AGXRequest *)request {
    if (request.isCacheable && !(request.cachePolicy & AGXCachePolicyIgnoreCache)) {
        NSHTTPURLResponse *cachedResponse = _respCache[@(request.hash)];
        NSString *lastModified = cachedResponse.lastModified;
        NSString *eTag = cachedResponse.eTag;
        if (lastModified) [request addHeaders:@{@"IF-MODIFIED-SINCE": lastModified}];
        if (eTag) [request addHeaders:@{@"IF-NONE-MATCH": eTag}];
    }
}

- (BOOL)useCacheInsteadOfDoRequest:(AGXRequest *)request {
    if (!request.isCacheable || (request.cachePolicy & AGXCachePolicyIgnoreCache)) return NO;

    NSHTTPURLResponse *cachedResponse = _respCache[@(request.hash)];
    if (!cachedResponse) return NO;

    request.response = cachedResponse;
    request.responseData = _dataCache[@(request.hash)];

    NSTimeInterval expiresTimeFromNow = cachedResponse.expiresTimeSinceNow;
    request.state = expiresTimeFromNow > 0 ?
    AGXRequestStateResponseAvailableFromCache : AGXRequestStateStaleResponseAvailableFromCache;

    return(expiresTimeFromNow > 0 && !(request.cachePolicy & AGXCachePolicyUpdateAlways));
}

@end
