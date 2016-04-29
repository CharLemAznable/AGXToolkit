//
//  AGXService.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXService_h
#define AGXNetwork_AGXService_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXNetworkTypes.h"
#import "AGXRequest.h"

@interface AGXService : NSObject
@property (nonatomic, readonly)     NSString *hostString;
@property (nonatomic, assign)       BOOL isSecureService;

@property (nonatomic, readonly)     NSDictionary *defaultHeaders;
@property (nonatomic, assign)       AGXDataEncoding defaultParameterEncoding;

- (AGX_INSTANCETYPE)initWithHost:(NSString *)hostString;
- (void)addDefaultHeaders:(NSDictionary *)defaultHeadersDictionary;
- (void)enableCache;
- (void)enableCacheWithDirectoryPath:(NSString *)directoryPath inMemoryCost:(NSUInteger)memoryCost;

- (AGXRequest *)requestWithPath:(NSString *)path;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData useSSL:(BOOL)useSSL;

- (void)startRequest:(AGXRequest *)request;
- (void)startUploadRequest:(AGXRequest *)request;
- (void)startDownloadRequest:(AGXRequest *)request;
@end

#endif /* AGXNetwork_AGXService_h */
