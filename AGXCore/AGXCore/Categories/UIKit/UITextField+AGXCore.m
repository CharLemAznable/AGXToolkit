//
//  UITextField+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "UITextField+AGXCore.h"

@category_implementation(UITextField, AGXCore)

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string limitWithLength:(NSUInteger)length {
    NSString *toBeString = [self.text stringByReplacingCharactersInRange:range withString:string];
    if (self.markedTextRange != nil || toBeString.length <= length || 1 == range.length) return YES;
    self.text = [toBeString substringToIndex:length];
    return NO;
}

@end
