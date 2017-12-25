//
//  AGXPDF417BoundingBox.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/2.
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

#ifndef AGXGcode_AGXPDF417BoundingBox_h
#define AGXGcode_AGXPDF417BoundingBox_h

#import "AGXBitMatrix.h"

@interface AGXPDF417BoundingBox : NSObject
@property (nonatomic, readonly) int minX;
@property (nonatomic, readonly) int maxX;
@property (nonatomic, readonly) int minY;
@property (nonatomic, readonly) int maxY;
@property (nonatomic, readonly) NSValue *topLeft;
@property (nonatomic, readonly) NSValue *topRight;
@property (nonatomic, readonly) NSValue *bottomLeft;
@property (nonatomic, readonly) NSValue *bottomRight;

+ (AGX_INSTANCETYPE)boundingBoxWithImage:(AGXBitMatrix *)image topLeft:(NSValue *)topLeft bottomLeft:(NSValue *)bottomLeft topRight:(NSValue *)topRight bottomRight:(NSValue *)bottomRight;
+ (AGX_INSTANCETYPE)boundingBoxWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox;
+ (AGXPDF417BoundingBox *)mergeLeftBox:(AGXPDF417BoundingBox *)leftBox rightBox:(AGXPDF417BoundingBox *)rightBox;
- (AGXPDF417BoundingBox *)addMissingRows:(int)missingStartRows missingEndRows:(int)missingEndRows isLeft:(BOOL)isLeft;
@end

#endif /* AGXGcode_AGXPDF417BoundingBox_h */
