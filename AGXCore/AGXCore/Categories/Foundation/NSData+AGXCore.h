//
//  NSData+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSData_AGXCore_h
#define AGXCore_NSData_AGXCore_h

#import <Foundation/Foundation.h>
#import "AGXCategory.h"

@category_interface(NSData, AGXCore)
- (NSString *)base64EncodedString;
+ (NSData *)dataWithBase64String:(NSString *)base64String;
@end

#endif /* AGXCore_NSData_AGXCore_h */
