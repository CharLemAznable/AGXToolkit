//
//  AGXAppConfig.m
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXProperty.h>
#import "AGXAppConfig.h"

AGX_STATIC NSString *const AppConfigBundleNameKey = @"AppConfigBundleNameKey";
AGX_STATIC NSString *const AppConfigDictionaryKey = @"AppConfigDictionaryKey";

AGX_STATIC NSDictionary *appConfigData(id instance);

void specifyAGXAppConfigBundle(const char *className, NSString *bundleName) {
    Class cls = objc_getClass(className);
    [cls setRetainProperty:bundleName forAssociateKey:AppConfigBundleNameKey];
}

void synthesizeAppConfig(const char *className, NSString *propertyName) {
    Class cls = objc_getClass(className);
    AGXProperty *property = [AGXProperty propertyWithName:propertyName inClass:cls];
    NSCAssert(property.property, @"Could not find property %s.%@", className, propertyName);
    NSCAssert(property.attributes.count != 0, @"Could not fetch property attributes for %s.%@", className, propertyName);
    NSCAssert(property.memoryManagementPolicy != AGXPropertyMemoryManagementPolicyAssign,
              @"Does not support un-strong-reference property %s.%@", className, propertyName);

    id getter = ^(id self) { return [appConfigData(self) objectForKey:propertyName]; };
    id setter = ^(id self, id value) {};
    if (AGX_EXPECT_F(!class_addMethod(cls, property.getter, imp_implementationWithBlock(getter), "@@:")))
        NSCAssert(NO, @"Could not add getter %s for property %s.%@", sel_getName(property.getter), className, propertyName);
    if (!property.isReadOnly) class_addMethod(cls, property.setter, imp_implementationWithBlock(setter), "v@:@");
}

AGX_STATIC NSDictionary *appConfigData(id instance) {
    if (AGX_EXPECT_F(![[instance class] retainPropertyForAssociateKey:AppConfigDictionaryKey]))
        [[instance class] setRetainProperty:AGXBundle.bundleNameAs([[instance class] retainPropertyForAssociateKey:AppConfigBundleNameKey]).dictionaryWithFile(AGXBundle.appIdentifier) ?: @{}
                            forAssociateKey:AppConfigDictionaryKey];
    return [[instance class] retainPropertyForAssociateKey:AppConfigDictionaryKey];
}
