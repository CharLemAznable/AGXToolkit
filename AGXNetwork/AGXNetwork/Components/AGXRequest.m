//
//  AGXRequest.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/20.
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

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXJson/AGXJson.h>
#import "AGXRequest+Private.h"
#import "AGXNetworkResource.h"

@implementation AGXRequest {
    NSString *_urlString;
    NSMutableDictionary *_params;
    NSString *_httpMethod;
    NSData *_bodyData;

    NSMutableDictionary *_headers;

    NSMutableArray *_attachedDatas;
    NSMutableArray *_attachedFiles;

    NSMutableArray *_completionHandlers;
    NSMutableArray *_uploadProgressChangedHandlers;
    NSMutableArray *_downloadProgressChangedHandlers;

    NSMutableArray *_stateHistory;

    NSURLRequest *_request;
    NSData *_multipartFormData;

    NSString *_downloadPath;
}

+ (AGX_INSTANCETYPE)requestWithURLString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData {
    return AGX_AUTORELEASE([[self alloc] initWithURLString:urlString params:params httpMethod:httpMethod bodyData:bodyData]);
}

- (AGX_INSTANCETYPE)initWithURLString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)httpMethod bodyData:(NSData *)bodyData {
    if (self = [super init]) {
        _urlString = AGX_RETAIN(urlString);
        _params = [[NSMutableDictionary alloc] initWithDictionary:params];
        _httpMethod = AGX_RETAIN(httpMethod);
        _bodyData = AGX_RETAIN(bodyData);

        _headers = [[NSMutableDictionary alloc] init];

        _attachedDatas = [[NSMutableArray alloc] init];
        _attachedFiles = [[NSMutableArray alloc] init];

        _completionHandlers = [[NSMutableArray alloc] init];
        _uploadProgressChangedHandlers = [[NSMutableArray alloc] init];
        _downloadProgressChangedHandlers = [[NSMutableArray alloc] init];

        _stateHistory = [[NSMutableArray alloc] initWithObjects:@(_state), nil];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_urlString);
    AGX_RELEASE(_params);
    AGX_RELEASE(_httpMethod);
    AGX_RELEASE(_bodyData);

    AGX_RELEASE(_headers);

    AGX_RELEASE(_attachedDatas);
    AGX_RELEASE(_attachedFiles);

    AGX_RELEASE(_completionHandlers);
    AGX_RELEASE(_uploadProgressChangedHandlers);
    AGX_RELEASE(_downloadProgressChangedHandlers);

    AGX_RELEASE(_stateHistory);

    AGX_RELEASE(_request);
    AGX_RELEASE(_multipartFormData);

    AGX_RELEASE(_downloadPath);

    AGX_SUPER_DEALLOC;
}

#pragma mark - Secure

- (BOOL)isSecureRequest {
    return([_urlString hasCaseInsensitivePrefix:@"https"] ||
           _username || _password || _clientCertificate || _clientCertificatePassword);
}

#pragma mark - Cache

- (BOOL)isCacheable {
    return(!(_cachePolicy & AGXCachePolicyDoNotCache) &&
           [_httpMethod isCaseInsensitiveEqualToString:@"GET"]);
}

- (NSString *)downloadPath {
    return _downloadPath ?: [NSString stringWithFormat:@"%ld", (unsigned long)self.hash];
}

#pragma mark - Request

- (NSURLRequest *)request {
    if (!_request) [self doBuild];
    return _request;
}

- (NSData *)multipartFormData {
    if (!_multipartFormData) [self doBuild];
    return _multipartFormData;
}

#pragma mark - Response

- (NSString *)responseDataAsString {
    NSString *string = [NSString stringWithData:_responseData encoding:NSUTF8StringEncoding];
    if (_responseData.length > 0 && !string) {
        string = [NSString stringWithData:_responseData encoding:NSASCIIStringEncoding];
    }
    return string;
}

- (id)responseDataAsJSON {
    return [_responseData agxJsonObject];
}

- (BOOL)errorResponding {
    return _error || !_response;
}

#pragma mark - Setting

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
    AGXHandler handler = AGX_BLOCK_COPY(completionHandler);
    [_completionHandlers addObject:handler];
    AGX_BLOCK_RELEASE(handler);
}

- (void)addUploadProgressChangedHandler:(AGXHandler)uploadProgressChangedHandler {
    AGXHandler handler = AGX_BLOCK_COPY(uploadProgressChangedHandler);
    [_uploadProgressChangedHandlers addObject:handler];
    AGX_BLOCK_RELEASE(handler);
}

- (void)addDownloadProgressChangedHandler:(AGXHandler)downloadProgressChangedHandler {
    AGXHandler handler = AGX_BLOCK_COPY(downloadProgressChangedHandler);
    [_downloadProgressChangedHandlers addObject:handler];
    AGX_BLOCK_RELEASE(handler);
}

#pragma mark - Operation

- (void)cancel {
    if (_state != AGXRequestStateStarted) return;
    [_sessionTask cancel];
    self.state = AGXRequestStateCancelled;
}

#pragma mark - private methods

- (void)setState:(AGXRequestState)state {
    _state = state;
    [_stateHistory addObject:@(state)];

    if (state == AGXRequestStateStarted) {
        [AGXNetworkResource addNetworkRequest:self];
        NSAssert(_sessionTask, @"Session Task missing");
        [_sessionTask resume];
        [self increaseRunningOperations];

    } else if (state == AGXRequestStateResponseAvailableFromCache ||
               state == AGXRequestStateStaleResponseAvailableFromCache) {
        [self doCompletionHandler];

    } else if (state == AGXRequestStateCompleted || state == AGXRequestStateError) {
        [self doCompletionHandler];
        [self decreaseRunningOperations];
        [AGXNetworkResource removeNetworkRequest:self];

    } else if (state == AGXRequestStateCancelled) {
        [self decreaseRunningOperations];
        [AGXNetworkResource removeNetworkRequest:self];
    }
}

- (void)doBuild {
    AGX_RELEASE(_request);
    AGX_RELEASE(_multipartFormData);
    _request = nil;
    _multipartFormData = nil;

    NSURL *url = nil;
    if (([_httpMethod isCaseInsensitiveEqualToString:@"GET"] ||
         [_httpMethod isCaseInsensitiveEqualToString:@"DELETE"] ||
         [_httpMethod isCaseInsensitiveEqualToString:@"HEAD"]) && (_params.count > 0)) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", _urlString,
                                    [NSString stringWithData:AGXHTTPBodyData(AGXDataEncodingURL, _params)
                                                    encoding:NSUTF8StringEncoding]]];
    } else url = [NSURL URLWithString:_urlString];

    if (!url) {
        NSAssert(@"Unable to create request %@ %@ with parameters %@", _httpMethod, _urlString, _params);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:_httpMethod];
    [request setAllHTTPHeaderFields:_headers];

    NSData *multipartFormData = AGXFormDataWithParamsAndFilesAndDatas(_params, _attachedFiles, _attachedDatas);
    if (multipartFormData) {
        [request setValue:[NSString stringWithFormat:@"multipart/form-data%@%@",
                           AGXContentTypeCharsetString(), AGXContentTypeBoundaryString()]
       forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu",
                           (unsigned long)[multipartFormData length]]
       forHTTPHeaderField:@"Content-Length"];
    } else {
        [request setValue:[NSString stringWithFormat:@"%@%@",
                           AGXContentTypeFormatString(_parameterEncoding), AGXContentTypeCharsetString()]
       forHTTPHeaderField:@"Content-Type"];
    }

    if (!([_httpMethod isCaseInsensitiveEqualToString:@"GET"] ||
          [_httpMethod isCaseInsensitiveEqualToString:@"DELETE"] ||
          [_httpMethod isCaseInsensitiveEqualToString:@"HEAD"])) {
        [request setHTTPBody:AGXHTTPBodyData(_parameterEncoding, _params)];
    }
    if (_bodyData) [request setHTTPBody:_bodyData];

    _request = AGX_RETAIN(request);
    _multipartFormData = AGX_RETAIN(multipartFormData);
}

- (void)doCompletionHandler {
    [_completionHandlers enumerateObjectsUsingBlock:
     ^(AGXHandler handler, NSUInteger idx, BOOL *stop) { handler(self); }];
}

- (void)doUploadProgressHandler {
    [_uploadProgressChangedHandlers enumerateObjectsUsingBlock:
     ^(AGXHandler handler, NSUInteger idx, BOOL *stop) { handler(self); }];
}

- (void)doDownloadProgressHandler {
    [_downloadProgressChangedHandlers enumerateObjectsUsingBlock:
     ^(AGXHandler handler, NSUInteger idx, BOOL *stop) { handler(self); }];
}

#pragma mark - NSObject

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
                                        [NSString stringWithDictionary:_params usingKeysComparator:
                                         ^NSComparisonResult(id  _Nonnull k1, id  _Nonnull k2) {
                                             return [k1 compare:k2 options:NSNumericSearch];
                                         } separator:@"&" keyValueSeparator:@"=" filterEmpty:NO],
                                        _username, _password,
                                        _clientCertificate,
                                        _clientCertificatePassword]
                      usingComparator:NULL separator:@" " filterEmpty:NO] hash];
}

- (NSString *)description {
    NSMutableString *displayString =
    [NSMutableString stringWithFormat:
     @"\n%@\n-------\nRequest\n%@\n--------\n",
     [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]],
     [self curlCommandLineString]];

    NSString *responseString = self.responseDataAsString;
    if ([responseString length] > 0) {
        [displayString appendFormat:
         @"Response\n%@\n--------\n",
         responseString];
    }

    if (self.error) {
        [displayString appendFormat:
         @"Error\n%@\n--------\n", self.error];
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

@end
