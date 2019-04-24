//
//  UIDevice+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UIDevice_AGXCore_h
#define AGXCore_UIDevice_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIDevice, AGXCore)
+ (NSString *)completeModelString;
+ (NSString *)purifiedModelString;
+ (NSString *)webkitVersionString;
- (NSString *)completeModelString;
- (NSString *)purifiedModelString;
- (NSString *)webkitVersionString;
@end

#endif /* AGXCore_UIDevice_AGXCore_h */
