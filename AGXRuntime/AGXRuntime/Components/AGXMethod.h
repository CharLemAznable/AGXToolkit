//
//  AGXMethod.h
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXRuntime_AGXMethod_h
#define AGXRuntime_AGXMethod_h

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXMethod : NSObject
+ (AGX_INSTANCETYPE)methodWithObjCMethod:(Method)method;
+ (AGX_INSTANCETYPE)instanceMethodWithName:(NSString *)name inClass:(Class)cls;
+ (AGX_INSTANCETYPE)classMethodWithName:(NSString *)name inClass:(Class)cls;
+ (AGX_INSTANCETYPE)instanceMethodWithName:(NSString *)name inClassNamed:(NSString *)className;
+ (AGX_INSTANCETYPE)classMethodWithName:(NSString *)name inClassNamed:(NSString *)className;
+ (AGX_INSTANCETYPE)methodWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature;

- (AGX_INSTANCETYPE)initWithObjCMethod:(Method)method;
- (AGX_INSTANCETYPE)initInstanceMethodWithName:(NSString *)name inClass:(Class)cls;
- (AGX_INSTANCETYPE)initClassMethodWithName:(NSString *)name inClass:(Class)cls;
- (AGX_INSTANCETYPE)initInstanceMethodWithName:(NSString *)name inClassNamed:(NSString *)className;
- (AGX_INSTANCETYPE)initClassMethodWithName:(NSString *)name inClassNamed:(NSString *)className;
- (AGX_INSTANCETYPE)initWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature;

- (SEL)selector;
- (NSString *)selectorName;
- (IMP)implementation;
- (void)setImplementation:(IMP)imp;
- (NSString *)signature;
@end

#endif /* AGXRuntime_AGXMethod_h */
