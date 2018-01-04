//
//  AGXService.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  MugunthKumar/MKNetworkKit
//

//  MKNetworkKit is licensed under MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import "AGXService.h"
#import "AGXCache.h"
#import "NSHTTPURLResponse+AGXNetwork.h"
#import "AGXRequest+Private.h"
#import "AGXNetworkResource.h"

static NSString *const agxServiceDefaultCacheDirectory = @"com.agxnetwork.servicecache";

@interface AGXService () <NSURLSessionDelegate>
@property (nonatomic, AGX_STRONG)   AGXCache *respCache;
@property (nonatomic, AGX_STRONG)   AGXCache *dataCache;
@end

@implementation AGXService {
    NSMutableDictionary *_defaultHeaders;
}

+ (AGX_INSTANCETYPE)service {
    return [self instance];
}

+ (AGX_INSTANCETYPE)serviceWithHost:(NSString *)hostString {
    return AGX_AUTORELEASE([[self alloc] initWithHost:hostString]);
}

- (AGX_INSTANCETYPE)init {
    return [self initWithHost:@""];
}

- (AGX_INSTANCETYPE)initWithHost:(NSString *)hostString {
    if AGX_EXPECT_T(self = [super init]) {
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
    return [self requestWithPath:path params:nil];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params {
    return [self requestWithPath:path params:params httpMethod:@"GET"];
}

- (AGXRequest *)requestWithPath:(NSString *)path httpMethod:(NSString *)httpMethod {
    return [self requestWithPath:path params:nil httpMethod:httpMethod];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    return [self requestWithPath:path params:params httpMethod:httpMethod bodyData:nil];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData {
    return [self requestWithPath:path params:params httpMethod:httpMethod bodyData:bodyData useSSL:_isSecureService];
}

- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData useSSL:(BOOL)useSSL {
    NSString *urlString = [_hostString isNotEmpty] ?
    [NSString stringWithFormat:@"%@://%@%@", useSSL ? @"https" : @"http", _hostString, path] : path;

    AGXRequest *request = [AGXRequest requestWithURLString:urlString params:params httpMethod:httpMethod bodyData:bodyData];
    request.parameterEncoding = _defaultParameterEncoding;
    [request addHeaders:_defaultHeaders];
    return request;
}

- (void)startRequest:(AGXRequest *)request {
    [self prepareCacheHeaders:request];
    [request doBuild];

    if AGX_EXPECT_F(!request || !request.request) {
        AGXLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }

    if AGX_EXPECT_T([self useCacheInsteadOfDoRequest:request]) return;
    NSURLSession *session = request.isSecureRequest ?
    [AGXNetworkResource ephemeralSession] : [AGXNetworkResource defaultSession];
    request.sessionTask = [session dataTaskWithRequest:request.request completionHandler:
                           ^(NSData *data, NSURLResponse *response, NSError *error) {
                               if (AGXRequestStateCancelled == request.state) return;

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

    if AGX_EXPECT_F(!request || !request.request) {
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

    if AGX_EXPECT_F(!request || !request.request) {
        AGXLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }

    [request addCompletionHandler:^(AGXRequest *request) {
        if (request.state != AGXRequestStateCompleted) return;
        if (request.isCacheable && !request.errorResponding) {
            _respCache[@(request.hash)] = request.response;
        }
    }];
    if ([self useCacheInsteadOfDoRequest:request]) {
        request.progress = 1.0;
        [request doDownloadProgressHandler];
        return;
    }
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
    if AGX_EXPECT_F(!cachedResponse) {
        if (request.cachePolicy & AGXCachePolicyOnlyCache) {
            request.error = [NSError errorWithDomain:@"com.agxnetwork.httperrordomain"
                                                code:500 userInfo:nil];
            request.state = AGXRequestStateError;
        }
        return(request.cachePolicy & AGXCachePolicyOnlyCache);
    }

    request.response = cachedResponse;
    request.responseData = _dataCache[@(request.hash)];

    NSTimeInterval expiresTimeFromNow = cachedResponse.expiresTimeSinceNow;
    request.state = expiresTimeFromNow > 0 ?
    AGXRequestStateResponseAvailableFromCache : AGXRequestStateStaleResponseAvailableFromCache;

    return((request.cachePolicy & AGXCachePolicyAlwaysCache)
           || (!(request.cachePolicy & AGXCachePolicyAlwaysUpdate)
               && expiresTimeFromNow > 0));
}

@end
