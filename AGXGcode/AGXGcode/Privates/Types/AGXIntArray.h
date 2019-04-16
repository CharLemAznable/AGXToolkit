//
//  AGXIntArray.h
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

#ifndef AGXGcode_AGXIntArray_h
#define AGXGcode_AGXIntArray_h

#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXIntArray : NSObject <NSCopying>
@property (nonatomic, readonly) int32_t *array;
@property (nonatomic, readonly) unsigned int length;

+ (AGX_INSTANCETYPE)intArrayWithLength:(unsigned int)length;
+ (AGX_INSTANCETYPE)intArrayWithInts:(int32_t)int1, ...;
- (AGX_INSTANCETYPE)initWithLength:(unsigned int)length;
- (AGX_INSTANCETYPE)initWithInts:(int32_t)int1, ...;
- (void)clear;
- (int)sum;
@end

#endif /* AGXGcode_AGXIntArray_h */
