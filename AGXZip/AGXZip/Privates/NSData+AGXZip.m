//
//  NSData+AGXZip.m
//  AGXZip
//
//  Created by Char Aznable on 2018/5/12.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "NSData+AGXZip.h"

@category_implementation(NSData, AGXZip)

- (NSString *)hexadedimalString {
    NSMutableString *string = [NSMutableString string];
    const unsigned char *bytes = self.bytes;
    NSUInteger length = self.length;
    for (NSUInteger i = 0; i < length; i++) {
        [string appendFormat:@"%02x", bytes[i]];
    }
    return AGX_AUTORELEASE([string copy]);
}

@end
