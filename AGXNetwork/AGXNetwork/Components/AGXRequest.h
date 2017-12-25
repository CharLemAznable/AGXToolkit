//
//  AGXRequest.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/20.
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

#ifndef AGXNetwork_AGXRequest_h
#define AGXNetwork_AGXRequest_h

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXNetworkTypes.h"

@interface AGXRequest : NSObject
// Secure
@property (nonatomic, AGX_STRONG)   NSString *username;
@property (nonatomic, AGX_STRONG)   NSString *password;
@property (nonatomic, AGX_STRONG)   NSString *clientCertificate;
@property (nonatomic, AGX_STRONG)   NSString *clientCertificatePassword;
@property (nonatomic, readonly)     BOOL isSecureRequest;
// Cache
@property (nonatomic, assign)       AGXCachePolicy cachePolicy;
@property (nonatomic, readonly)     BOOL isCacheable;
// Setting
@property (nonatomic, assign)       AGXDataEncoding parameterEncoding;
@property (nonatomic, AGX_STRONG)   NSString *downloadPath;
// State
@property (nonatomic, readonly)     AGXRequestState state;
// Request
@property (nonatomic, readonly)     NSURLRequest *request;
@property (nonatomic, readonly)     NSData *multipartFormData;
// Response
@property (nonatomic, readonly)     NSHTTPURLResponse *response;
@property (nonatomic, readonly)     NSData *responseData;
@property (nonatomic, readonly)     NSString *responseDataAsString;
@property (nonatomic, readonly)     id responseDataAsJSON;
@property (nonatomic, readonly)     NSError *error;
@property (nonatomic, readonly)     BOOL errorResponding;
// Session
@property (nonatomic, readonly)     NSURLSessionTask *sessionTask;
@property (nonatomic, readonly)     double progress;

+ (AGX_INSTANCETYPE)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData;
- (AGX_INSTANCETYPE)initWithURLString:(NSString *)URLString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData;
// Setting
- (void)addParams:(NSDictionary *)paramsDictionary;
- (void)addHeaders:(NSDictionary *)headersDictionary;
- (void)setAuthorizationHeaderValue:(NSString*)value forAuthType:(NSString*)authType;
- (void)attachFile:(NSString *)filePath forName:(NSString *)name mimeType:(NSString *)mimeType;
- (void)attachData:(NSData *)data forName:(NSString *)name mimeType:(NSString *)mimeType fileName:(NSString *)fileName;
- (void)addCompletionHandler:(void (^)(AGXRequest *request))completionHandler;
- (void)addUploadProgressChangedHandler:(void (^)(AGXRequest *request))uploadProgressChangedHandler;
- (void)addDownloadProgressChangedHandler:(void (^)(AGXRequest *request))downloadProgressChangedHandler;
// Operation
- (void)cancel;
@end

#endif /* AGXNetwork_AGXRequest_h */
