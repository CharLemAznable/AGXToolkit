//
//  AGXNetworkDelegate.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXNetworkDelegate_h
#define AGXNetwork_AGXNetworkDelegate_h

#import <UIKit/UIKit.h>

@protocol AGXNetworkDelegate <UIApplicationDelegate>
@optional
- (void)application:(UIApplication *)application defaultSessionConfiguration:(NSURLSessionConfiguration *)configuration;
- (void)application:(UIApplication *)application ephemeralSessionConfiguration:(NSURLSessionConfiguration *)configuration;
- (void)application:(UIApplication *)application backgroundSessionConfiguration:(NSURLSessionConfiguration *)configuration;
@end

#endif /* AGXNetwork_AGXNetworkDelegate_h */
