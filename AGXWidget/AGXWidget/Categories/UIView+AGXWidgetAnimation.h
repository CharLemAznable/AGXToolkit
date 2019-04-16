//
//  UIView+AGXWidgetAnimation.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/29.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_UIView_AGXWidgetAnimation_h
#define AGXWidget_UIView_AGXWidgetAnimation_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimation.h"

@category_interface(UIView, AGXWidgetAnimation)
- (void)agxAnimate:(AGXAnimation)animation;
- (void)agxAnimate:(AGXAnimation)animation completion:(void (^)(void))completion;
@end

#endif /* AGXWidget_UIView_AGXWidgetAnimation_h */
