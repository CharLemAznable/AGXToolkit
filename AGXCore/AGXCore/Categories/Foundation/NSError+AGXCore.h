//
//  NSError+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 17/9/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSError_AGXCore_h
#define AGXCore_NSError_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSError, AGXCore)
+ (AGX_INSTANCETYPE)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(3,4);
+ (BOOL)fillError:(NSError **)error withDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(4,5);
+ (BOOL)clearError:(NSError **)error;
@end

#endif /* AGXCore_NSError_AGXCore_h */
