//
//  AGXDecodeHints.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
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

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import "AGXDecodeHints.h"

@implementation AGXDecodeHints

+ (AGX_INSTANCETYPE)hints {
    return AGX_AUTORELEASE([[self alloc] init]);
}

+ (AGX_INSTANCETYPE)hintsWithFormats:(NSArray *)formats {
    return AGX_AUTORELEASE([[self alloc] initWithFormats:formats]);
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _formats = [[NSArray alloc] init];
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithFormats:(NSArray *)formats {
    if AGX_EXPECT_T(self = [super init]) {
        _formats = [[NSArray arrayWithArray:formats] copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_formats);
    AGX_SUPER_DEALLOC;
}

- (id)copyWithZone:(NSZone *)zone {
    AGXDecodeHints *result = [[self.class allocWithZone:zone] init];
    if AGX_EXPECT_T(result) {
        result.encoding = _encoding;
        result.formats = AGX_AUTORELEASE([_formats deepCopy]);
    }
    return result;
}

- (BOOL)containsFormat:(AGXGcodeFormat)format {
    return [_formats containsObject:@(format)];
}

@end
