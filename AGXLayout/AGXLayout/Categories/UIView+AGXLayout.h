//
//  UIView+AGXLayout.h
//  AGXLayout
//
//  Created by Char Aznable on 16/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXLayout_UIView_AGXLayout_h
#define AGXLayout_UIView_AGXLayout_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@category_interface(UIView, AGXLayout)
- (UIView *(^)(UIView *))byView;
- (UIView *(^)(id))withLeft; // animatable.
- (UIView *(^)(id))withRight; // animatable.
- (UIView *(^)(id))withTop; // animatable.
- (UIView *(^)(id))withBottom; // animatable.
- (UIView *(^)(id))withWidth; // animatable.
- (UIView *(^)(id))withHeight; // animatable.
- (UIView *(^)(id))withCenterX; // animatable.
- (UIView *(^)(id))withCenterY; // animatable.
@end

#endif /* AGXLayout_UIView_AGXLayout_h */
