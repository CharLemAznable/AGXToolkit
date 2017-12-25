//
//  UIImageView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIImageView_AGXCore_h
#define AGXCore_UIImageView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIImageView, AGXCore)
+ (AGX_INSTANCETYPE)imageViewWithImage:(UIImage *)image;
@end

#endif /* AGXCore_UIImageView_AGXCore_h */
