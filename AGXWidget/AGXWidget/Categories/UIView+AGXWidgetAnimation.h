//
//  UIView+AGXWidgetAnimation.h
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_UIView_AGXWidgetAnimation_h
#define AGXWidget_UIView_AGXWidgetAnimation_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimation.h"

@category_interface(UIView, AGXWidgetAnimation)
- (void)agxAnimate:(AGXAnimation)animation;
- (void)agxAnimate:(AGXAnimation)animation completion:(void (^)())completion;
@end

#endif /* AGXWidget_UIView_AGXWidgetAnimation_h */
