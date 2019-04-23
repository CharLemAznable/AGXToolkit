//
//  AGXWKWebViewConsoleView.h
//  AGXWidget
//
//  Created by Char on 2019/4/21.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewConsoleView_h
#define AGXWidget_AGXWKWebViewConsoleView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXWKWebViewLogLevel.h"

@protocol AGXWKWebViewConsoleViewDelegate;

@interface AGXWKWebViewConsoleView : UIView
@property (nonatomic, assign)   UIEdgeInsets layoutContentInset;
@property (nonatomic, AGX_WEAK) id<AGXWKWebViewConsoleViewDelegate> delegate;
@property (nonatomic, assign)   AGXWKWebViewLogLevel javascriptLogLevel;

- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWKWebViewLogLevel)level;
- (void)addLogLevel:(AGXWKWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack;
@end

@protocol AGXWKWebViewConsoleViewDelegate <NSObject>
@optional
- (void)webViewConsoleView:(AGXWKWebViewConsoleView *)consoleView didSelectSegmentIndex:(NSInteger)index;
@end

#endif /* AGXWidget_AGXWKWebViewConsoleView_h */
