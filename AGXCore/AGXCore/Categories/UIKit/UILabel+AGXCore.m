//
//  UILabel+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UILabel+AGXCore.h"
#import "AGXAdapt.h"

@category_implementation(UILabel, AGXCore)

- (CGSize)sizeThatConstraintToSize:(CGSize)size {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    BEFORE_IOS7 ? [self.text sizeWithFont:self.font
                        constrainedToSize:size
                            lineBreakMode:self.lineBreakMode] :
#endif
    [self.text boundingRectWithSize:size
                            options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                         attributes:@{ NSFontAttributeName:self.font }
                            context:NULL].size;
}

@end
