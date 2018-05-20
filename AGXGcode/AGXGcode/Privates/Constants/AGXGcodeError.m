//
//  AGXGcodeError.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
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

#import "AGXGcodeError.h"

NSError *AGXChecksumErrorInstance() {
    return [NSError errorWithDomain:AGXGcodeErrorDomain code:AGXChecksumError
                           userInfo:@{NSLocalizedDescriptionKey: @"This barcode failed its checksum"}];
}

NSError *AGXFormatErrorInstance() {
    return [NSError errorWithDomain:AGXGcodeErrorDomain code:AGXFormatError
                           userInfo:@{NSLocalizedDescriptionKey: @"This barcode does not confirm to the format's rules"}];
}

NSError *AGXNotFoundErrorInstance() {
    return [NSError errorWithDomain:AGXGcodeErrorDomain code:AGXNotFoundError
                           userInfo:@{NSLocalizedDescriptionKey: @"A barcode was not found in this image"}];
}
