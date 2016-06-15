//
//  AGXDataBox.h
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXData_AGXDataBox_h
#define AGXData_AGXDataBox_h

#import <AGXCore/AGXCore/AGXSingleton.h>

AGX_EXTERN NSString *AGXAppEverLaunchedKey;
AGX_EXTERN NSString *AGXAppFirstLaunchKey;

@interface AGXDataBox : NSObject
+ (BOOL)appEverLaunched;
+ (BOOL)appFirstLaunch;
@end

@protocol AGXDataBox <NSObject>
@required
- (void)synchronize;

@optional
+ (NSString *)defaultShareKey;
+ (NSString *)keychainShareKey;
+ (NSString *)keychainShareDomain;
+ (NSString *)restrictShareKey;
+ (NSString *)restrictShareDomain;
+ (NSString *)defaultUsersKey;
+ (NSString *)keychainUsersKey;
+ (NSString *)keychainUsersDomain;
+ (NSString *)restrictUsersKey;
+ (NSString *)restrictUsersDomain;
@end

// databox_interface
#define databox_interface(className, superClassName)                            \
singleton_interface(className, superClassName) <AGXDataBox>                     \
- (id)defaultShareObjectForKey:(id)key;                                         \
- (void)setDefaultShareObject:(id)obj forKey:(id)key;                           \
- (id)keychainShareObjectForKey:(id)key;                                        \
- (void)setKeychainShareObject:(id)obj forKey:(id)key;                          \
- (id)restrictShareObjectForKey:(id)key;                                        \
- (void)setRestrictShareObject:(id)obj forKey:(id)key;                          \
- (id)defaultUsersObjectForKey:(id)key userId:(id)userId;                       \
- (void)setDefaultUsersObject:(id)obj forKey:(id)key userId:(id)userId;         \
- (id)keychainUsersObjectForKey:(id)key userId:(id)userId;                      \
- (void)setKeychainUsersObject:(id)obj forKey:(id)key userId:(id)userId;        \
- (id)restrictUsersObjectForKey:(id)key userId:(id)userId;                      \
- (void)setRestrictUsersObject:(id)obj forKey:(id)key userId:(id)userId;

// databox_property
#define databox_property(className, propertyType, propertyName)                 \
property (nonatomic, AGX_STRONG) propertyType propertyName;                     \
- (className *(^)(id))propertyName##As;

// databox_implementation
#define databox_implementation(className)                                       \
singleton_implementation(className)                                             \
AGX_CONSTRUCTOR void construct_AGX_DATABOX_##className() {                      \
    constructAGXDataBox(#className);                                            \
}                                                                               \
- (void)synchronize {                                                           \
    @synchronized(self) {                                                       \
        defaultShareDataSynchronize(self);                                      \
        keychainShareDataSynchronize(self);                                     \
        restrictShareDataSynchronize(self);                                     \
        defaultUsersDataSynchronize(self);                                      \
        keychainUsersDataSynchronize(self);                                     \
        restrictUsersDataSynchronize(self);                                     \
    }                                                                           \
}                                                                               \
- (id)defaultShareObjectForKey:(id)key {                                        \
    return [defaultShareData(self) objectForKey:key];                           \
}                                                                               \
- (void)setDefaultShareObject:(id)obj forKey:(id)key {                          \
    [(NSMutableDictionary *)defaultShareData(self) setObject:obj forKey:key];   \
}                                                                               \
- (id)keychainShareObjectForKey:(id)key {                                       \
    return [keychainShareData(self) objectForKey:key];                          \
}                                                                               \
- (void)setKeychainShareObject:(id)obj forKey:(id)key {                         \
    [(NSMutableDictionary *)keychainShareData(self) setObject:obj forKey:key];  \
}                                                                               \
- (id)restrictShareObjectForKey:(id)key {                                       \
    return [restrictShareData(self) objectForKey:key];                          \
}                                                                               \
- (void)setRestrictShareObject:(id)obj forKey:(id)key {                         \
    [(NSMutableDictionary *)restrictShareData(self) setObject:obj forKey:key];  \
}                                                                               \
- (id)defaultUsersObjectForKey:(id)key userId:(id)userId {                      \
    return [defaultUsersData(self, userId) objectForKey:key];                   \
}                                                                               \
- (void)setDefaultUsersObject:(id)obj forKey:(id)key userId:(id)userId {        \
    [(NSMutableDictionary *)defaultUsersData(self, userId)                      \
     setObject:obj forKey:key];                                                 \
}                                                                               \
- (id)keychainUsersObjectForKey:(id)key userId:(id)userId {                     \
    return [keychainUsersData(self, userId) objectForKey:key];                  \
}                                                                               \
- (void)setKeychainUsersObject:(id)obj forKey:(id)key userId:(id)userId {       \
    [(NSMutableDictionary *)keychainUsersData(self, userId)                     \
     setObject:obj forKey:key];                                                 \
}                                                                               \
- (id)restrictUsersObjectForKey:(id)key userId:(id)userId {                     \
    return [restrictUsersData(self, userId) objectForKey:key];                  \
}                                                                               \
- (void)setRestrictUsersObject:(id)obj forKey:(id)key userId:(id)userId {       \
    [(NSMutableDictionary *)restrictUsersData(self, userId)                     \
     setObject:obj forKey:key];                                                 \
}

// default_share
#define default_share(className, property)                                      \
synthesize_constructor(className, property,                                     \
defaultShareData(instance))

// keychain_share
#define keychain_share(className, property)                                     \
synthesize_constructor(className, property,                                     \
keychainShareData(instance))

// restrict_share
#define restrict_share(className, property)                                     \
synthesize_constructor(className, property,                                     \
restrictShareData(instance))

// default_users
#define default_users(className, property, userIdProperty)                      \
synthesize_constructor(className, property,                                     \
defaultUsersData(instance, [instance valueForKey:@#userIdProperty]))

// keychain_users
#define keychain_users(className, property, userIdProperty)                     \
synthesize_constructor(className, property,                                     \
keychainUsersData(instance, [instance valueForKey:@#userIdProperty]))

// restrict_users
#define restrict_users(className, property, userIdProperty)                     \
synthesize_constructor(className, property,                                     \
restrictUsersData(instance, [instance valueForKey:@#userIdProperty]))

// synthesize_constructor
#define synthesize_constructor(className, property, dataRef)                    \
dynamic property;                                                               \
AGX_CONSTRUCTOR void synthesize_AGX_DATABOX_##className##_##property() {        \
    synthesizeDataBox(#className, @#property, ^NSDictionary *(id instance) {    \
        return dataRef;                                                         \
    });                                                                         \
}                                                                               \
- (className *(^)(id))property##As { return nil; }

AGX_EXTERN void constructAGXDataBox(const char *className);

AGX_EXTERN void defaultShareDataSynchronize(id instance);
AGX_EXTERN void keychainShareDataSynchronize(id instance);
AGX_EXTERN void restrictShareDataSynchronize(id instance);
AGX_EXTERN void defaultUsersDataSynchronize(id instance);
AGX_EXTERN void keychainUsersDataSynchronize(id instance);
AGX_EXTERN void restrictUsersDataSynchronize(id instance);

AGX_EXTERN NSDictionary *defaultShareData(id instance);
AGX_EXTERN NSDictionary *keychainShareData(id instance);
AGX_EXTERN NSDictionary *restrictShareData(id instance);
AGX_EXTERN NSDictionary *defaultUsersData(id instance, id userId);
AGX_EXTERN NSDictionary *keychainUsersData(id instance, id userId);
AGX_EXTERN NSDictionary *restrictUsersData(id instance, id userId);

AGX_EXTERN void synthesizeDataBox(const char *className, NSString *propertyName, NSDictionary *(^dataRef)(id instance));

#endif /* AGXData_AGXDataBox_h */
