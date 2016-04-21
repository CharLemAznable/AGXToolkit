//
//  AGXRequest.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXRequest.h"
#import <AGXCore/AGXCore/NSString+AGXCore.h>

@implementation AGXRequest {
    NSMutableArray *_stateHistory;
    
    NSString *_urlString;
    NSMutableDictionary *_headers;
    NSMutableDictionary *_params;
    NSString *_httpMethod;
    NSData *_bodyData;
    
    NSMutableArray *_attachedDatas;
    NSMutableArray *_attachedFiles;
    
    NSMutableArray *_completionHandlers;
    NSMutableArray *_uploadProgressChangedHandlers;
    NSMutableArray *_downloadProgressChangedHandlers;
}

@synthesize httpMethod = _httpMethod;
@synthesize responseData = _responseData;

- (AGX_INSTANCETYPE)initWithURLString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData {
    if (self = [super init]) {
        _stateHistory = [[NSMutableArray alloc] init];
        
        _urlString = AGX_RETAIN(urlString);
        _params = [[NSMutableDictionary alloc] initWithDictionary:params];
        _headers = [[NSMutableDictionary alloc] init];
        _httpMethod = AGX_RETAIN(httpMethod);
        _bodyData = AGX_RETAIN(bodyData);
        
        _attachedDatas = [[NSMutableArray alloc] init];
        _attachedFiles = [[NSMutableArray alloc] init];
        
        _completionHandlers = [[NSMutableArray alloc] init];
        _uploadProgressChangedHandlers = [[NSMutableArray alloc] init];
        _downloadProgressChangedHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_stateHistory);
    
    AGX_RELEASE(_urlString);
    AGX_RELEASE(_headers);
    AGX_RELEASE(_params);
    AGX_RELEASE(_httpMethod);
    AGX_RELEASE(_bodyData);
    
    AGX_RELEASE(_attachedDatas);
    AGX_RELEASE(_attachedFiles);
    
    AGX_RELEASE(_completionHandlers);
    AGX_RELEASE(_uploadProgressChangedHandlers);
    AGX_RELEASE(_downloadProgressChangedHandlers);
    AGX_SUPER_DEALLOC;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[AGXRequest class]]) return NO;
    return [self isEqualToRequest:object];
}

- (BOOL)isEqualToRequest:(AGXRequest *)request {
    return [self hash] == [request hash];
}

- (NSUInteger)hash {
    if ([_httpMethod isCaseInsensitiveEqualToString:@"POST"] ||
        [_httpMethod isCaseInsensitiveEqualToString:@"PATCH"]) return arc4random();
    
    return [[NSString stringWithArray:@[_httpMethod.uppercaseString, _urlString,
                                        [NSString stringWithDictionary:_params separator:@"&"
                                                     keyValueSeparator:@"=" filterEmpty:YES],
                                        _username, _password,
                                        _clientCertificate,
                                        _clientCertificatePassword]
                            separator:@" " filterEmpty:NO] hash];
}

- (NSString *)description {
    NSMutableString *displayString =
    [NSMutableString stringWithFormat:
     @"--------\n%@\nRequest\n-------\n%@\n--------\n",
     [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]],
     [self curlCommandLineString]];
    
    NSString *responseString = self.responseAsString;
    if ([responseString length] > 0) {
        [displayString appendFormat:
         @"Response\n--------\n%@\n--------\n",
         responseString];
    }
    return displayString;
}

- (NSString *)curlCommandLineString {
    NSURLRequest *request = self.request;
    
    __block NSMutableString *displayString =
    [NSMutableString stringWithFormat:@"curl -X %@ \'%@\'",
     request.HTTPMethod, request.URL.absoluteString];
    
    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:
     ^(id key, id value, BOOL *stop) {
         [displayString appendFormat:@" -H \'%@: %@\'", key, value];
     }];
    
    if ([request.HTTPMethod isEqualToString:@"POST"] ||
        [request.HTTPMethod isEqualToString:@"PUT"] ||
        [request.HTTPMethod isEqualToString:@"PATCH"]) {
        
        NSString *option = _params.count == 0 ? @"-d" : @"-F";
        if (_parameterEncoding == AGXDataEncodingURL) {
            [_params enumerateKeysAndObjectsUsingBlock:
             ^(id key, id value, BOOL *stop) {
                 [displayString appendFormat:@" %@ \'%@=%@\'", option, key, value];
             }];
        } else {
            [displayString appendFormat:@" -d \'%@\'",
             [NSString stringWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
        }
    }
    
    return displayString;
}

- (BOOL)isSSL {
    return [_urlString hasCaseInsensitivePrefix:@"https"];
}

- (BOOL)requiresAuthentication {
    return (_username != nil || _password != nil ||
            _clientCertificate != nil ||
            _clientCertificatePassword != nil);
}

- (BOOL)isCacheable {
    if (_doNotCache || ![_httpMethod isCaseInsensitiveEqualToString:@"GET"]) return NO;
    return !(self.requiresAuthentication || self.isSSL) || _alwaysCache;
}

- (BOOL)isCachedResponse {
    return (_state == AGXRequestStateResponseAvailableFromCache ||
            _state == AGXRequestStateStaleResponseAvailableFromCache);
}

- (BOOL)responseAvailable {
    return self.isCachedResponse || _state == AGXRequestStateCompleted;
}

- (NSString *)responseAsString {
    NSString *string = [NSString stringWithData:_responseData encoding:NSUTF8StringEncoding];
    if (_responseData.length > 0 && !string) {
        string = [NSString stringWithData:_responseData encoding:NSASCIIStringEncoding];
    }
    return string;
}

- (id)responseAsJSON {
    if (!_responseData) return nil;
    
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&error];
    if (!json) AGXLog(@"JSON Parsing Error: %@", error);
    return json;
}

- (void)addParams:(NSDictionary *)paramsDictionary {
    [_params addEntriesFromDictionary:paramsDictionary];
}

- (void)addHeaders:(NSDictionary *)headersDictionary {
    [_headers addEntriesFromDictionary:headersDictionary];
}

- (void)setAuthorizationHeaderValue:(NSString *)value forAuthType:(NSString *)authType {
    [_headers setObject:[NSString stringWithFormat:@"%@ %@", authType, value] forKey:@"Authorization"];
}

- (void)attachFile:(NSString *)filePath forName:(NSString *)name mimeType:(NSString *)mimeType {
    [_attachedFiles addObject:@{@"filepath" : filePath, @"name" : name, @"mimetype" : mimeType}];
}

- (void)attachData:(NSData *)data forName:(NSString *)name mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    [_attachedDatas addObject:@{@"data" : data, @"name" : name, @"mimetype" : mimeType, @"filename" : fileName?:name}];
}

- (void)addCompletionHandler:(AGXHandler)completionHandler {
    [_completionHandlers addObject:completionHandler];
}

- (void)addUploadProgressChangedHandler:(AGXHandler)uploadProgressChangedHandler {
    [_uploadProgressChangedHandlers addObject:uploadProgressChangedHandler];
}

- (void)addDownloadProgressChangedHandler:(AGXHandler)downloadProgressChangedHandler {
    [_downloadProgressChangedHandlers addObject:downloadProgressChangedHandler];
}

- (void)cancel {
    if (_state != AGXRequestStateStarted) return;
    [_task cancel];
    self.state = AGXRequestStateCancelled;
}

- (void)setState:(AGXRequestState)state {
    _state = state;
    [_stateHistory addObject:@(state)];
    
    if (state == AGXRequestStateStarted) {
        NSAssert(self.task, @"Task missing");
        [self.task resume];
        [self increaseRunningOperations];
        
    } else if (state == AGXRequestStateResponseAvailableFromCache ||
              state == AGXRequestStateStaleResponseAvailableFromCache) {
        [_completionHandlers enumerateObjectsUsingBlock:
         ^(AGXHandler handler, NSUInteger idx, BOOL *stop) { handler(self); }];
        
    } else if (state == AGXRequestStateCompleted || state == AGXRequestStateError) {
        [self decreaseRunningOperations];
        [_completionHandlers enumerateObjectsUsingBlock:
         ^(AGXHandler handler, NSUInteger idx, BOOL *stop) { handler(self); }];
        
    } else if (state == AGXRequestStateCancelled) {
        [self decreaseRunningOperations];
    }
}

#pragma mark - private methods

- (void)increaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations++;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = numberOfRunningOperations > 0;)
}

- (void)decreaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations--;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = numberOfRunningOperations > 0;
     if (numberOfRunningOperations < 0) AGXLog(@"operation's count below zero. State Changes [%@]", _stateHistory);)
}

@end
