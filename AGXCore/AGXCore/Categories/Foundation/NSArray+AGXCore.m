//
//  NSArray+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSArray+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "NSNull+AGXCore.h"
#import "AGXBundle.h"
#import "AGXArc.h"

@category_implementation(NSArray, AGXCore)

- (NSArray *)deepCopy {
    return [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:
                                           [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (NSMutableArray *)deepMutableCopy {
    return [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                  [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)defaultValue {
    id value = [self objectAtIndex:index];
    return [NSNull isNull:value] ? defaultValue : value;
}

+ (NSArray *)arrayWithContentsOfUserFile:(NSString *)fileName {
    return [self arrayWithContentsOfUserFile:fileName subpath:nil];
}

+ (NSArray *)arrayWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if ([AGXDirectory fileExists:fileName inDirectory:AGXDocument subpath:subpath])
        return [self arrayWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    return [self arrayWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

+ (NSArray *)arrayWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self arrayWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

+ (NSArray *)arrayWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if (AGX_EXPECT_F(![AGXDirectory fileExists:fileName inDirectory:directory subpath:subpath])) return nil;
    return [self arrayWithContentsOfFile:[AGXDirectory fullFilePath:fileName inDirectory:directory subpath:subpath]];
}

+ (NSArray *)arrayWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self arrayWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

+ (NSArray *)arrayWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self arrayWithContentsOfFile:[AGXBundle plistPathWithName:fileName bundle:bundleName subpath:subpath]];
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

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self objectAtIndex:index];
}
#endif

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@category_implementation(NSMutableArray, AGXCore)

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    [self replaceObjectAtIndex:index withObject:obj];
}

@end
#endif

@category_interface_generic(NSArray, AGX_COVARIANT_GENERIC(AGX_OBJECT_TYPE), AGXSafe)
@end
@category_implementation(NSArray, AGXSafe)

- (AGX_INSTANCETYPE)agx_initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    if (cnt == 0) return [self agx_initWithObjects:objects count:cnt];
    id nonnull_objects[cnt];
    int nonnull_index = 0;
    for (int index = 0; index < cnt; index++) {
        if (!objects[index]) continue;
        nonnull_objects[nonnull_index] = objects[index];
        nonnull_index++;
    }
    return [self agx_initWithObjects:nonnull_objects count:nonnull_index];
}

- (id)agx_objectAtIndex:(NSUInteger)index {
    if (AGX_EXPECT_F(index >= [self count])) return nil;
    return [self agx_objectAtIndex:index];
}

- (id)agx_objectAtIndexedSubscript:(NSUInteger)index {
    if (AGX_EXPECT_F(index >= [self count])) return nil;
    return [self agx_objectAtIndexedSubscript:index];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSPlaceholderArray")
         swizzleInstanceOriSelector:@selector(initWithObjects:count:)
         withNewSelector:@selector(agx_initWithObjects:count:)];
        
        [NSClassFromString(@"__NSArrayI")
         swizzleInstanceOriSelector:@selector(initWithObjects:count:)
         withNewSelector:@selector(agx_initWithObjects:count:)];
        [NSClassFromString(@"__NSArrayI")
         swizzleInstanceOriSelector:@selector(objectAtIndex:)
         withNewSelector:@selector(agx_objectAtIndex:)];
        [NSClassFromString(@"__NSArrayI")
         swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
         withNewSelector:@selector(agx_objectAtIndexedSubscript:)];
    });
}

@end 

@category_interface_generic(NSMutableArray, AGX_GENERIC(AGX_OBJECT_TYPE), AGXSafe)
@end
@category_implementation(NSMutableArray, AGXSafe)

- (void)agx_setObject:(id)anObject atIndexedSubscript:(NSUInteger)index {
    if (!anObject) { [self removeObjectAtIndex:index]; return; }
    [self agx_setObject:anObject atIndexedSubscript:index];
}

- (void)agx_addObject:(id)anObject {
    if (AGX_EXPECT_F(!anObject)) return;
    [self agx_addObject:anObject];
}

- (void)agx_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (AGX_EXPECT_F(!anObject)) return;
    [self agx_insertObject:anObject atIndex:index];
}

- (void)agx_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) { [self removeObjectAtIndex:index]; return; }
    [self agx_replaceObjectAtIndex:index withObject:anObject];
}

- (void)agx_removeObjectAtIndex:(NSUInteger)index {
    if (AGX_EXPECT_F(index >= [self count])) return;
    [self agx_removeObjectAtIndex:index];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(initWithObjects:count:)
         withNewSelector:@selector(agx_initWithObjects:count:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(objectAtIndex:)
         withNewSelector:@selector(agx_objectAtIndex:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
         withNewSelector:@selector(agx_objectAtIndexedSubscript:)];
        
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(setObject:atIndexedSubscript:)
         withNewSelector:@selector(agx_setObject:atIndexedSubscript:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(addObject:)
         withNewSelector:@selector(agx_addObject:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(insertObject:atIndex:)
         withNewSelector:@selector(agx_insertObject:atIndex:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(replaceObjectAtIndex:withObject:)
         withNewSelector:@selector(agx_replaceObjectAtIndex:withObject:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(removeObjectAtIndex:)
         withNewSelector:@selector(agx_removeObjectAtIndex:)];
    });
}

@end
