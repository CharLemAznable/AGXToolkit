//
//  AGXWebViewProgressSensor.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewProgressSensor.h"
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>

#define agxkProgressSensorScheme    @"agxscheme"
#define agxkProgressSensorComplete  @"__PROGRESS_COMPLETE__"

const float AGXInitialProgressValue     = 0.1f;
const float AGXInteractiveProgressValue = 0.5f;
const float AGXFinalProgressValue       = 0.9f;

@implementation AGXWebViewProgressSensor {
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    BOOL _interactive;
    NSURL *_currentURL;
}

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _loadingCount = _maxLoadCount = 0;
        _interactive = NO;
        _currentURL = nil;
    }
    return self;
}

- (void)setProgress:(float)progress {
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        if ([_delegate respondsToSelector:@selector(webViewProgressSensor:updateProgress:)])
            [_delegate webViewProgressSensor:self updateProgress:progress];
    }
}

- (void)dealloc {
    AGX_RELEASE(_currentURL);
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (BOOL)senseCompletedWithRequest:(NSURLRequest *)request {
    if ([request.URL.scheme isEqualToString:agxkProgressSensorScheme] &&
        [request.URL.host isEqualToString:agxkProgressSensorComplete]) {
        [self setProgress:1.0];
        return YES;
    }
    return NO;
}

- (BOOL)shouldResetProgressWithRequest:(NSURLRequest *)request fromURL:(NSURL *)originURL {
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingString:
                                    [@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:originURL.absoluteString];
    }
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"]
    || [request.URL.scheme isEqualToString:@"https"]
    || [request.URL.scheme isEqualToString:@"file"];
    return !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation;
}

- (void)resetProgressWithRequest:(NSURLRequest *)request {
    _loadingCount = _maxLoadCount = 0;
    _interactive = NO;
    AGX_RELEASE(_currentURL);
    _currentURL = [request.URL copy];
    [self setProgress:0.0];
}

- (void)startProgress {
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    
    if (_progress < AGXInitialProgressValue)
        [self setProgress:AGXInitialProgressValue];
}

- (void)senseProgressFromURL:(NSURL *)documentURL withError:(NSError *)error {
    _loadingCount--;
    
    float progress = self.progress;
    float maxProgress = _interactive ? AGXFinalProgressValue :
    (AGXInteractiveProgressValue + [NSDate date].timeIntervalMillsSince1970 % 10 * 0.01);
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
    
    if ([_delegate respondsToSelector:@selector(evaluateJavascript:)]) {
        NSString *readyState = [_delegate evaluateJavascript:@"document.readyState"];
        if ([readyState isEqualToString:@"interactive"]) {
            _interactive = YES;
            [_delegate evaluateJavascript:ProgressSensorCompleteJS()];
        }
        
        BOOL isNotRedirect = _currentURL && [_currentURL isEqual:documentURL];
        BOOL complete = [readyState isEqualToString:@"complete"];
        if ((complete && isNotRedirect) || error) {
            [self setProgress:1.0];
        }
    }
}

#pragma mark - private function

NSString *ProgressSensorCompleteJS() {
    static NSString *completeJS = @"window.addEventListener('load',function(){var AGXPIframe=document.createElement('iframe');AGXPIframe.style.display='none';AGXPIframe.src='"agxkProgressSensorScheme@"://"agxkProgressSensorComplete@"';document.body.appendChild(AGXPIframe);setTimeout(function() {document.documentElement.removeChild(AGXPIframe)},0);},false);";
    return completeJS;
}

@end
