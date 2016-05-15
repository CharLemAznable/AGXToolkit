//
//  NSObject+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSObject_AGXCore_h
#define AGXCore_NSObject_AGXCore_h

#import <Foundation/Foundation.h>
#import "AGXCategory.h"

@category_interface(NSObject, AGXCore)
+ (AGX_INSTANCETYPE)instance;

+ (void)addInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;
+ (void)addOrReplaceInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;
+ (void)addClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;
+ (void)addOrReplaceClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding;

+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector;
+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz;
+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector;
+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz;

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
@end

#endif /* AGXCore_NSObject_AGXCore_h */
