//
//  AGXGcodeError.h
//  AGXGcode
//
//  Created by Char Aznable on 16/7/26.
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

#ifndef AGXGcode_AGXGcodeError_h
#define AGXGcode_AGXGcodeError_h

#import <Foundation/Foundation.h>

#define AGXGcodeErrorDomain @"AGXGcodeErrorDomain"

enum {
    AGXChecksumError    = 1000,
    AGXFormatError      = 1001,
    AGXNotFoundError    = 1002,
    AGXReedSolomonError = 1003,
    AGXReaderError      = 1004,
    AGXWriterError      = 1005
};

// Helper methods for error instances
NSError *AGXChecksumErrorInstance();
NSError *AGXFormatErrorInstance();
NSError *AGXNotFoundErrorInstance();

#endif /* AGXGcode_AGXGcodeError_h */
