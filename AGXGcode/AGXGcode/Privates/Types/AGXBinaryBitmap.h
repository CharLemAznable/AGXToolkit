//
//  AGXBinaryBitmap.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
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

#ifndef AGXGcode_AGXBinaryBitmap_h
#define AGXGcode_AGXBinaryBitmap_h

#import "AGXBinarizer.h"

@interface AGXBinaryBitmap : NSObject
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

+ (AGX_INSTANCETYPE)binaryBitmapWithBinarizer:(AGXBinarizer *)binarizer;
- (AGX_INSTANCETYPE)initWithBinarizer:(AGXBinarizer *)binarizer;
- (AGXBitArray *)blackRow:(int)y row:(AGXBitArray *)row error:(NSError **)error;
- (AGXBitMatrix *)blackMatrixWithError:(NSError **)error;
- (AGXBinaryBitmap *)crop:(int)left top:(int)top width:(int)width height:(int)height;
- (AGXBinaryBitmap *)rotateCounterClockwise;
@end

#endif /* AGXGcode_AGXBinaryBitmap_h */
