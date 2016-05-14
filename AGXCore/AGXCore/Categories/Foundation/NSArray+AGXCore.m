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

- (NSMutableArray *)mutableDeepCopy {
    return [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                  [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (NSArray *)deepMutableCopy {
    return [[NSArray alloc] initWithArray:AGX_AUTORELEASE([self mutableDeepMutableCopy])];
}

- (NSMutableArray *)mutableDeepMutableCopy {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id item in self) {
        if ([item respondsToSelector:@selector(mutableDeepMutableCopy)])
            [array addObject:AGX_AUTORELEASE([item mutableDeepMutableCopy])];
        else if ([item respondsToSelector:@selector(mutableCopy)])
            [array addObject:AGX_AUTORELEASE([item mutableCopy])];
        else [array addObject:AGX_AUTORELEASE([item copy])];
    }
    return array;
}

- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)defaultValue {
    id value = [self objectAtIndex:index];
    return [NSNull isNull:value] ? defaultValue : value;
}

- (NSArray *)reverseArray {
    return [[self reverseObjectEnumerator] allObjects];
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
    return([AGXDirectory createPathOfFile:fileName inDirectory:directory subpath:subpath] &&
           [self writeToFile:[AGXDirectory fullFilePath:fileName inDirectory:directory subpath:subpath] atomically:YES]);
}

@end

@category_interface_generic(NSArray, AGX_COVARIANT_GENERIC(AGX_OBJECT_TYPE), AGXCoreSafe)
@end
@category_implementation(NSArray, AGXCoreSafe)

- (AGX_INSTANCETYPE)AGXCoreSafe_initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    if (cnt == 0) return [self AGXCoreSafe_initWithObjects:objects count:cnt];
    id nonnull_objects[cnt];
    int nonnull_index = 0;
    for (int index = 0; index < cnt; index++) {
        if (!objects[index]) continue;
        nonnull_objects[nonnull_index] = objects[index];
        nonnull_index++;
    }
    return [self AGXCoreSafe_initWithObjects:nonnull_objects count:nonnull_index];
}

- (id)AGXCoreSafe_objectAtIndex:(NSUInteger)index {
    if (AGX_EXPECT_F(index >= [self count])) return nil;
    return [self AGXCoreSafe_objectAtIndex:index];
}

- (id)AGXCoreSafe_objectAtIndexedSubscript:(NSUInteger)index {
    if (AGX_EXPECT_F(index >= [self count])) return nil;
    return [self AGXCoreSafe_objectAtIndexedSubscript:index];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSPlaceholderArray")
         swizzleInstanceOriSelector:@selector(initWithObjects:count:)
         withNewSelector:@selector(AGXCoreSafe_initWithObjects:count:)];

        [NSClassFromString(@"__NSArrayI")
         swizzleInstanceOriSelector:@selector(initWithObjects:count:)
         withNewSelector:@selector(AGXCoreSafe_initWithObjects:count:)];
        [NSClassFromString(@"__NSArrayI")
         swizzleInstanceOriSelector:@selector(objectAtIndex:)
         withNewSelector:@selector(AGXCoreSafe_objectAtIndex:)];
        [NSClassFromString(@"__NSArrayI")
         swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_objectAtIndexedSubscript:)];
    });
}

@end 

@category_interface_generic(NSMutableArray, AGX_GENERIC(AGX_OBJECT_TYPE), AGXCoreSafe)
@end
@category_implementation(NSMutableArray, AGXCoreSafe)

- (void)AGXCoreSafe_setObject:(id)anObject atIndexedSubscript:(NSUInteger)index {
    if (!anObject) { [self removeObjectAtIndex:index]; return; }
    [self AGXCoreSafe_setObject:anObject atIndexedSubscript:index];
}

- (void)AGXCoreSafe_addObject:(id)anObject {
    if (AGX_EXPECT_F(!anObject)) return;
    [self AGXCoreSafe_addObject:anObject];
}

- (void)AGXCoreSafe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (AGX_EXPECT_F(!anObject)) return;
    [self AGXCoreSafe_insertObject:anObject atIndex:index];
}

- (void)AGXCoreSafe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) { [self removeObjectAtIndex:index]; return; }
    [self AGXCoreSafe_replaceObjectAtIndex:index withObject:anObject];
}

- (void)AGXCoreSafe_removeObjectAtIndex:(NSUInteger)index {
    if (AGX_EXPECT_F(index >= [self count])) return;
    [self AGXCoreSafe_removeObjectAtIndex:index];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(initWithObjects:count:)
         withNewSelector:@selector(AGXCoreSafe_initWithObjects:count:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(objectAtIndex:)
         withNewSelector:@selector(AGXCoreSafe_objectAtIndex:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_objectAtIndexedSubscript:)];

        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(setObject:atIndexedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_setObject:atIndexedSubscript:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(addObject:)
         withNewSelector:@selector(AGXCoreSafe_addObject:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(insertObject:atIndex:)
         withNewSelector:@selector(AGXCoreSafe_insertObject:atIndex:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(replaceObjectAtIndex:withObject:)
         withNewSelector:@selector(AGXCoreSafe_replaceObjectAtIndex:withObject:)];
        [NSClassFromString(@"__NSArrayM")
         swizzleInstanceOriSelector:@selector(removeObjectAtIndex:)
         withNewSelector:@selector(AGXCoreSafe_removeObjectAtIndex:)];
    });
}

@end
