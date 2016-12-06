//
//  NSUUID+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 16/12/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_NSUUID_AGXWidget_h
#define AGXWidget_NSUUID_AGXWidget_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@interface NSUUID (AGXWidget)
+ (AGX_INSTANCETYPE)UUIDWithUUIDString:(NSString *)string;
+ (AGX_INSTANCETYPE)UUIDWithUUIDBytes:(const uuid_t)bytes;
@end

#endif /* AGXWidget_NSUUID_AGXWidget_h */
