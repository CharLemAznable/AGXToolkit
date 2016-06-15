//
//  UIDevice+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIDevice_AGXCore_h
#define AGXCore_UIDevice_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIDevice, AGXCore)
+ (NSString *)fullModelString;
+ (NSString *)purifyModelString;
+ (NSString *)webkitVersionString;
- (NSString *)fullModelString;
- (NSString *)purifyModelString;
- (NSString *)webkitVersionString;
@end

#endif /* AGXCore_UIDevice_AGXCore_h */
