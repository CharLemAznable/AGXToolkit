//
//  AGXWebViewExtension.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/16.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewExtension_h
#define AGXWidget_AGXWebViewExtension_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXEvaluateJavascriptDelegate.h"

@protocol AGXWebViewExtensionDelegate;

@interface AGXWebViewExtension : NSObject <UIScrollViewDelegate, UIScrollViewDelegate_AGXCore>
@property (nonatomic, AGX_WEAK) id<AGXWebViewExtensionDelegate> delegate;
@property (nonatomic, assign) BOOL autoCoordinateBackgroundColor; // default YES
@property (nonatomic, assign) BOOL autoRevealCurrentLocationHost; // default YES
@property (nonatomic, AGX_STRONG) NSString *currentLocationHostRevealFormat; // default "Provided by: %@"

- (void)coordinateBackgroundColor;
- (void)revealCurrentLocationHost;
@end

@protocol AGXWebViewExtensionDelegate <AGXEvaluateJavascriptDelegate>
- (void)webViewExtension:(AGXWebViewExtension *)webViewExtension coordinateWithBackgroundColor:(UIColor *)backgroundColor;
- (void)webViewExtension:(AGXWebViewExtension *)webViewExtension revealWithCurrentLocationHost:(NSString *)locationHost;
- (void)webViewExtension:(AGXWebViewExtension *)webViewExtension didChangeAdjustedContentInset:(UIScrollView *)scrollView;
@end

#endif /* AGXWidget_AGXWebViewExtension_h */
