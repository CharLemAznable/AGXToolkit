//
//  NSArray+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "NSArray+AGXCore.h"
#import "AGXArc.h"
#import "NSNull+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(NSArray, AGXCore)

- (BOOL)isEmpty {
    return 0 == self.count;
}

- (BOOL)isNotEmpty {
    return 0 != self.count;
}

- (NSArray *)deepCopy {
    return [[NSArray alloc] initWithArray:self.duplicate];
}

- (NSMutableArray *)mutableDeepCopy {
    return [[NSMutableArray alloc] initWithArray:self.duplicate];
}

- (NSArray *)deepMutableCopy {
    return [[NSArray alloc] initWithArray:AGX_AUTORELEASE([self mutableDeepMutableCopy])];
}

- (NSMutableArray *)mutableDeepMutableCopy {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id item in self) {
        if ([item respondsToSelector:@selector(mutableDeepMutableCopy)])
            [array addObject:AGX_AUTORELEASE([item mutableDeepMutableCopy])];
        else if ([item respondsToSelector:@selector(mutableCopyWithZone:)])
            [array addObject:AGX_AUTORELEASE([item mutableCopy])];
        else if ([item respondsToSelector:@selector(copyWithZone:)])
            [array addObject:AGX_AUTORELEASE([item copy])];
        else [array addObject:item];
    }
    return array;
}

- (id)itemAtIndex:(NSUInteger)index {
    id item = [self objectAtIndex:index];
    return AGXIsNil(item) ? nil : item;
}

- (NSArray *)reverseArray {
    return [self reverseObjectEnumerator].allObjects;
}

- (NSString *)stringJoinedByString:(NSString *)joiner usingComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty {
    return [NSString stringWithArray:self joinedByString:joiner usingComparator:cmptr filterEmpty:filterEmpty];
}

+ (NSArray *)arrayWithContentsOfFilePath:(NSString *)path {
    if (@available(iOS 11.0, *)) {
        return [self arrayWithContentsOfURL:
                [NSURL fileURLWithPath:path] error:NULL];
    } else return [self arrayWithContentsOfFile:path];
}

- (NSArray *)initWithContentsOfFilePath:(NSString *)path {
    if (@available(iOS 11.0, *)) {
        return [self initWithContentsOfURL:
                [NSURL fileURLWithPath:path] error:NULL];
    } else return [self initWithContentsOfFile:path];
}

@end

@category_implementation(NSMutableArray, AGXCore)

- (void)addAbsenceObject:(id)anObject {
    if AGX_EXPECT_T(![self containsObject:anObject]) [self addObject:anObject];
}

- (void)addAbsenceObjectsFromArray:(NSArray *)otherArray {
    NSSet *arraySet = [NSSet setWithArray:otherArray];
    NSMutableArray *temp = AGX_AUTORELEASE([arraySet.allObjects mutableCopy]);
    [temp removeObjectsInArray:self];
    [self addObjectsFromArray:temp];
}

@end

@category_interface(NSArray, AGXCoreSafe)
@end
@category_implementation(NSArray, AGXCoreSafe)

- (AGX_INSTANCETYPE)AGXCoreSafe_NSArray_initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    if (0 == cnt) return [self AGXCoreSafe_NSArray_initWithObjects:objects count:cnt];
    id nonnull_objects[cnt];
    int nonnull_index = 0;
    for (int index = 0; index < cnt; index++) {
        if AGX_EXPECT_F(!objects[index]) continue;
        nonnull_objects[nonnull_index] = objects[index];
        nonnull_index++;
    }
    return [self AGXCoreSafe_NSArray_initWithObjects:nonnull_objects count:nonnull_index];
}

- (id)AGXCoreSafe_NSArray_objectAtIndex:(NSUInteger)index {
    if AGX_EXPECT_F(index >= self.count) return nil;
    return [self AGXCoreSafe_NSArray_objectAtIndex:index];
}

- (id)AGXCoreSafe_NSArray_objectAtIndexedSubscript:(NSUInteger)index {
    if AGX_EXPECT_F(index >= self.count) return nil;
    return [self AGXCoreSafe_NSArray_objectAtIndexedSubscript:index];
}

+ (void)load {
    agx_once
    ([NSClassFromString(@"__NSPlaceholderArray")
      swizzleInstanceOriSelector:@selector(initWithObjects:count:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_initWithObjects:count:)];

     [NSClassFromString(@"__NSArrayI")
      swizzleInstanceOriSelector:@selector(initWithObjects:count:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_initWithObjects:count:)];
     [NSClassFromString(@"__NSArrayI")
      swizzleInstanceOriSelector:@selector(objectAtIndex:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndex:)];
     [NSClassFromString(@"__NSArrayI")
      swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndexedSubscript:)];

     [NSClassFromString(@"__NSArray0")
      swizzleInstanceOriSelector:@selector(initWithObjects:count:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_initWithObjects:count:)];
     [NSClassFromString(@"__NSArray0")
      swizzleInstanceOriSelector:@selector(objectAtIndex:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndex:)];
     [NSClassFromString(@"__NSArray0")
      swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndexedSubscript:)];

     [NSClassFromString(@"__NSSingleObjectArrayI")
      swizzleInstanceOriSelector:@selector(initWithObjects:count:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_initWithObjects:count:)];
     [NSClassFromString(@"__NSSingleObjectArrayI")
      swizzleInstanceOriSelector:@selector(objectAtIndex:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndex:)];
     [NSClassFromString(@"__NSSingleObjectArrayI")
      swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndexedSubscript:)];);
}

@end

@category_interface(NSMutableArray, AGXCoreSafe)
@end
@category_implementation(NSMutableArray, AGXCoreSafe)

- (void)AGXCoreSafe_NSMutableArray_setObject:(id)anObject atIndexedSubscript:(NSUInteger)index {
    if (!anObject) { [self removeObjectAtIndex:index]; return; }
    [self AGXCoreSafe_NSMutableArray_setObject:anObject atIndexedSubscript:index];
}

- (void)AGXCoreSafe_NSMutableArray_addObject:(id)anObject {
    if AGX_EXPECT_F(!anObject) return;
    [self AGXCoreSafe_NSMutableArray_addObject:anObject];
}

- (void)AGXCoreSafe_NSMutableArray_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if AGX_EXPECT_F(!anObject) return;
    [self AGXCoreSafe_NSMutableArray_insertObject:anObject atIndex:index];
}

- (void)AGXCoreSafe_NSMutableArray_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) { [self removeObjectAtIndex:index]; return; }
    [self AGXCoreSafe_NSMutableArray_replaceObjectAtIndex:index withObject:anObject];
}

- (void)AGXCoreSafe_NSMutableArray_removeObjectAtIndex:(NSUInteger)index {
    if AGX_EXPECT_F(index >= self.count) return;
    [self AGXCoreSafe_NSMutableArray_removeObjectAtIndex:index];
}

+ (void)load {
    agx_once
    ([NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(initWithObjects:count:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_initWithObjects:count:)];
     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(objectAtIndex:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndex:)];
     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(objectAtIndexedSubscript:)
      withNewSelector:@selector(AGXCoreSafe_NSArray_objectAtIndexedSubscript:)];

     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(setObject:atIndexedSubscript:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableArray_setObject:atIndexedSubscript:)];
     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(addObject:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableArray_addObject:)];
     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(insertObject:atIndex:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableArray_insertObject:atIndex:)];
     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(replaceObjectAtIndex:withObject:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableArray_replaceObjectAtIndex:withObject:)];
     [NSClassFromString(@"__NSArrayM")
      swizzleInstanceOriSelector:@selector(removeObjectAtIndex:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableArray_removeObjectAtIndex:)];);
}

@end
