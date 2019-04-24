//
//  AGXProtocol.m
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXProtocol.h"
#import "AGXMethod.h"

@interface AGXProtocolInternal : AGXProtocol {
    Protocol *_protocol;
}
@end

#pragma mark - Implementation -

@implementation AGXProtocol

+ (NSArray *)allProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = objc_copyProtocolList(&count);

    NSMutableArray *array = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++)
        [array addObject:[self protocolWithObjCProtocol:protocols[i]]];

    free(protocols);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGX_INSTANCETYPE)protocolWithObjCProtocol:(Protocol *)protocol {
    return AGX_AUTORELEASE([[self alloc] initWithObjCProtocol:protocol]);
}

+ (AGX_INSTANCETYPE)protocolWithName:(NSString *)name {
    return AGX_AUTORELEASE([[self alloc] initWithName:name]);
}

- (AGX_INSTANCETYPE)initWithObjCProtocol:(Protocol *)protocol {
    AGX_RELEASE(self);
    return [[AGXProtocolInternal alloc] initWithObjCProtocol:protocol];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name {
    return [self initWithObjCProtocol:objc_getProtocol(name.UTF8String)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p: %@>",
            self.class, self, self.name];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:AGXProtocol.class]
    && protocol_isEqual(self.objCProtocol, [other objCProtocol]);
}

- (NSUInteger)hash {
    return [self.objCProtocol hash];
}

- (Protocol *)objCProtocol {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)name {
    return @(protocol_getName(self.objCProtocol));
}

- (NSArray *)incorporatedProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = protocol_copyProtocolList(self.objCProtocol, &count);

    NSMutableArray *array = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++)
        [array addObject:[AGXProtocol protocolWithObjCProtocol:protocols[i]]];

    free(protocols);
    return AGX_AUTORELEASE([array copy]);
}

- (NSArray *)methodsRequired:(BOOL)isRequiredMethod instance:(BOOL)isInstanceMethod {
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList
    (self.objCProtocol, isRequiredMethod, isInstanceMethod, &count);

    NSMutableArray *array = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        NSString *signature = [NSString stringWithCString:methods[i].types encoding:NSString.defaultCStringEncoding];
        [array addObject:[AGXMethod methodWithSelector:methods[i].name implementation:NULL signature:signature]];
    }

    free(methods);
    return AGX_AUTORELEASE([array copy]);
}

@end

@implementation AGXProtocolInternal

- (AGX_INSTANCETYPE)initWithObjCProtocol:(Protocol *)protocol {
    if AGX_EXPECT_F(!protocol) { AGX_RELEASE(self); return nil; }
    if AGX_EXPECT_T(self = [self init]) _protocol = protocol;
    return self;
}

- (Protocol *)objCProtocol {
    return _protocol;
}

@end
