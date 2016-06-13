//
//  AGXProtocol.h
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXRuntime_AGXProtocol_h
#define AGXRuntime_AGXProtocol_h

#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXProtocol : NSObject
+ (NSArray *)allProtocols;

+ (AGX_INSTANCETYPE)protocolWithObjCProtocol:(Protocol *)protocol;
+ (AGX_INSTANCETYPE)protocolWithName:(NSString *)name;

- (AGX_INSTANCETYPE)initWithObjCProtocol:(Protocol *)protocol;
- (AGX_INSTANCETYPE)initWithName:(NSString *)name;

- (Protocol *)objCProtocol;
- (NSString *)name;
- (NSArray *)incorporatedProtocols;
- (NSArray *)methodsRequired:(BOOL)isRequiredMethod instance:(BOOL)isInstanceMethod;
@end

#endif /* AGXRuntime_AGXProtocol_h */
