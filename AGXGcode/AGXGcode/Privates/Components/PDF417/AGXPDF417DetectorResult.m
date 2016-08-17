//
//  AGXPDF417DetectorResult.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/2.
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
#import "AGXPDF417DetectorResult.h"

@implementation AGXPDF417DetectorResult

+ (AGX_INSTANCETYPE)resultWithBits:(AGXBitMatrix *)bits points:(NSArray *)points {
    return AGX_AUTORELEASE([[self alloc] initWithBits:bits points:points]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits points:(NSArray *)points {
    if (self = [super init]) {
        _bits = AGX_RETAIN(bits);
        _points = AGX_RETAIN(points);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bits);
    AGX_RELEASE(_points);
    AGX_SUPER_DEALLOC;
}

@end
