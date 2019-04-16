//
//  AGXQRCodeAlignmentPattern.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/5.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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

#ifndef AGXGcode_AGXQRCodeAlignmentPattern_h
#define AGXGcode_AGXQRCodeAlignmentPattern_h

#import <CoreGraphics/CGGeometry.h>
#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXQRCodeAlignmentPattern : NSObject
@property (nonatomic, readonly) CGPoint point;

+ (AGX_INSTANCETYPE)alignmentPatternWithX:(float)x y:(float)y estimatedModuleSize:(float)estimatedModuleSize;
- (AGX_INSTANCETYPE)initWithX:(float)x y:(float)y estimatedModuleSize:(float)estimatedModuleSize;
- (BOOL)aboutEquals:(float)moduleSize i:(float)i j:(float)j;
- (AGXQRCodeAlignmentPattern *)combineEstimateI:(float)i j:(float)j newModuleSize:(float)newModuleSize;
@end

#endif /* AGXGcode_AGXQRCodeAlignmentPattern_h */
