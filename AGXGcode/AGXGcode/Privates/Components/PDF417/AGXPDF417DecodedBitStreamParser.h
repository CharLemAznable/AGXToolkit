//
//  AGXPDF417DecodedBitStreamParser.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/3.
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

#ifndef AGXGcode_AGXPDF417DecodedBitStreamParser_h
#define AGXGcode_AGXPDF417DecodedBitStreamParser_h

#import "AGXDecoderResult.h"
#import "AGXIntArray.h"

@interface AGXPDF417DecodedBitStreamParser : NSObject
+ (AGXDecoderResult *)decode:(AGXIntArray *)codewords ecLevel:(NSString *)ecLevel error:(NSError **)error;
@end

#endif /* AGXGcode_AGXPDF417DecodedBitStreamParser_h */
