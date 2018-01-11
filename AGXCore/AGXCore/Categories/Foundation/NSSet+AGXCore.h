//
//  NSSet+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2017/11/2.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSSet_AGXCore_h
#define AGXCore_NSSet_AGXCore_h

#import "NSObject+AGXCore.h"

@category_interface(NSSet, AGXCore)
- (NSSet *)deepCopy NS_RETURNS_RETAINED; // deep copy items, item need <NSCoding>
- (NSMutableSet *)mutableDeepCopy NS_RETURNS_RETAINED; // only mutable container, item need <NSCoding>
- (NSSet *)deepMutableCopy NS_RETURNS_RETAINED; // only mutable items, item need -mutableCopy
- (NSMutableSet *)mutableDeepMutableCopy NS_RETURNS_RETAINED; // mutable container and items, item need -mutableCopy
- (id)member:(id)object defaultValue:(id)defaultValue;
- (NSString *)stringJoinedByString:(NSString *)joiner usingComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty;
@end

#endif /* AGXCore_NSSet_AGXCore_h */
