//
//  AGXDataBox.m
//  AGXData
//
//  Created by Char Aznable on 2016/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXProperty.h>
#import <AGXJson/AGXJson.h>
#import "AGXDataBox.h"
#import "AGXKeychain.h"

#define ShareUserDefaults               [NSUserDefaults standardUserDefaults]
#define AppKeyFormat(key)               [NSString stringWithFormat:@"%@."@#key, AGXBundle.appIdentifier]
#define ClassKeyFormat(className, key)  [NSString stringWithFormat:@"%@.%s"@"."@#key, AGXBundle.appIdentifier, className]

NSString *AGXAppEverLaunchedKey = nil;
NSString *AGXAppFirstLaunchKey = nil;

@implementation AGXDataBox

AGX_CONSTRUCTOR void construct_AGX_DATABOX_launchData() {
    AGXAppEverLaunchedKey = AGXAppEverLaunchedKey ?: AGX_RETAIN(AppKeyFormat(AppEverLaunched));
    AGXAppFirstLaunchKey = AGXAppFirstLaunchKey ?: AGX_RETAIN(AppKeyFormat(AppFirstLaunch));

    if AGX_EXPECT_F(![ShareUserDefaults boolForKey:AGXAppEverLaunchedKey]) {
        [ShareUserDefaults setBool:YES forKey:AGXAppEverLaunchedKey];
        [ShareUserDefaults setBool:YES forKey:AGXAppFirstLaunchKey];
    } else [ShareUserDefaults setBool:NO forKey:AGXAppFirstLaunchKey];
    [ShareUserDefaults synchronize];
}

+ (BOOL)appEverLaunched {
    return [ShareUserDefaults boolForKey:AGXAppEverLaunchedKey];
}

+ (BOOL)appFirstLaunch {
    return [ShareUserDefaults boolForKey:AGXAppFirstLaunchKey];
}

@end

#pragma mark -

AGX_STATIC NSString *const DataBoxDefaultShareKey = @"DataBoxDefaultShareKey";
AGX_STATIC NSString *const DataBoxKeychainShareKey = @"DataBoxKeychainShareKey";
AGX_STATIC NSString *const DataBoxKeychainShareDomainKey = @"DataBoxKeychainShareDomainKey";
AGX_STATIC NSString *const DataBoxRestrictShareKey = @"DataBoxRestrictShareKey";
AGX_STATIC NSString *const DataBoxRestrictShareDomainKey = @"DataBoxRestrictShareDomainKey";
AGX_STATIC NSString *const DataBoxDefaultUsersKey = @"DataBoxDefaultUsersKey";
AGX_STATIC NSString *const DataBoxKeychainUsersKey = @"DataBoxKeychainUsersKey";
AGX_STATIC NSString *const DataBoxKeychainUsersDomainKey = @"DataBoxKeychainUsersDomainKey";
AGX_STATIC NSString *const DataBoxRestrictUsersKey = @"DataBoxRestrictUsersKey";
AGX_STATIC NSString *const DataBoxRestrictUsersDomainKey = @"DataBoxRestrictUsersDomainKey";

AGX_STATIC void defaultDataSynchronize(id instance, NSString *key);
AGX_STATIC void keychainDataSynchronize(id instance, NSString *key, NSString *domain);
AGX_STATIC void restrictDataSynchronize(id instance, NSString *key, NSString *domain);

AGX_STATIC void initialShareData(id instance, NSString *key, id initialData);
AGX_STATIC void initialUsersData(id instance, NSString *key, id userId, id jsonObject);
AGX_STATIC NSString *keychainDataString(NSString *key, NSString *domain);
AGX_STATIC void cleanKeychainData(NSString *key, NSString *domain);

#pragma mark -

void constructAGXDataBox(const char *className) {
    Class cls = objc_getClass(className);

#define setKeyProperty(sel, key)                                    \
[cls setRetainProperty:[cls respondsToSelector:@selector(sel)] ?    \
 [cls sel] : ClassKeyFormat(className, key)                         \
       forAssociateKey:DataBox##key##Key]
    setKeyProperty(defaultShareKey, DefaultShare);
    setKeyProperty(keychainShareKey, KeychainShare);
    setKeyProperty(keychainShareDomain, KeychainShareDomain);
    setKeyProperty(restrictShareKey, RestrictShare);
    setKeyProperty(restrictShareDomain, RestrictShareDomain);
    setKeyProperty(defaultUsersKey, DefaultUsers);
    setKeyProperty(keychainUsersKey, KeychainUsers);
    setKeyProperty(keychainUsersDomain, KeychainUsersDomain);
    setKeyProperty(restrictUsersKey, RestrictUsers);
    setKeyProperty(restrictUsersDomain, RestrictUsersDomain);
#undef setKeyProperty
}

#define keyProperty(key) [[instance class] retainPropertyForAssociateKey:DataBox##key##Key]

void defaultShareDataSynchronize(id instance) {
    defaultDataSynchronize(instance, keyProperty(DefaultShare));
}

void keychainShareDataSynchronize(id instance) {
    keychainDataSynchronize(instance, keyProperty(KeychainShare), keyProperty(KeychainShareDomain));
}

void restrictShareDataSynchronize(id instance) {
    restrictDataSynchronize(instance, keyProperty(RestrictShare), keyProperty(RestrictShareDomain));
}

void defaultUsersDataSynchronize(id instance) {
    defaultDataSynchronize(instance, keyProperty(DefaultUsers));
}

void keychainUsersDataSynchronize(id instance) {
    keychainDataSynchronize(instance, keyProperty(KeychainUsers), keyProperty(KeychainUsersDomain));
}

void restrictUsersDataSynchronize(id instance) {
    restrictDataSynchronize(instance, keyProperty(RestrictUsers), keyProperty(RestrictUsersDomain));
}

NSDictionary *defaultShareData(id instance) {
    NSString *key = keyProperty(DefaultShare);
    initialShareData(instance, key,
                     [[ShareUserDefaults objectForKey:key] agxJsonObject]);
    return [instance retainPropertyForAssociateKey:key];
}

NSDictionary *keychainShareData(id instance) {
    NSString *key = keyProperty(KeychainShare);
    NSString *domain = keyProperty(KeychainShareDomain);
    initialShareData(instance, key,
                     [keychainDataString(key, domain) agxJsonObject]);
    return [instance retainPropertyForAssociateKey:key];
}

NSDictionary *restrictShareData(id instance) {
    NSString *key = keyProperty(RestrictShare);
    NSString *domain = keyProperty(RestrictShareDomain);
    if AGX_EXPECT_F([AGXDataBox appFirstLaunch]) cleanKeychainData(key, domain);
    initialShareData(instance, key, [keychainDataString(key, domain) agxJsonObject]);
    return [instance retainPropertyForAssociateKey:key];
}

NSDictionary *defaultUsersData(id instance, id userId) {
    NSString *key = keyProperty(DefaultUsers);
    initialUsersData(instance, key, userId,
                     [[[ShareUserDefaults objectForKey:key] agxJsonObject] objectForKey:userId]);
    return [[instance retainPropertyForAssociateKey:key] objectForKey:userId];
}

NSDictionary *keychainUsersData(id instance, id userId) {
    NSString *key = keyProperty(KeychainUsers);
    NSString *domain = keyProperty(KeychainUsersDomain);
    initialUsersData(instance, key, userId,
                     [[keychainDataString(key, domain) agxJsonObject] objectForKey:userId]);
    return [[instance retainPropertyForAssociateKey:key] objectForKey:userId];
}

NSDictionary *restrictUsersData(id instance, id userId) {
    NSString *key = keyProperty(RestrictUsers);
    NSString *domain = keyProperty(RestrictUsersDomain);
    if AGX_EXPECT_F([AGXDataBox appFirstLaunch]) cleanKeychainData(key, domain);
    initialUsersData(instance, key, userId, [[keychainDataString(key, domain) agxJsonObject] objectForKey:userId]);
    return [[instance retainPropertyForAssociateKey:key] objectForKey:userId];
}

void synthesizeDataBox(const char *className, NSString *propertyName, NSDictionary *(^dataRef)(id instance)) {
    Class cls = objc_getClass(className);
    AGXProperty *property = [AGXProperty propertyWithName:propertyName inClass:cls];
    NSCAssert(property.property, @"Could not find property %s.%@", className, propertyName);
    NSCAssert(property.attributes.count != 0, @"Could not fetch property attributes for %s.%@", className, propertyName);
    NSCAssert(property.memoryManagementPolicy != AGXPropertyMemoryManagementPolicyAssign,
              @"Does not support un-strong-reference property %s.%@", className, propertyName);

    id getter = ^(id self) { return [dataRef(self) objectForKey:propertyName]; };
    id setter = ^(id self, id value) { [(NSMutableDictionary *)dataRef(self) setObject:value forKey:propertyName]; };
    id bsetter = ^(id self) { return AGX_BLOCK_AUTORELEASE(^(id value) { [(NSMutableDictionary *)dataRef(self) setObject:value forKey:propertyName]; return self; }); };
    [cls addOrReplaceInstanceMethodWithSelector:property.getter andBlock:getter andTypeEncoding:"@@:"];
    if (!property.isReadOnly) {
        [cls addOrReplaceInstanceMethodWithSelector:property.setter andBlock:setter andTypeEncoding:"v@:@"];

        SEL bsel = sel_registerName(([NSString stringWithFormat:@"%@As", propertyName]).UTF8String);
        [cls addOrReplaceInstanceMethodWithSelector:bsel andBlock:bsetter andTypeEncoding:"@?@:"];
    }
}

#undef keyProperty

#pragma mark -

AGX_STATIC void defaultDataSynchronize(id instance, NSString *key) {
    NSDictionary *data = [instance retainPropertyForAssociateKey:key];
    if AGX_EXPECT_F(!data) return;
    [ShareUserDefaults setObject:[data agxJsonStringWithOptions:AGXJsonWriteClassName] forKey:key];
    [ShareUserDefaults synchronize];
}

AGX_STATIC void keychainDataSynchronize(id instance, NSString *key, NSString *domain) {
    NSDictionary *data = [instance retainPropertyForAssociateKey:key];
    if AGX_EXPECT_F(!data) return;
    NSString *dataStr = [data agxJsonStringWithOptions:AGXJsonWriteClassName];
    if AGX_EXPECT_F(!dataStr) return;
    NSError *error = nil;
    [AGXKeychain storePassword:dataStr forUsername:key andService:domain updateExisting:YES error:&error];
    if AGX_EXPECT_F(error) AGXLog(@"Keychain Synchronize Error: %@", error);
}

AGX_STATIC void restrictDataSynchronize(id instance, NSString *key, NSString *domain) {
    keychainDataSynchronize(instance, key, domain);
}

AGX_STATIC void initialShareData(id instance, NSString *key, id jsonObject) {
    if AGX_EXPECT_T([instance retainPropertyForAssociateKey:key]) return;
    [instance setRetainProperty:[NSMutableDictionary dictionaryWithValidJsonObject:
                                 jsonObject ?: @{}] forAssociateKey:key];
}

AGX_STATIC void initialUsersData(id instance, NSString *key, id userId, id jsonObject) {
    initialShareData(instance, key, nil);
    if AGX_EXPECT_T([[instance retainPropertyForAssociateKey:key] objectForKey:userId]) return;
    [[instance retainPropertyForAssociateKey:key] setObject:[NSMutableDictionary dictionaryWithValidJsonObject:
                                                       jsonObject ?: @{}] forKey:userId];
}

AGX_STATIC NSString *keychainDataString(NSString *key, NSString *domain) {
    NSError *error = nil;
    NSString *dataStr = [AGXKeychain passwordForUsername:key andService:domain error:&error];
    if AGX_EXPECT_F(error) AGXLog(@"Keychain Error: %@", error);
    return dataStr;
}

AGX_STATIC void cleanKeychainData(NSString *key, NSString *domain) {
    [AGXKeychain deletePasswordForUsername:key andService:domain error:NULL];
}

#undef ClassKeyFormat
#undef AppKeyFormat
#undef ShareUserDefaults
