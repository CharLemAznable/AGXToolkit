//
//  AGXWKWebViewRefreshView.h
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewRefreshView_h
#define AGXWidget_AGXWKWebViewRefreshView_h

#import "AGXRefreshView.h"

@class AGXWKWebView;

@interface AGXWKWebViewRefreshView : AGXRefreshView
@property (nonatomic, AGX_WEAK) AGXWKWebView *internalDelegate;
@end

#endif /* AGXWidget_AGXWKWebViewRefreshView_h */
