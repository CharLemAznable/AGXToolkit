//
//  AGXRequest.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXRequest_h
#define AGXNetwork_AGXRequest_h

#import <Foundation/Foundation.h>
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
@property (nonatomic, AGX_WEAK)     AGXCachePolicy cachePolicy;
@property (nonatomic, readonly)     BOOL isCacheable;
// Setting
@property (nonatomic, AGX_WEAK)     AGXDataEncoding parameterEncoding;
@property (nonatomic, AGX_STRONG)   NSString *downloadPath;
// State
@property (nonatomic, readonly)     AGXRequestState state;
// Request
@property (nonatomic, readonly)     NSURLRequest *request;
@property (nonatomic, readonly)     NSData *multipartFormData;
// Response
@property (nonatomic, readonly)     NSHTTPURLResponse *response;
@property (nonatomic, readonly)     NSData *responseData;
@property (nonatomic, readonly)     NSString *responseAsString;
@property (nonatomic, readonly)     id responseAsJSON;
@property (nonatomic, readonly)     NSError *error;
// Session
@property (nonatomic, readonly)     NSURLSessionTask *sessionTask;
@property (nonatomic, readonly)     double progress;

- (AGX_INSTANCETYPE)initWithURLString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData;
// Setting
- (void)addParams:(NSDictionary *)paramsDictionary;
- (void)addHeaders:(NSDictionary *)headersDictionary;
- (void)setAuthorizationHeaderValue:(NSString*)value forAuthType:(NSString*)authType;
- (void)attachFile:(NSString *)filePath forName:(NSString *)name mimeType:(NSString *)mimeType;
- (void)attachData:(NSData *)data forName:(NSString *)name mimeType:(NSString *)mimeType fileName:(NSString *)fileName;
- (void)addCompletionHandler:(AGXHandler)completionHandler;
- (void)addUploadProgressChangedHandler:(AGXHandler)uploadProgressChangedHandler;
- (void)addDownloadProgressChangedHandler:(AGXHandler)downloadProgressChangedHandler;
// Operation
- (void)cancel;
@end

#endif /* AGXNetwork_AGXRequest_h */
