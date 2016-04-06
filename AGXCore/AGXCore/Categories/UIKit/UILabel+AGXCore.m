//
//  UILabel+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UILabel+AGXCore.h"

@category_implementation(UILabel, AGXCore)

- (CGSize)sizeThatConstraintToSize:(CGSize)size {
    return [self.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                         attributes:@{ NSFontAttributeName:self.font } context:NULL].size;
}

@end
