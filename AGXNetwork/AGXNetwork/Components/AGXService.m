//
//  AGXService.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXService.h"
#import "AGXCache.h"
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>

static NSString *const kAGXServiceDefaultCacheDirectory = @"com.agxnetwork.servicecache";

@interface AGXService () <NSURLSessionDelegate>
@property (nonatomic, AGX_STRONG)   AGXCache *reqDataCache;
@property (nonatomic, AGX_STRONG)   AGXCache *rspDataCache;
@end

@implementation AGXService

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

    AGX_RELEASE(_reqDataCache);
    AGX_RELEASE(_rspDataCache);
    AGX_SUPER_DEALLOC;
}

- (void)enableCache {
    [self enableCacheWithDirectoryPath:kAGXServiceDefaultCacheDirectory inMemoryCost:0];
}

- (void)enableCacheWithDirectoryPath:(NSString *)directoryPath inMemoryCost:(NSUInteger)memoryCost {
    NSString *reqdataPath = [NSString stringWithFormat:@"%@/reqdata", directoryPath];
    _reqDataCache = [[AGXCache alloc] initWithDirectoryPath:reqdataPath memoryCost:memoryCost];
    NSString *rspdataPath = [NSString stringWithFormat:@"%@/rspdata", directoryPath];
    _rspDataCache = [[AGXCache alloc] initWithDirectoryPath:rspdataPath memoryCost:memoryCost];
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
    AGXRequest *request = [[AGXRequest alloc] initWithURLString:urlString params:params httpMethod:httpMethod bodyData:bodyData];
    request.parameterEncoding = _defaultParameterEncoding;
    [request addHeaders:_defaultHeaders];
    
    if(request.isCacheable && !request.ignoreCache) {
        NSHTTPURLResponse *cachedResponse = _rspDataCache[@(request.hash)];
        NSString *lastModified = [cachedResponse.allHeaderFields objectForCaseInsensitiveKey:@"Last-Modified"];
        NSString *eTag = [cachedResponse.allHeaderFields objectForCaseInsensitiveKey:@"ETag"];
        if (lastModified) [request addHeaders:@{@"IF-MODIFIED-SINCE": lastModified}];
        if (eTag) [request addHeaders:@{@"IF-NONE-MATCH": eTag}];
    }

    return AGX_AUTORELEASE(request);
}

@end
