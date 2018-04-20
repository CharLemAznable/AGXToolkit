//
//  NSSet+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/2.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "NSSet+AGXCore.h"
#import "AGXArc.h"
#import "NSNull+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(NSSet, AGXCore)

- (BOOL)isEmpty {
    return 0 == self.count;
}

- (BOOL)isNotEmpty {
    return 0 != self.count;
}

- (NSSet *)deepCopy {
    return [[NSSet alloc] initWithSet:self.duplicate];
}

- (NSMutableSet *)mutableDeepCopy {
    return [[NSMutableSet alloc] initWithSet:self.duplicate];
}

- (NSSet *)deepMutableCopy {
    return [[NSSet alloc] initWithSet:AGX_AUTORELEASE([self mutableDeepMutableCopy])];
}

- (NSMutableSet *)mutableDeepMutableCopy {
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:self.count];
    for (id item in self) {
        if ([item respondsToSelector:@selector(mutableDeepMutableCopy)])
            [set addObject:AGX_AUTORELEASE([item mutableDeepMutableCopy])];
        else if ([item respondsToSelector:@selector(mutableCopy)])
            [set addObject:AGX_AUTORELEASE([item mutableCopy])];
        else [set addObject:AGX_AUTORELEASE([item copy])];
    }
    return set;
}

- (id)itemForMember:(id)member {
    id item = [self member:member];
    return AGXIsNil(item) ? nil : item;
}

- (NSString *)stringJoinedByString:(NSString *)joiner usingComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty {
    return [NSString stringWithArray:self.allObjects joinedByString:joiner usingComparator:cmptr filterEmpty:filterEmpty];
}

@end

@category_interface(NSMutableSet, AGXCoreSafe)
@end
@category_implementation(NSMutableSet, AGXCoreSafe)

- (void)AGXCoreSafe_NSMutableSet_addObject:(id)object {
    if AGX_EXPECT_F(!object) return;
    [self AGXCoreSafe_NSMutableSet_addObject:object];
}

- (void)AGXCoreSafe_NSMutableSet_removeObject:(id)object {
    if AGX_EXPECT_F(!object) return;
    [self AGXCoreSafe_NSMutableSet_removeObject:object];
}

+ (void)load {
    agx_once
    ([NSClassFromString(@"__NSSetM")
      swizzleInstanceOriSelector:@selector(addObject:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableSet_addObject:)];
     [NSClassFromString(@"__NSSetM")
      swizzleInstanceOriSelector:@selector(removeObject:)
      withNewSelector:@selector(AGXCoreSafe_NSMutableSet_removeObject:)];);
}

@end
