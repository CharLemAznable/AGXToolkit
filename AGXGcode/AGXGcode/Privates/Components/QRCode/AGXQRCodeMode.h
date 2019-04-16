//
//  AGXQRCodeMode.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/8.
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

#ifndef AGXGcode_AGXQRCodeMode_h
#define AGXGcode_AGXQRCodeMode_h

#import "AGXQRCodeVersion.h"

@interface AGXQRCodeMode : NSObject
@property (nonatomic, readonly) int bits;
@property (nonatomic, readonly) NSString *name;

+ (AGX_INSTANCETYPE)forBits:(int)bits;
- (int)characterCountBits:(AGXQRCodeVersion *)version;

+ (AGX_INSTANCETYPE)terminatorMode; // Not really a mode...
+ (AGX_INSTANCETYPE)numericMode;
+ (AGX_INSTANCETYPE)alphanumericMode;
+ (AGX_INSTANCETYPE)structuredAppendMode; // Not supported
+ (AGX_INSTANCETYPE)byteMode;
+ (AGX_INSTANCETYPE)eciMode; // character counts don't apply
+ (AGX_INSTANCETYPE)kanjiMode;
+ (AGX_INSTANCETYPE)fnc1FirstPositionMode;
+ (AGX_INSTANCETYPE)fnc1SecondPositionMode;
+ (AGX_INSTANCETYPE)hanziMode; // See GBT 18284-2000; "Hanzi" is a transliteration of this mode name.
@end

#endif /* AGXGcode_AGXQRCodeMode_h */
