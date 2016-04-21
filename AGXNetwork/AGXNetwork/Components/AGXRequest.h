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
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXNetworkTypes.h"

static NSInteger numberOfRunningOperations;

@interface AGXRequest : NSObject
@property (nonatomic, readonly)     NSURLRequest *request;
@property (nonatomic, readonly)     NSHTTPURLResponse *response;

@property (nonatomic, AGX_WEAK)     AGXDataEncoding parameterEncoding;
@property (nonatomic, readonly)     AGXRequestState state;

// authentication
@property (nonatomic, AGX_STRONG)   NSString *username;
@property (nonatomic, AGX_STRONG)   NSString *password;
@property (nonatomic, AGX_STRONG)   NSString *clientCertificate;
@property (nonatomic, AGX_STRONG)   NSString *clientCertificatePassword;

@property (nonatomic, AGX_STRONG)   NSString *downloadPath;

@property (nonatomic, AGX_WEAK)     BOOL doNotCache;
@property (nonatomic, AGX_WEAK)     BOOL alwaysCache;

@property (nonatomic, AGX_WEAK)     BOOL ignoreCache;
@property (nonatomic, AGX_WEAK)     BOOL alwaysLoad;

@property (nonatomic, AGX_STRONG)   NSString *httpMethod;

@property (nonatomic, readonly)     NSData *multipartFormData;
@property (nonatomic, readonly)     NSError *error;
@property (nonatomic, readonly)     NSURLSessionTask *task;
@property (nonatomic, readonly)     double progress;

@property (nonatomic, readonly)     BOOL isSSL;
@property (nonatomic, readonly)     BOOL requiresAuthentication;
@property (nonatomic, readonly)     BOOL isCacheable;
@property (nonatomic, readonly)     BOOL isCachedResponse;
@property (nonatomic, readonly)     BOOL responseAvailable;

@property (nonatomic, readonly)     NSData *responseData;
@property (nonatomic, readonly)     NSString *responseAsString;
@property (nonatomic, readonly)     id responseAsJSON;

- (AGX_INSTANCETYPE)initWithURLString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData;

- (void)addParams:(NSDictionary *)paramsDictionary;
- (void)addHeaders:(NSDictionary *)headersDictionary;
- (void)setAuthorizationHeaderValue:(NSString*)value forAuthType:(NSString*)authType;

- (void)attachFile:(NSString *)filePath forName:(NSString *)name mimeType:(NSString *)mimeType;
- (void)attachData:(NSData *)data forName:(NSString *)name mimeType:(NSString *)mimeType fileName:(NSString *)fileName;

- (void)addCompletionHandler:(AGXHandler)completionHandler;
- (void)addUploadProgressChangedHandler:(AGXHandler)uploadProgressChangedHandler;
- (void)addDownloadProgressChangedHandler:(AGXHandler)downloadProgressChangedHandler;

- (void)cancel;
@end

#endif /* AGXNetwork_AGXRequest_h */
