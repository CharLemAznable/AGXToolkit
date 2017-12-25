//
//  AGXLuminanceSource.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#ifndef AGXGcode_AGXLuminanceSource_h
#define AGXGcode_AGXLuminanceSource_h

#import <CoreGraphics/CoreGraphics.h>
#import "AGXByteArray.h"

@interface AGXLuminanceSource : NSObject
@property (nonatomic, readonly) CGImageRef image;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

+ (AGX_INSTANCETYPE)luminanceSourceWithCGImage:(CGImageRef)image;
+ (AGX_INSTANCETYPE)luminanceSourceWithCGImage:(CGImageRef)image left:(size_t)left top:(size_t)top width:(size_t)width height:(size_t)height;
- (AGX_INSTANCETYPE)initWithCGImage:(CGImageRef)image;
- (AGX_INSTANCETYPE)initWithCGImage:(CGImageRef)image left:(size_t)left top:(size_t)top width:(size_t)width height:(size_t)height;
- (AGXByteArray *)rowAtY:(int)y row:(AGXByteArray *)row;
- (AGXByteArray *)matrix;
- (AGXLuminanceSource *)invert;
- (AGXLuminanceSource *)crop:(int)left top:(int)top width:(int)width height:(int)height;
- (AGXLuminanceSource *)rotateCounterClockwise;
@end

#endif /* AGXGcode_AGXLuminanceSource_h */
