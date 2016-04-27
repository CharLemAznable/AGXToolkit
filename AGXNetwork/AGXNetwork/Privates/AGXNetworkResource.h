//
//  AGXNetworkResource.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXSingleton.h>

@class AGXRequest;

@singleton_interface(AGXNetworkResource, NSObject) <NSURLSessionDelegate>
@property (nonatomic, readonly)     NSURLSession *defaultSession;
@property (nonatomic, readonly)     NSURLSession *ephemeralSession;
@property (nonatomic, readonly)     NSURLSession *backgroundSession;

+ (NSURLSession *)defaultSession;
+ (NSURLSession *)ephemeralSession;
+ (NSURLSession *)backgroundSession;

- (void)addTask:(AGXRequest *)request;
- (void)removeTask:(AGXRequest *)request;

+ (void)addTask:(AGXRequest *)request;
+ (void)removeTask:(AGXRequest *)request;
@end
