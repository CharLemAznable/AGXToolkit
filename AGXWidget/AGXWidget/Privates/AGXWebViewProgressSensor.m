//
//  AGXWebViewProgressSensor.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  ninjinkun/NJKWebViewProgress
//

//  The MIT License (MIT)
//
//  Copyright (c) 2013 Satoshi Asano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import "AGXWebViewProgressSensor.h"

#define agxkProgressSensorScheme    @"agxscheme"
#define agxkProgressSensorComplete  @"__PROGRESS_COMPLETE__"

const float agxInitialProgressValue     = 0.1f;
const float agxInteractiveProgressValue = 0.5f;
const float agxFinalProgressValue       = 0.9f;

@implementation AGXWebViewProgressSensor {
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    BOOL _interactive;
}

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _loadingCount = _maxLoadCount = 0;
        _interactive = NO;
        _currentRequest = nil;
    }
    return self;
}

- (void)setProgress:(float)progress {
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        if ([self.delegate respondsToSelector:@selector(webViewProgressSensor:updateProgress:)])
            [self.delegate webViewProgressSensor:self updateProgress:progress];
    }
}

- (void)dealloc {
    AGX_RELEASE(_currentRequest);
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

- (void)resetProgressWithRequest:(NSURLRequest *)request {
    _loadingCount = _maxLoadCount = 0;
    _interactive = NO;
    AGX_RELEASE(_currentRequest);
    _currentRequest = [request copy];
    [self setProgress:0.0];
}

- (void)startProgress {
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);

    if (_progress < agxInitialProgressValue)
        [self setProgress:agxInitialProgressValue];
}

- (void)senseProgressFromURL:(NSURL *)documentURL withError:(NSError *)error {
    _loadingCount--;

    float progress = self.progress;
    float maxProgress = _interactive ? agxFinalProgressValue :
    (agxInteractiveProgressValue + [NSDate date].timeIntervalMillsSince1970 % 10 * 0.01);
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];

    if ([self.delegate respondsToSelector:@selector(evaluateJavascript:)]) {
        NSString *readyState = [self.delegate evaluateJavascript:@"document.readyState"];
        if ([readyState isEqualToString:@"interactive"]) {
            _interactive = YES;
            [self.delegate evaluateJavascript:ProgressSensorCompleteJS()];
        }

        BOOL isNotRedirect = _currentRequest && [_currentRequest.URL isEqual:documentURL];
        BOOL complete = [readyState isEqualToString:@"complete"];
        if ((complete && isNotRedirect) || error) {
            [self setProgress:1.0];
        }
    }
}

#pragma mark - private function

NSString *ProgressSensorCompleteJS() {
    static NSString *completeJS = @"window.addEventListener('load',function(){var AGXPIframe=document.createElement('iframe');AGXPIframe.style.display='none';AGXPIframe.src='"agxkProgressSensorScheme@"://"agxkProgressSensorComplete@"';document.body.appendChild(AGXPIframe);setTimeout(function() {document.body.removeChild(AGXPIframe)},0);},false);";
    return completeJS;
}

@end

#undef agxkProgressSensorComplete
#undef agxkProgressSensorScheme
