//
//  NSObject+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSObject_AGXCore_h
#define AGXCore_NSObject_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSObject, AGXCore)
+ (BOOL)isProperSubclassOfClass:(Class)aClass;

+ (AGX_INSTANCETYPE)instance;
- (AGX_INSTANCETYPE)duplicate;

+ (BOOL)silentUndefinedKeyValueCoding; // default to NO
+ (void)setSilentUndefinedKeyValueCoding:(BOOL)silentUndefinedKeyValueCoding;

+ (void)addInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;
+ (void)addOrReplaceInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;
+ (void)addClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;
+ (void)addOrReplaceClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;

+ (void)addInstanceMethodWithSelector:(SEL)selector fromClass:(Class)clazz;
+ (void)addOrReplaceInstanceMethodWithSelector:(SEL)selector fromClass:(Class)clazz;
+ (void)addClassMethodWithSelector:(SEL)selector fromClass:(Class)clazz;
+ (void)addOrReplaceClassMethodWithSelector:(SEL)selector fromClass:(Class)clazz;

+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector;
+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz;
+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector;
+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz;

- (id)performAGXSelector:(SEL)selector;
- (id)performAGXSelector:(SEL)selector withObject:(id)object;
- (id)performAGXSelector:(SEL)selector withObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
- (id)performAGXSelector:(SEL)selector withObjectsArray:(NSArray *)objectArray;

- (void)addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths;

- (id)assignPropertyForAssociateKey:(NSString *)key;
- (void)setAssignProperty:(id)property forAssociateKey:(NSString *)key;
- (void)setKVOAssignProperty:(id)property forAssociateKey:(NSString *)key;
- (id)retainPropertyForAssociateKey:(NSString *)key;
- (void)setRetainProperty:(id)property forAssociateKey:(NSString *)key;
- (void)setKVORetainProperty:(id)property forAssociateKey:(NSString *)key;
- (id)copyPropertyForAssociateKey:(NSString *)key;
- (void)setCopyProperty:(id)property forAssociateKey:(NSString *)key;
- (void)setKVOCopyProperty:(id)property forAssociateKey:(NSString *)key;

- (NSData *)plistData;
- (NSString *)plistString;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
@end

AGX_EXTERN BOOL AGXIsNil(id object);
AGX_EXTERN BOOL AGXIsNotNil(id object);

AGX_EXTERN BOOL AGXIsEmpty(id object);
AGX_EXTERN BOOL AGXIsNotEmpty(id object);
AGX_EXTERN BOOL AGXIsNilOrEmpty(id object);

#endif /* AGXCore_NSObject_AGXCore_h */
