//
//  AGXNetworkResource.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXNetworkResource_h
#define AGXNetwork_AGXNetworkResource_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXSingleton.h>
#import "AGXRequest.h"

@singleton_interface(AGXNetworkResource, NSObject) <NSURLSessionDelegate>
@property (nonatomic, readonly)     NSURLSession *defaultSession;
@property (nonatomic, readonly)     NSURLSession *ephemeralSession;
@property (nonatomic, readonly)     NSURLSession *backgroundSession;

+ (NSURLSession *)defaultSession;
+ (NSURLSession *)ephemeralSession;
+ (NSURLSession *)backgroundSession;

- (void)addNetworkRequest:(AGXRequest *)request;
- (void)removeNetworkRequest:(AGXRequest *)request;

+ (void)addNetworkRequest:(AGXRequest *)request;
+ (void)removeNetworkRequest:(AGXRequest *)request;
@end

#endif /* AGXNetwork_AGXNetworkResource_h */
