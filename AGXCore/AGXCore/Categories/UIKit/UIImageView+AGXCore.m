//
//  UIImageView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "UIImageView+AGXCore.h"
#import "AGXArc.h"

@category_implementation(UIImageView, AGXCore)

+ (AGX_INSTANCETYPE)imageViewWithImage:(UIImage *)image {
    return AGX_AUTORELEASE([[self alloc] initWithImage:image]);
}

@end
