//
//  AGXQRCodeErrorCorrectionLevel.h
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

#ifndef AGXGcode_AGXQRCodeErrorCorrectionLevel_h
#define AGXGcode_AGXQRCodeErrorCorrectionLevel_h

#import <AGXCore/AGXCore/AGXObjC.h>

/**
 * See ISO 18004:2006, 6.5.1. This enum encapsulates the four error correction levels
 * defined by the QR code standard.
 */
@interface AGXQRCodeErrorCorrectionLevel : NSObject
@property (nonatomic, readonly) int ordinal;
@property (nonatomic, readonly) int bits;
@property (nonatomic, readonly) NSString *name;

- (AGX_INSTANCETYPE)initWithOrdinal:(int)ordinal bits:(int)bits name:(NSString *)name;

/**
 * @param bits int containing the two bits encoding a QR Code's error correction level
 * @return ErrorCorrectionLevel representing the encoded error correction level
 */
+ (AGX_INSTANCETYPE)forBits:(int)bits;

/**
 * L = ~7% correction
 */
+ (AGX_INSTANCETYPE)errorCorrectionLevelL;

/**
 * M = ~15% correction
 */
+ (AGX_INSTANCETYPE)errorCorrectionLevelM;

/**
 * Q = ~25% correction
 */
+ (AGX_INSTANCETYPE)errorCorrectionLevelQ;

/**
 * H = ~30% correction
 */
+ (AGX_INSTANCETYPE)errorCorrectionLevelH;
@end

#endif /* AGXGcode_AGXQRCodeErrorCorrectionLevel_h */
