//
//  AGXService.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
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

#ifndef AGXNetwork_AGXService_h
#define AGXNetwork_AGXService_h

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXNetworkTypes.h"
#import "AGXRequest.h"

@interface AGXService : NSObject
@property (nonatomic, readonly)     NSString *hostString;
@property (nonatomic, assign)       BOOL isSecureService;
@property (nonatomic, assign)       AGXDataEncoding defaultParameterEncoding;

+ (AGXService *)service;
+ (AGXService *)serviceWithHost:(NSString *)hostString;
- (AGX_INSTANCETYPE)init;
- (AGX_INSTANCETYPE)initWithHost:(NSString *)hostString;
- (void)enableCache;
- (void)enableCacheWithDirectoryPath:(NSString *)directoryPath inMemoryCost:(NSUInteger)memoryCost;
- (void)addDefaultHeaders:(NSDictionary *)defaultHeadersDictionary;

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
