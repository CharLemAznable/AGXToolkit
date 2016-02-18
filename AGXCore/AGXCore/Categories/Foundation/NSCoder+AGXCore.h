//
//  NSCoder+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSCoder_AGXCore_h
#define AGXCore_NSCoder_AGXCore_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AGXCategory.h"

@category_interface(NSCoder, AGXCore)
- (void)encodeCGFloat:(CGFloat)realv forKey:(NSString *)key;
- (CGFloat)decodeCGFloatForKey:(NSString *)key;
@end

#endif /* AGXCore_NSCoder_AGXCore_h */
