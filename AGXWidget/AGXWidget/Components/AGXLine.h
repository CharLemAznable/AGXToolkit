//
//  AGXLine.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/4/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  SSLineView(SSToolkit)
//

//  Copyright (c) 2008-2014 Sam Soffes
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
