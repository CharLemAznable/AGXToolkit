//
//  NSDictionary+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSDictionary_AGXCore_h
#define AGXCore_NSDictionary_AGXCore_h

#import "NSObject+AGXCore.h"

@category_interface(NSDictionary, AGXCore)
- (NSDictionary *)deepCopy NS_RETURNS_RETAINED; // deep copy items, item need <NSCoding>
- (NSMutableDictionary *)mutableDeepCopy NS_RETURNS_RETAINED; // only mutable container, item need <NSCoding>
- (NSDictionary *)deepMutableCopy NS_RETURNS_RETAINED; // only mutable items, item need -mutableCopy
- (NSMutableDictionary *)mutableDeepMutableCopy NS_RETURNS_RETAINED; // mutable container and items, item need -mutableCopy

- (id)itemForKey:(id)key;

- (id)objectForCaseInsensitiveKey:(id)key;
- (NSDictionary *)subDictionaryForKeys:(NSArray *)keys;
- (NSString *)stringJoinedByString:(NSString *)joiner keyValueJoinedByString:(NSString *)kvJoiner usingKeysComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty;

+ (NSDictionary *)dictionaryWithContentsOfFilePath:(NSString *)path;
- (NSDictionary *)initWithContentsOfFilePath:(NSString *)path;
@end

@category_interface(NSMutableDictionary, AGXCore)
- (void)addAbsenceEntriesFromDictionary:(NSDictionary *)otherDictionary;
@end

#endif /* AGXCore_NSDictionary_AGXCore_h */
