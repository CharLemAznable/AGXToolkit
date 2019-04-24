//
//  AGXProgressBar.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/10.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

//
//  Modify from:
//  ninjinkun/NJKWebViewProgress
//

//  The MIT License (MIT)
//
//  Copyright (c) 2013 Satoshi Asano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#ifndef AGXWidget_AGXProgressBar_h
#define AGXWidget_AGXProgressBar_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXProgressBar : UIView
@property (nonatomic, AGX_STRONG)   UIColor        *progressColor UI_APPEARANCE_SELECTOR; // default 167efb
+ (UIColor *)progressColor;
+ (void)setProgressColor:(UIColor *)progressColor;

@property (nonatomic, assign)       NSTimeInterval  progressDuration; // default 0.3
@property (nonatomic, assign)       NSTimeInterval  fadingDuration; // default 0.3
@property (nonatomic, assign)       NSTimeInterval  fadeDelay; // default 0.1

@property (nonatomic, assign)       float           progress; // 0.0..1.0
- (void)setProgress:(float)progress animated:(BOOL)animated;
@end

#endif /* AGXWidget_AGXProgressBar_h */
