//
//  UILabel+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UILabel_AGXCore_h
#define AGXCore_UILabel_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UILabel, AGXCore)
@property (nonatomic, assign) CGFloat linesSpacing;
@property (nonatomic, assign) CGFloat paragraphSpacing;
@end

#endif /* AGXCore_UILabel_AGXCore_h */
