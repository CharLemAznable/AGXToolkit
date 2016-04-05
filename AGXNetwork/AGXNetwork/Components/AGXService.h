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
#import "AGXNetworkTypes.h"

@class AGXRequest;

@interface AGXService : NSObject
@property (nonatomic, readonly)     NSString *hostString;
@property (nonatomic, readonly)     NSDictionary *defaultHeaders;
@property (nonatomic, readonly)     BOOL secureHost;
@property (nonatomic, assign)       AGXDataEncoding defaultDataEncoding;

- (AGX_INSTANCETYPE)initWithHost:(NSString *)hostString;
- (void)enableCache;
- (void)enableCacheWithDirectoryPath:(NSString *)directoryPath inMemoryCost:(NSUInteger)memoryCost;

- (AGXRequest *)requestWithURLString:(NSString *)urlString;
- (AGXRequest *)requestWithPath:(NSString *)path;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)method;
- (AGXRequest *)requestWithPath:(NSString *)path params:(NSDictionary *)params httpMethod:(NSString *)method
                           body:(NSData *)bodyData ssl:(BOOL)useSSL;

- (void)startRequest:(AGXRequest *)request;
- (void)startUploadRequest:(AGXRequest *)request;
- (void)startDownloadRequest:(AGXRequest *)request;
@end

#endif /* AGXNetwork_AGXService_h */
