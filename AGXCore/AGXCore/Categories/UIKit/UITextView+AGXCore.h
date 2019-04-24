//
//  UITextView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UITextView_AGXCore_h
#define AGXCore_UITextView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UITextView, AGXCore)
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string limitWithLength:(NSUInteger)length;
@end

#endif /* AGXCore_UITextView_AGXCore_h */
