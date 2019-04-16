//
//  AGXReedSolomonDecoder.h
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

#ifndef AGXGcode_AGXReedSolomonDecoder_h
#define AGXGcode_AGXReedSolomonDecoder_h

#import "AGXIntArray.h"

@class AGXGenericGF, AGXGenericGFPoly;

@interface AGXReedSolomonDecoder : NSObject
+ (AGX_INSTANCETYPE)decoderWithField:(AGXGenericGF *)field;
- (AGX_INSTANCETYPE)initWithField:(AGXGenericGF *)field;
- (BOOL)decode:(AGXIntArray *)received twoS:(int)twoS error:(NSError **)error;
@end

@interface AGXGenericGF : NSObject
@property (nonatomic, readonly) AGXGenericGFPoly *zero;
@property (nonatomic, readonly) AGXGenericGFPoly *one;
@property (nonatomic, readonly) int32_t size;
@property (nonatomic, readonly) int32_t generatorBase;

+ (AGXGenericGF *)AztecData12;
+ (AGXGenericGF *)AztecData10;
+ (AGXGenericGF *)AztecData6;
+ (AGXGenericGF *)AztecParam;
+ (AGXGenericGF *)QrCodeField256;
+ (AGXGenericGF *)DataMatrixField256;
+ (AGXGenericGF *)AztecData8;
+ (AGXGenericGF *)MaxiCodeField64;
- (AGXGenericGFPoly *)buildMonomial:(int)degree coefficient:(int)coefficient;
+ (int32_t)addOrSubtract:(int32_t)a b:(int32_t)b;
- (int32_t)exp:(int)a;
- (int32_t)log:(int)a;
- (int32_t)inverse:(int)a;
- (int32_t)multiply:(int)a b:(int)b;
@end

@interface AGXGenericGFPoly : NSObject
@property (nonatomic, readonly) AGXIntArray *coefficients;

+ (AGX_INSTANCETYPE)polyWithField:(AGXGenericGF *)field coefficients:(AGXIntArray *)coefficients;
- (AGX_INSTANCETYPE)initWithField:(AGXGenericGF *)field coefficients:(AGXIntArray *)coefficients;
- (int)degree;
- (BOOL)zero;
- (int)coefficient:(int)degree;
- (int)evaluateAt:(int)a;
- (AGXGenericGFPoly *)addOrSubtract:(AGXGenericGFPoly *)other;
- (AGXGenericGFPoly *)multiply:(AGXGenericGFPoly *)other;
- (AGXGenericGFPoly *)multiplyScalar:(int)scalar;
- (AGXGenericGFPoly *)multiplyByMonomial:(int)degree coefficient:(int)coefficient;
- (NSArray *)divide:(AGXGenericGFPoly *)other;
@end

#endif /* AGXGcode_AGXReedSolomonDecoder_h */
