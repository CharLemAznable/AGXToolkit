//
//  AGXDataMatrixBitMatrixParser.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/10.
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

#ifndef AGXGcode_AGXDataMatrixBitMatrixParser_h
#define AGXGcode_AGXDataMatrixBitMatrixParser_h

#import "AGXBitMatrix.h"
#import "AGXDataMatrixVersion.h"

@interface AGXDataMatrixBitMatrixParser : NSObject
@property (nonatomic, readonly) AGXDataMatrixVersion *version;

+ (AGX_INSTANCETYPE)parserWithBitMatrix:(AGXBitMatrix *)bitMatrix error:(NSError **)error;
- (AGXByteArray *)readCodewords;
@end

#endif /* AGXGcode_AGXDataMatrixBitMatrixParser_h */
