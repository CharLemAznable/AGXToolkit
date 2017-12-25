//
//  AGXPDF417BarcodeMetadata.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/2.
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

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXPDF417BarcodeMetadata.h"

@implementation AGXPDF417BarcodeMetadata

+ (AGX_INSTANCETYPE)barcodeMetadataWithColumnCount:(int)columnCount rowCountUpperPart:(int)rowCountUpperPart rowCountLowerPart:(int)rowCountLowerPart errorCorrectionLevel:(int)errorCorrectionLevel {
    return AGX_AUTORELEASE([[self alloc] initWithColumnCount:columnCount rowCountUpperPart:rowCountUpperPart rowCountLowerPart:rowCountLowerPart errorCorrectionLevel:errorCorrectionLevel]);
}

- (AGX_INSTANCETYPE)initWithColumnCount:(int)columnCount rowCountUpperPart:(int)rowCountUpperPart rowCountLowerPart:(int)rowCountLowerPart errorCorrectionLevel:(int)errorCorrectionLevel {
    if AGX_EXPECT_T(self = [super init]) {
        _columnCount = columnCount;
        _errorCorrectionLevel = errorCorrectionLevel;
        _rowCountUpperPart = rowCountUpperPart;
        _rowCountLowerPart = rowCountLowerPart;
        _rowCount = rowCountUpperPart + rowCountLowerPart;
    }
    return self;
}

@end
