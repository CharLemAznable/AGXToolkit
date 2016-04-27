//
//  AGXNetworkResource.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXSingleton.h>

@singleton_interface(AGXNetworkResource, NSObject) <NSURLSessionDelegate>
@property (nonatomic, AGX_DISPATCH) dispatch_queue_t syncTasksQueue;
@property (nonatomic, AGX_STRONG)   NSMutableArray *activeTasks;

@property (nonatomic, readonly)     NSURLSession *defaultSession;
@property (nonatomic, readonly)     NSURLSession *ephemeralSession;
@property (nonatomic, readonly)     NSURLSession *backgroundSession;

+ (dispatch_queue_t)syncTasksQueue;
+ (NSMutableArray *)activeTasks;

+ (NSURLSession *)defaultSession;
+ (NSURLSession *)ephemeralSession;
+ (NSURLSession *)backgroundSession;
@end
