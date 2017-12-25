//
//  AGXQRCodeFormatInformation.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/5.
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

#ifndef AGXGcode_AGXQRCodeFormatInformation_h
#define AGXGcode_AGXQRCodeFormatInformation_h

#import "AGXQRCodeErrorCorrectionLevel.h"

@interface AGXQRCodeFormatInformation : NSObject
@property (nonatomic, readonly) AGXQRCodeErrorCorrectionLevel *errorCorrectionLevel;
@property (nonatomic, readonly) int8_t dataMask;

+ (int)numBitsDiffering:(int)a b:(int)b;

/**
 * @param maskedFormatInfo1 format info indicator, with mask still applied
 * @param maskedFormatInfo2 second copy of same info; both are checked at the same time
 *  to establish best match
 * @return information about the format it specifies, or {@code null}
 *  if doesn't seem to match any known pattern
 */
+ (AGX_INSTANCETYPE)decodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2;
@end

#endif /* AGXGcode_AGXQRCodeFormatInformation_h */
