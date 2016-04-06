//
//  NSDictionary+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSDictionary+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "NSNull+AGXCore.h"
#import "AGXBundle.h"
#import "AGXArc.h"

@category_implementation(NSDictionary, AGXCore)

- (NSDictionary *)deepCopy {
    return [[NSDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                     [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (NSMutableDictionary *)deepMutableCopy {
    return [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                            [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (id)objectForKey:(id)key defaultValue:(id)defaultValue {
    id value = [self objectForKey:key];
    return [NSNull isNull:value] ? defaultValue : value;
}

- (NSDictionary *)subDictionaryForKeys:(NSArray *)keys {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([keys containsObject:key]) [dict setValue:obj forKey:key];
    }];
    return AGX_AUTORELEASE([dict copy]);
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName {
    return [self dictionaryWithContentsOfUserFile:fileName subpath:nil];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if ([AGXDirectory fileExists:fileName inDirectory:AGXDocument subpath:subpath])
        return [self dictionaryWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    return [self dictionaryWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self dictionaryWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if (AGX_EXPECT_F(![AGXDirectory fileExists:fileName inDirectory:directory subpath:subpath])) return nil;
    return [self dictionaryWithContentsOfFile:[AGXDirectory fullFilePath:fileName inDirectory:directory subpath:subpath]];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self dictionaryWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self dictionaryWithContentsOfFile:[AGXBundle plistPathWithName:fileName bundle:bundleName subpath:subpath]];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName {
    return [self initWithContentsOfUserFile:fileName subpath:nil];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if ([AGXDirectory fileExists:fileName inDirectory:AGXDocument subpath:subpath])
        return [self initWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    return [self initWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self initWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if (AGX_EXPECT_F(![AGXDirectory fileExists:fileName inDirectory:directory subpath:subpath])) return nil;
    return [self initWithContentsOfFile:[AGXDirectory fullFilePath:fileName inDirectory:directory subpath:subpath]];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self initWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self initWithContentsOfFile:[AGXBundle plistPathWithName:fileName bundle:bundleName subpath:subpath]];
}

- (BOOL)writeToUserFile:(NSString *)fileName {
    return [self writeToUserFile:fileName inDirectory:AGXDocument];
}

- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self writeToUserFile:fileName inDirectory:directory subpath:nil];
}

- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if (AGX_EXPECT_F(![AGXDirectory createDirectory:[fileName stringByDeletingLastPathComponent]
                                        inDirectory:directory subpath:subpath])) return NO;
    return [self writeToFile:[AGXDirectory fullFilePath:fileName inDirectory:directory subpath:subpath] atomically:YES];
}

@end

@category_interface_generic(NSDictionary, AGX_COVARIANT_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE), AGXCoreSafe)
@end
@category_implementation(NSDictionary, AGXCoreSafe)

- (AGX_INSTANCETYPE)AGXCoreSafe_initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt {
    if (cnt == 0) return [self AGXCoreSafe_initWithObjects:objects forKeys:keys count:cnt];
    id nonnull_objects[cnt];
    id nonnull_keys[cnt];
    int nonnull_index = 0;
    for (int index = 0; index < cnt; index++) {
        if (!objects[index] || !keys[index]) continue;
        nonnull_objects[nonnull_index] = objects[index];
        nonnull_keys[nonnull_index] = keys[index];
        nonnull_index++;
    }
    return [self AGXCoreSafe_initWithObjects:nonnull_objects forKeys:nonnull_keys count:nonnull_index];
}

- (id)AGXCoreSafe_objectForKey:(id)key {
    if (AGX_EXPECT_F(!key)) return nil;
    return [self AGXCoreSafe_objectForKey:key];
}

- (id)AGXCoreSafe_objectForKeyedSubscript:(id)key {
    if (AGX_EXPECT_F(!key)) return nil;
    return [self AGXCoreSafe_objectForKeyedSubscript:key];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSPlaceholderDictionary")
         swizzleInstanceOriSelector:@selector(initWithObjects:forKeys:count:)
         withNewSelector:@selector(AGXCoreSafe_initWithObjects:forKeys:count:)];
        
        [NSClassFromString(@"__NSDictionaryI")
         swizzleInstanceOriSelector:@selector(initWithObjects:forKeys:count:)
         withNewSelector:@selector(AGXCoreSafe_initWithObjects:forKeys:count:)];
        [NSClassFromString(@"__NSDictionaryI")
         swizzleInstanceOriSelector:@selector(objectForKey:)
         withNewSelector:@selector(AGXCoreSafe_objectForKey:)];
        [NSClassFromString(@"__NSDictionaryI")
         swizzleInstanceOriSelector:@selector(objectForKeyedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_objectForKeyedSubscript:)];
    });
}

@end

@category_interface_generic(NSMutableDictionary, AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE), AGXCoreSafe)
@end
@category_implementation(NSMutableDictionary, AGXCoreSafe)

- (void)AGXCoreSafe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (AGX_EXPECT_F(!aKey)) return;
    if (!anObject) { [self removeObjectForKey:aKey]; return; }
    [self AGXCoreSafe_setObject:anObject forKey:aKey];
}

- (void)AGXCoreSafe_setObject:(id)anObject forKeyedSubscript:(id<NSCopying>)aKey {
    if (AGX_EXPECT_F(!aKey)) return;
    if (!anObject) { [self removeObjectForKey:aKey]; return; }
    [self AGXCoreSafe_setObject:anObject forKeyedSubscript:aKey];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(initWithObjects:forKeys:count:)
         withNewSelector:@selector(AGXCoreSafe_initWithObjects:forKeys:count:)];
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(objectForKey:)
         withNewSelector:@selector(AGXCoreSafe_objectForKey:)];
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(objectForKeyedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_objectForKeyedSubscript:)];
        
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(setObject:forKey:)
         withNewSelector:@selector(AGXCoreSafe_setObject:forKey:)];
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(setObject:forKeyedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_setObject:forKeyedSubscript:)];
    });
}

@end
