//
//  AGXProgressBar.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXProgressBar_h
#define AGXWidget_AGXProgressBar_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXProgressBar : UIView
@property (nonatomic, AGX_STRONG)   UIColor        *tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign)       NSTimeInterval  progressDuration; // default 0.3
@property (nonatomic, assign)       NSTimeInterval  fadingDuration; // default 0.3
@property (nonatomic, assign)       NSTimeInterval  fadeDelay; // default 0.1

@property (nonatomic, assign)       float           progress;
- (void)setProgress:(float)progress animated:(BOOL)animated;
@end

#endif /* AGXWidget_AGXProgressBar_h */
