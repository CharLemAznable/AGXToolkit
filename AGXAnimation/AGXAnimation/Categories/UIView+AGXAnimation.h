//
//  UIView+AGXAnimation.h
//  AGXAnimation
//
//  Created by Char Aznable on 16/2/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXAnimation_UIView_AGXAnimation_h
#define AGXAnimation_UIView_AGXAnimation_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimationTypes.h"

@category_interface(UIView, AGXAnimation)
- (void)agxAnimate:(AGXAnimation)animation;
- (void)agxAnimate:(AGXAnimation)animation completion:(void (^)())completion;
@end

#endif /* AGXAnimation_UIView_AGXAnimation_h */
