//
//  NSArray+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSArray_AGXCore_h
#define AGXCore_NSArray_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSArray, AGXCore)
- (NSArray *)deepCopy NS_RETURNS_RETAINED; // deep copy items, item need <NSCoding>
- (NSMutableArray *)mutableDeepCopy NS_RETURNS_RETAINED; // only mutable container, item need <NSCoding>
- (NSArray *)deepMutableCopy NS_RETURNS_RETAINED; // only mutable items, item need -mutableCopy
- (NSMutableArray *)mutableDeepMutableCopy NS_RETURNS_RETAINED; // mutable container and items, item need -mutableCopy
- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)defaultValue;
- (NSArray *)reverseArray;
@end

#endif /* AGXCore_NSArray_AGXCore_h */
