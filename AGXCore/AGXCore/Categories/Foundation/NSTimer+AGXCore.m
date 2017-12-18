//
//  NSTimer+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/12/15.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  ChatGame/HWWeakTimer
//

// The MIT License (MIT)
//
// Copyright (c) 2015  ( https://github.com/callmewhy )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "NSTimer+AGXCore.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"

@interface AGXTimerInternalProxy : NSObject
@property (nonatomic, AGX_WEAK) id target;
@property (nonatomic, assign)   SEL selector;
@property (nonatomic, copy)     void (^block)(NSTimer *timer);
@property (nonatomic, AGX_WEAK) NSTimer *timer;

- (void)fireTarget:(NSTimer *)timer;
- (void)fireBlock:(NSTimer *)timer;
@end

@interface NSTimerCompatiblityAGXCoreDummy : NSObject
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
+ (NSTimer *)AGXCore_NSTimer_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
@end

@category_implementation(NSTimer, AGXCore)

+ (NSTimer *)AGXCore_NSTimer_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    AGXTimerInternalProxy *proxy = AGXTimerInternalProxy.instance;
    proxy.target = aTarget;
    proxy.selector = aSelector;
    proxy.timer = [self AGXCore_NSTimer_scheduledTimerWithTimeInterval:ti target:proxy selector:@selector(fireTarget:) userInfo:userInfo repeats:yesOrNo];
    return proxy.timer;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSTimer swizzleClassOriSelector:@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:) withNewSelector:@selector(AGXCore_NSTimer_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)];
        [NSTimer swizzleClassOriSelector:@selector(scheduledTimerWithTimeInterval:repeats:block:) withNewSelector:@selector(AGXCore_NSTimer_scheduledTimerWithTimeInterval:repeats:block:) fromClass:[NSTimerCompatiblityAGXCoreDummy class]];
    });
}

@end

@implementation AGXTimerInternalProxy

- (void)setBlock:(void (^)(NSTimer *))block {
    void (^temp)(NSTimer *) = AGX_BLOCK_COPY(block);
    AGX_BLOCK_RELEASE(_block);
    _block = temp;
}

- (void)fireTarget:(NSTimer *)timer {
    if (!_target) { [_timer invalidate]; _timer = nil; return; }
    AGX_PerformSelector([_target performSelector:_selector withObject:timer];)
}

- (void)fireBlock:(NSTimer *)timer {
    if (!_block) { [_timer invalidate]; _timer = nil; return; }
    !_block ?: _block(timer);
}

- (void)dealloc {
    _target = nil;
    AGX_BLOCK_RELEASE(_block);
    _timer = nil;
    AGX_SUPER_DEALLOC;
}

@end

@implementation NSTimerCompatiblityAGXCoreDummy

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    AGXTimerInternalProxy *proxy = AGXTimerInternalProxy.instance;
    proxy.block = block;
    proxy.timer = [NSTimer AGXCore_NSTimer_scheduledTimerWithTimeInterval:interval target:proxy selector:@selector(fireBlock:) userInfo:nil repeats:repeats];
    return proxy.timer;
}

+ (NSTimer *)AGXCore_NSTimer_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [self AGXCore_NSTimer_scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
}

@end
