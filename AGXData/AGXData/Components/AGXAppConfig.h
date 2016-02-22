//
//  AGXAppConfig.h
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXData_AGXAppConfig_h
#define AGXData_AGXAppConfig_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXSingleton.h>

// appconfig_interface
#define appconfig_interface(className, superClassName)                      \
singleton_interface(className, superClassName)

// appconfig_implementation
#define appconfig_implementation(className)                                 \
singleton_implementation(className)

// appconfig_bundle
#define appconfig_bundle(className, bundleName)                             \
AGX_CONSTRUCTOR void init_AGX_APPCONFIG_##className##_bundle() {            \
    specifyAGXAppConfigBundle(#className, @#bundleName);                    \
}

// appconfig
#define appconfig(className, property)                                      \
dynamic property;                                                           \
AGX_CONSTRUCTOR void synthesize_AGX_APPCONFIG_##className##_##property() {  \
    synthesizeAppConfig(#className, @#property);                            \
}

AGX_EXTERN void specifyAGXAppConfigBundle(const char *className, NSString *bundleName);
AGX_EXTERN void synthesizeAppConfig(const char *className, NSString *propertyName);

#endif /* AGXData_AGXAppConfig_h */
