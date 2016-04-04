//
//  AGXLine.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Rename from:
//  SSLineView.h
//  SSToolkit
//  Created by Sam Soffes on 4/12/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#ifndef AGXWidget_AGXLine_h
#define AGXWidget_AGXLine_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXGeometry.h>

@interface AGXLine : UIView
@property (nonatomic, AGX_STRONG)   UIColor         *lineColor; // default gray
@property (nonatomic, assign)       AGXDirection     lineDirection; // default AGXDirectionEast
@property (nonatomic, assign)       NSUInteger       lineWidth; // pixel, default 1
@property (nonatomic, assign)       BOOL             ceilAdjust; // ceil adjust Quartz point value, default NO(floor adjust)
@property (nonatomic, assign)       CGFloat          dashPhase;
@property (nonatomic, copy)         NSArray         *dashLengths;
@end

#endif /* AGXWidget_AGXLine_h */
