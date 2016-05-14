//
//  AGXBundle.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXBundle_h
#define AGXCore_AGXBundle_h

#import <UIKit/UIKit.h>

@interface AGXBundle : NSObject
+ (AGXBundle *)appBundle;
+ (AGXBundle *(^)(NSString *))bundleNamed;

- (AGXBundle *(^)(NSString *))subpath;

- (NSString *(^)(NSString *, NSString *))filePath;
- (NSURL *(^)(NSString *, NSString *))fileURL;
- (UIImage *(^)(NSString *))imageNamed;

+ (NSString *)appIdentifier;
+ (NSString *)appVersion;
+ (BOOL)viewControllerBasedStatusBarAppearance;
@end

#endif /* AGXCore_AGXBundle_h */
