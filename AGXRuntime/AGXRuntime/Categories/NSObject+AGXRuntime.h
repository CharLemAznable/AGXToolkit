//
//  NSObject+AGXRuntime.h
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXRuntime_NSObject_AGXRuntime_h
#define AGXRuntime_NSObject_AGXRuntime_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCategory.h>

@class AGXProtocol;
@class AGXIvar;
@class AGXProperty;
@class AGXMethod;

@category_interface(NSObject, AGXRuntime)
+ (NSArray *)zuxProtocols;
+ (void)enumerateAGXProtocolsWithBlock:(void (^)(AGXProtocol *protocol))block;
- (void)enumerateAGXProtocolsWithBlock:(void (^)(id object, AGXProtocol *protocol))block;

+ (NSArray *)zuxIvars;
+ (AGXIvar *)zuxIvarForName:(NSString *)name;
+ (void)enumerateAGXIvarsWithBlock:(void (^)(AGXIvar *ivar))block;
- (void)enumerateAGXIvarsWithBlock:(void (^)(id object, AGXIvar *ivar))block;

+ (NSArray *)zuxProperties;
+ (AGXProperty *)zuxPropertyForName:(NSString *)name;
+ (void)enumerateAGXPropertiesWithBlock:(void (^)(AGXProperty *property))block;
- (void)enumerateAGXPropertiesWithBlock:(void (^)(id object, AGXProperty *property))block;

+ (NSArray *)zuxMethods;
+ (AGXMethod *)zuxInstanceMethodForName:(NSString *)name;
+ (AGXMethod *)zuxClassMethodForName:(NSString *)name;
+ (void)enumerateAGXMethodsWithBlock:(void (^)(AGXMethod *method))block;
- (void)enumerateAGXMethodsWithBlock:(void (^)(id object, AGXMethod *method))block;
@end

#endif /* AGXRuntime_NSObject_AGXRuntime_h */
