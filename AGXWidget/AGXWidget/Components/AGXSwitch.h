//
//  AGXSwitch.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/6/13.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXSwitch_h
#define AGXWidget_AGXSwitch_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXSwitch : UIControl
@property (nonatomic)             CGFloat slideHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic)             CGFloat thumbRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, AGX_STRONG) UIColor *onColor    UI_APPEARANCE_SELECTOR; // default 4cd864
@property (nonatomic, AGX_STRONG) UIColor *offColor   UI_APPEARANCE_SELECTOR; // default e4e4e4
@property (nonatomic, AGX_STRONG) UIColor *thumbColor UI_APPEARANCE_SELECTOR; // default white

@property (nonatomic, assign, getter=isOn) BOOL on;
- (void)setOn:(BOOL)on animated:(BOOL)animated;
@end

#endif /* AGXWidget_AGXSwitch_h */
