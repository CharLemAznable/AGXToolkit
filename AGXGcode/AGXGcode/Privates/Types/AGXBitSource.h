//
//  AGXBitSource.h
//  AGXGcode
//
//  Created by Char Aznable on 16/8/8.
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

#ifndef AGXGcode_AGXBitSource_h
#define AGXGcode_AGXBitSource_h

#import "AGXByteArray.h"

@interface AGXBitSource : NSObject
@property (nonatomic, readonly) int bitOffset;
@property (nonatomic, readonly) int byteOffset;

+ (AGX_INSTANCETYPE)bitSourceWithBytes:(AGXByteArray *)bytes;
- (AGX_INSTANCETYPE)initWithBytes:(AGXByteArray *)bytes;
- (int)readBits:(int)numBits;
- (int)available;
@end

#endif /* AGXGcode_AGXBitSource_h */
