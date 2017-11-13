//
//  AGXQRCodeAlignmentPattern.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/5.
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

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import "AGXQRCodeAlignmentPattern.h"

@implementation AGXQRCodeAlignmentPattern {
    float _estimatedModuleSize;
}

+ (AGX_INSTANCETYPE)alignmentPatternWithX:(float)x y:(float)y estimatedModuleSize:(float)estimatedModuleSize {
    return AGX_AUTORELEASE([[self alloc] initWithX:x y:y estimatedModuleSize:estimatedModuleSize]);
}

- (AGX_INSTANCETYPE)initWithX:(float)x y:(float)y estimatedModuleSize:(float)estimatedModuleSize {
    if AGX_EXPECT_T(self = [super init]) {
        _point = CGPointMake(x, y);
        _estimatedModuleSize = estimatedModuleSize;
    }
    return self;
}

- (BOOL)aboutEquals:(float)moduleSize i:(float)i j:(float)j {
    if AGX_EXPECT_T(cgfabs(i - _point.y) <= moduleSize && cgfabs(j - _point.x) <= moduleSize) {
        float moduleSizeDiff = fabsf(moduleSize - _estimatedModuleSize);
        return moduleSizeDiff <= 1.0f || moduleSizeDiff <= _estimatedModuleSize;
    }
    return NO;
}

- (AGXQRCodeAlignmentPattern *)combineEstimateI:(float)i j:(float)j newModuleSize:(float)newModuleSize {
    float combinedX = (_point.x + j) / 2.0f;
    float combinedY = (_point.y + i) / 2.0f;
    float combinedModuleSize = (_estimatedModuleSize + newModuleSize) / 2.0f;
    return [AGXQRCodeAlignmentPattern alignmentPatternWithX:combinedX y:combinedY estimatedModuleSize:combinedModuleSize];
}

@end
