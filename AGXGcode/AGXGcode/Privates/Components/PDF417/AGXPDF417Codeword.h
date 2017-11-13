//
//  AGXPDF417Codeword.h
//  AGXGcode
//
//  Created by Char Aznable on 16/8/2.
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

#ifndef AGXGcode_AGXPDF417Codeword_h
#define AGXGcode_AGXPDF417Codeword_h

#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXPDF417Codeword : NSObject
@property (nonatomic, readonly) int startX;
@property (nonatomic, readonly) int endX;
@property (nonatomic, readonly) int bucket;
@property (nonatomic, readonly) int value;
@property (nonatomic)           int rowNumber;

+ (AGX_INSTANCETYPE)codewordWithStartX:(int)startX endX:(int)endX bucket:(int)bucket value:(int)value;
- (AGX_INSTANCETYPE)initWithStartX:(int)startX endX:(int)endX bucket:(int)bucket value:(int)value;
- (BOOL)hasValidRowNumber;
- (BOOL)isValidRowNumber:(int)rowNumber;
- (void)setRowNumberAsRowIndicatorColumn;
- (int)width;
@end

#endif /* AGXGcode_AGXPDF417Codeword_h */
