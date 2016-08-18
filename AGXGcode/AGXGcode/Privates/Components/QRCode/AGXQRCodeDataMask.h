//
//  AGXQRCodeDataMask.h
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

#ifndef AGXGcode_AGXQRCodeDataMask_h
#define AGXGcode_AGXQRCodeDataMask_h

#import "AGXBitMatrix.h"

@interface AGXQRCodeDataMask : NSObject
+ (AGX_INSTANCETYPE)forReference:(int)reference;
- (void)unmaskBitMatrix:(AGXBitMatrix *)bits dimension:(int)dimension;
- (BOOL)isMasked:(int)i j:(int)j;
@end

#endif /* AGXGcode_AGXQRCodeDataMask_h */