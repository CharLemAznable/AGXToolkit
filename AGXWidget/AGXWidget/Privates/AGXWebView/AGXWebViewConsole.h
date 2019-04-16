//
//  AGXWebViewConsole.h
//  AGXWidget
//
//  Created by Char Aznable on 2017/12/12.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewConsole_h
#define AGXWidget_AGXWebViewConsole_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXWebViewLogLevel.h"

@protocol AGXWebViewConsoleDelegate;

@interface AGXWebViewConsole : UIView
@property (nonatomic, assign)   UIEdgeInsets layoutContentInset;
@property (nonatomic, AGX_WEAK) id<AGXWebViewConsoleDelegate> delegate;
@property (nonatomic, assign)   AGXWebViewLogLevel javascriptLogLevel;

- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWebViewLogLevel)level;
- (void)addLogLevel:(AGXWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack;
@end

@protocol AGXWebViewConsoleDelegate <NSObject>
@optional
- (void)webViewConsole:(AGXWebViewConsole *)console didSelectSegmentIndex:(NSInteger)index;
@end

#endif /* AGXWidget_AGXWebViewConsole_h */
