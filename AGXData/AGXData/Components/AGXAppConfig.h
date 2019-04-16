//
//  AGXAppConfig.h
//  AGXData
//
//  Created by Char Aznable on 2016/2/22.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXData_AGXAppConfig_h
#define AGXData_AGXAppConfig_h

#import <AGXCore/AGXCore/AGXSingleton.h>

@protocol AGXAppConfig <NSObject>
@optional
- (NSString *)appConfigPlistName;
@end

// appconfig_interface
#define appconfig_interface(className, superClassName, instanceName)        \
singleton_interface(className, superClassName, instanceName) <AGXAppConfig>

// appconfig_implementation
#define appconfig_implementation(className, instanceName)                   \
singleton_implementation(className, instanceName)

// appconfig_bundle
#define appconfig_bundle(className, bundleName)                             \
AGX_CONSTRUCTOR void init_AGX_APPCONFIG_##className##_bundle() {            \
    specifyAGXAppConfigBundle(#className, (bundleName));                    \
}

// appconfig_plistName
#define appconfig_plistName(plistName)                                      \
- (NSString *)appConfigPlistName { return (plistName); }

// appconfig
#define appconfig(className, property)                                      \
dynamic property;                                                           \
AGX_CONSTRUCTOR void synthesize_AGX_APPCONFIG_##className##_##property() {  \
    synthesizeAppConfig(#className, @#property);                            \
}

AGX_EXTERN void specifyAGXAppConfigBundle(const char *className, NSString *bundleName);
AGX_EXTERN void synthesizeAppConfig(const char *className, NSString *propertyName);

#endif /* AGXData_AGXAppConfig_h */
