//
//  AGXMethod.h
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  NextThought/MAObjCRuntime
//

//  MAObjCRuntime and all code associated with it is distributed under a BSD license, as listed below.
//
//
//  Copyright (c) 2010, Michael Ash
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef AGXRuntime_AGXMethod_h
#define AGXRuntime_AGXMethod_h

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
- (NSString *)purifiedSignature;
@end

#endif /* AGXRuntime_AGXMethod_h */
