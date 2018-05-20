//
//  UITextField+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UITextField_AGXCore_h
#define AGXCore_UITextField_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UITextField, AGXCore)
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string limitWithLength:(NSUInteger)length;
@end

#endif /* AGXCore_UITextField_AGXCore_h */
