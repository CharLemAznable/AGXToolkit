//
//  AGXCategory.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXCategory_h
#define AGXCore_AGXCategory_h

#import "AGXObjC.h"

// enable_category_constructor
#define enable_category_constructor(className, categoryName)                    \
AGX_CONSTRUCTOR void enable_AGX_CATEGORY_##className##_##categoryName()         \
{ [AGX_CATEGORY_##className##_##categoryName declare]; }

// category_interface
#define category_interface(className, categoryName)                             \
interface AGX_CATEGORY_##className##_##categoryName : NSObject                  \
+ (void)declare;                                                                \
@end                                                                            \
enable_category_constructor(className, categoryName)                            \
@interface className (categoryName)

// category_implementation
#define category_implementation(className, categoryName)                        \
implementation AGX_CATEGORY_##className##_##categoryName                        \
+ (void)declare { ; }                                                           \
@end                                                                            \
@implementation className (categoryName)

#endif /* AGXCore_AGXCategory_h */
