//
//  UIView+AGXLayout.h
//  AGXLayout
//
//  Created by Char Aznable on 2016/2/21.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXLayout_UIView_AGXLayout_h
#define AGXLayout_UIView_AGXLayout_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@category_interface(UIView, AGXLayout)
- (UIView *(^)(UIView *))viewAs;
- (UIView *(^)(id))leftAs; // animatable.
- (UIView *(^)(id))rightAs; // animatable.
- (UIView *(^)(id))topAs; // animatable.
- (UIView *(^)(id))bottomAs; // animatable.
- (UIView *(^)(id))widthAs; // animatable.
- (UIView *(^)(id))heightAs; // animatable.
- (UIView *(^)(id))centerXAs; // animatable.
- (UIView *(^)(id))centerYAs; // animatable.
@end

#endif /* AGXLayout_UIView_AGXLayout_h */
