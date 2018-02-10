//
//  AGXQRCodeDataMask.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/8.
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

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXQRCodeDataMask.h"

@interface AGXDataMask000 : AGXQRCodeDataMask
@end
@implementation AGXDataMask000
- (BOOL)isMasked:(int)i j:(int)j {
    return(((i + j) & 0x01) == 0);
}
@end

@interface AGXDataMask001 : AGXQRCodeDataMask
@end
@implementation AGXDataMask001
- (BOOL)isMasked:(int)i j:(int)j {
    return((i & 0x01) == 0);
}
@end

@interface AGXDataMask010 : AGXQRCodeDataMask
@end
@implementation AGXDataMask010
- (BOOL)isMasked:(int)i j:(int)j {
    return(j % 3 == 0);
}
@end

@interface AGXDataMask011 : AGXQRCodeDataMask
@end
@implementation AGXDataMask011
- (BOOL)isMasked:(int)i j:(int)j {
    return((i + j) % 3 == 0);
}
@end

@interface AGXDataMask100 : AGXQRCodeDataMask
@end
@implementation AGXDataMask100
- (BOOL)isMasked:(int)i j:(int)j {
    return((((i / 2) + (j /3)) & 0x01) == 0);
}
@end

@interface AGXDataMask101 : AGXQRCodeDataMask
@end
@implementation AGXDataMask101
- (BOOL)isMasked:(int)i j:(int)j {
    int temp = i * j;
    return((temp & 0x01) + (temp % 3) == 0);
}
@end

@interface AGXDataMask110 : AGXQRCodeDataMask
@end
@implementation AGXDataMask110
- (BOOL)isMasked:(int)i j:(int)j {
    int temp = i * j;
    return((((temp & 0x01) + (temp % 3)) & 0x01) == 0);
}
@end

@interface AGXDataMask111 : AGXQRCodeDataMask
@end
@implementation AGXDataMask111
- (BOOL)isMasked:(int)i j:(int)j {
    return(((((i + j) & 0x01) + ((i * j) % 3)) & 0x01) == 0);
}
@end

@implementation AGXQRCodeDataMask

static NSArray *DATA_MASKS = nil;

+ (AGX_INSTANCETYPE)forReference:(int)reference {
    if (!DATA_MASKS) {
        DATA_MASKS = [[NSArray alloc] initWithObjects:
                      AGXDataMask000.instance,
                      AGXDataMask001.instance,
                      AGXDataMask010.instance,
                      AGXDataMask011.instance,
                      AGXDataMask100.instance,
                      AGXDataMask101.instance,
                      AGXDataMask110.instance,
                      AGXDataMask111.instance, nil];
    }

    if AGX_EXPECT_F(reference < 0 || reference > 7)
        [NSException raise:NSInvalidArgumentException format:@"Invalid reference value"];
    return DATA_MASKS[reference];
}

- (void)unmaskBitMatrix:(AGXBitMatrix *)bits dimension:(int)dimension {
    for (int i = 0; i < dimension; i++) {
        for (int j = 0; j < dimension; j++) {
            if ([self isMasked:i j:j]) {
                [bits flipX:j y:i];
            }
        }
    }
}

- (BOOL)isMasked:(int)i j:(int)j {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
