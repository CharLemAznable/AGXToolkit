//
//  AGXWebView.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWebView_AGXWebView_h
#define AGXWebView_AGXWebView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXObjC.h>

AGX_EXTERN NSString *AutoRegisterMethodNamePrefix;

@interface AGXWebView : UIWebView
- (void)registerHandler:(id)handler selector:(SEL)selector name:(NSString *)handlerName;
@end

#endif /* AGXWebView_AGXWebView_h */
