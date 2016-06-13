//
//  AGXProtocol.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

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
            [self class], self, [self name]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AGXProtocol class]]
    && protocol_isEqual([self objCProtocol], [other objCProtocol]);
}

- (NSUInteger)hash {
    return [(id)[self objCProtocol] hash];
}

- (Protocol *)objCProtocol {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)name {
    return @(protocol_getName([self objCProtocol]));
}

- (NSArray *)incorporatedProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = protocol_copyProtocolList([self objCProtocol], &count);

    NSMutableArray *array = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++)
        [array addObject:[AGXProtocol protocolWithObjCProtocol:protocols[i]]];

    free(protocols);
    return AGX_AUTORELEASE([array copy]);
}

- (NSArray *)methodsRequired:(BOOL)isRequiredMethod instance:(BOOL)isInstanceMethod {
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList
    ([self objCProtocol], isRequiredMethod, isInstanceMethod, &count);

    NSMutableArray *array = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        NSString *signature = [NSString stringWithCString:methods[i].types encoding:[NSString defaultCStringEncoding]];
        [array addObject:[AGXMethod methodWithSelector:methods[i].name implementation:NULL signature:signature]];
    }

    free(methods);
    return AGX_AUTORELEASE([array copy]);
}

@end

@implementation AGXProtocolInternal

- (AGX_INSTANCETYPE)initWithObjCProtocol:(Protocol *)protocol {
    if (AGX_EXPECT_T(self = [self init])) _protocol = protocol;
    return self;
}

- (Protocol *)objCProtocol {
    return _protocol;
}

@end
