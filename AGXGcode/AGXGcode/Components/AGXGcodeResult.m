//
//  AGXGcodeResult.m
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

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXGcodeResult.h"

@implementation AGXGcodeResult

+ (AGX_INSTANCETYPE)gcodeResultWithText:(NSString *)text format:(AGXGcodeFormat)format {
    return AGX_AUTORELEASE([[self alloc] initWithText:text format:format]);
}

- (AGX_INSTANCETYPE)initWithText:(NSString *)text format:(AGXGcodeFormat)format {
    if AGX_EXPECT_T(self = [super init]) {
        _text = [text copy];
        _format = format;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_text);
    AGX_SUPER_DEALLOC;
}

- (NSString *)description {
    return _text;
}

@end
