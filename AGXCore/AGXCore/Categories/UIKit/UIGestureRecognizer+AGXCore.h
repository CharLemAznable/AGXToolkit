//
//  UIGestureRecognizer+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2017/12/14.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UIGestureRecognizer_AGXCore_h
#define AGXCore_UIGestureRecognizer_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIGestureRecognizer, AGXCore)
@property (nonatomic, assign) NSUInteger agxTag;
@end

#endif /* AGXCore_UIGestureRecognizer_AGXCore_h */
