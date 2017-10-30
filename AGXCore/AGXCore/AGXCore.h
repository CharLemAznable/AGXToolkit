//
//  AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_h
#define AGXCore_h

#import <math.h>
#import <time.h>
#import <xlocale.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <UserNotifications/UserNotifications.h>

#define AGXToolkitVersionNumber 300
#define AGXToolkitVersionString "0.3.0"

FOUNDATION_EXPORT const long AGXCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char AGXCoreVersionString[];

#import "AGXCore/AGXC.h"
#import "AGXCore/AGXObjC.h"
#import "AGXCore/AGXArc.h"
#import "AGXCore/AGXAdapt.h"

#import "AGXCore/AGXCategory.h"
#import "AGXCore/AGXSingleton.h"
#import "AGXCore/AGXYCombinator.h"
#import "AGXCore/AGXMath.h"
#import "AGXCore/AGXGeometry.h"
#import "AGXCore/AGXDirectory.h"
#import "AGXCore/AGXBundle.h"
#import "AGXCore/AGXColorSet.h"
#import "AGXCore/AGXRandom.h"

#import "AGXCore/NSObject+AGXCore.h"
#import "AGXCore/NSNull+AGXCore.h"
#import "AGXCore/NSNumber+AGXCore.h"
#import "AGXCore/NSCoder+AGXCore.h"
#import "AGXCore/NSData+AGXCore.h"
#import "AGXCore/NSString+AGXCore.h"
#import "AGXCore/NSValue+AGXCore.h"
#import "AGXCore/NSArray+AGXCore.h"
#import "AGXCore/NSDictionary+AGXCore.h"
#import "AGXCore/NSExpression+AGXCore.h"
#import "AGXCore/NSDate+AGXCore.h"
#import "AGXCore/NSURLRequest+AGXCore.h"
#import "AGXCore/NSError+AGXCore.h"

#import "AGXCore/UIDevice+AGXCore.h"
#import "AGXCore/UIApplication+AGXCore.h"
#import "AGXCore/UIView+AGXCore.h"
#import "AGXCore/UIControl+AGXCore.h"
#import "AGXCore/UIButton+AGXCore.h"
#import "AGXCore/UILabel+AGXCore.h"
#import "AGXCore/UIImage+AGXCore.h"
#import "AGXCore/UIImageView+AGXCore.h"
#import "AGXCore/UITextField+AGXCore.h"
#import "AGXCore/UITextView+AGXCore.h"
#import "AGXCore/UIColor+AGXCore.h"
#import "AGXCore/UINavigationBar+AGXCore.h"
#import "AGXCore/UITabBar+AGXCore.h"
#import "AGXCore/UINavigationItem+AGXCore.h"
#import "AGXCore/UIBarItem+AGXCore.h"
#import "AGXCore/UIBarButtonItem+AGXCore.h"
#import "AGXCore/UITabBarItem+AGXCore.h"
#import "AGXCore/UIActionSheet+AGXCore.h"
#import "AGXCore/UIAlertView+AGXCore.h"
#import "AGXCore/UIViewController+AGXCore.h"
#import "AGXCore/UIWebView+AGXCore.h"
#import "AGXCore/UIImagePickerController+AGXCore.h"

#endif /* AGXCore_h */
