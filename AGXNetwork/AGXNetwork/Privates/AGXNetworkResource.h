//
//  AGXNetworkResource.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/26.
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

#ifndef AGXNetwork_AGXNetworkResource_h
#define AGXNetwork_AGXNetworkResource_h

#import <AGXCore/AGXCore/AGXSingleton.h>
#import "AGXRequest.h"

@singleton_interface(AGXNetworkResource, NSObject, shareNetwork) <NSURLSessionDelegate>
@property (nonatomic, readonly)     NSURLSession *defaultSession;
@property (nonatomic, readonly)     NSURLSession *ephemeralSession;
@property (nonatomic, readonly)     NSURLSession *backgroundSession;
@property (nonatomic, copy)         void (^backgroundSessionCompletionHandler)(void);

+ (NSURLSession *)defaultSession;
+ (NSURLSession *)ephemeralSession;
+ (NSURLSession *)backgroundSession;
+ (void (^)(void))backgroundSessionCompletionHandler;
+ (void)setBackgroundSessionCompletionHandler:(void (^)(void))backgroundSessionCompletionHandler;

- (void)addNetworkRequest:(AGXRequest *)request;
- (void)removeNetworkRequest:(AGXRequest *)request;
+ (void)addNetworkRequest:(AGXRequest *)request;
+ (void)removeNetworkRequest:(AGXRequest *)request;
@end

#endif /* AGXNetwork_AGXNetworkResource_h */
