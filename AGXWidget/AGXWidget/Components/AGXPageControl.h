//
//  AGXPageControl.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXPageControl_h
#define AGXWidget_AGXPageControl_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXPageControl : UIPageControl
@property (nonatomic, AGX_STRONG) UIColor *pageIndicatorColor;
@property (nonatomic, AGX_STRONG) UIColor *currentPageIndicatorColor;
@end

#endif /* AGXWidget_AGXPageControl_h */
