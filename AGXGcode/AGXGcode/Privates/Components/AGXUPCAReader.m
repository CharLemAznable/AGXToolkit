//
//  AGXUPCAReader.m
//  AGXGcode
//
//  Created by Char Aznable on 16/7/26.
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
#import "AGXUPCAReader.h"
#import "AGXEAN13Reader.h"
#import "AGXGcodeError.h"

@implementation AGXUPCAReader {
    AGXEAN13Reader *_ean13Reader;
}

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _ean13Reader = [[AGXEAN13Reader alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_ean13Reader);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXGcodeResult *result = [_ean13Reader decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints error:error];
    if (result) {
        result = [self maybeReturnResult:result];
        if (!result) {
            if (error) *error = AGXFormatErrorInstance();
            return nil;
        }
        return result;
    } else {
        return nil;
    }
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXGcodeResult *result = [_ean13Reader decodeRow:rowNumber row:row hints:hints error:error];
    if (result) {
        result = [self maybeReturnResult:result];
        if (!result) {
            if (error) *error = AGXFormatErrorInstance();
            return nil;
        }
        return result;
    } else {
        return nil;
    }
}

- (AGXGcodeResult *)decode:(UIImage *)image hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXGcodeResult *result = [_ean13Reader decode:image hints:hints error:error];
    if (result) {
        result = [self maybeReturnResult:result];
        if (!result) {
            if (error) *error = AGXFormatErrorInstance();
            return nil;
        }
        return result;
    } else {
        return nil;
    }
}

- (AGXGcodeFormat)gcodeFormat {
    return kGcodeFormatUPCA;
}

- (int)decodeMiddle:(AGXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error {
    return [_ean13Reader decodeMiddle:row startRange:startRange result:result error:error];
}

- (AGXGcodeResult *)maybeReturnResult:(AGXGcodeResult *)result {
    NSString *text = result.text;
    if ([text characterAtIndex:0] == '0') {
        return [AGXGcodeResult resultWithText:[text substringFromIndex:1] format:kGcodeFormatUPCA];
    } else {
        return nil;
    }
}

@end
