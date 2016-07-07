//
//  UIWebView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/7/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIWebView_AGXCore_h
#define AGXCore_UIWebView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIWebView, AGXCore)
- (void)loadRequestWithURLString:(NSString *)requestURLString;
@end

#endif /* AGXCore_UIWebView_AGXCore_h */
