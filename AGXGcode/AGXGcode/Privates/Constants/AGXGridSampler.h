//
//  AGXGridSampler.h
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

#ifndef AGXGcode_AGXGridSampler_h
#define AGXGcode_AGXGridSampler_h

#import <AGXCore/AGXCore/AGXSingleton.h>
#import "AGXBitMatrix.h"
#import "AGXPerspectiveTransform.h"

@singleton_interface(AGXGridSampler, NSObject)
- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY error:(NSError **)error;
- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(AGXPerspectiveTransform *)transform error:(NSError **)error;
@end

#endif /* AGXGcode_AGXGridSampler_h */
