//
//  AGXProgressHUD.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Rename from:
//  MBProgressHUD.m
//  Version 0.9.1
//  Created by Matej Bukovinski on 2.4.09.
//

#import "AGXProgressHUD.h"
#import <tgmath.h>
#import <AGXCore/AGXCore/AGXAdapt.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
# define AGX_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
# define AGX_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
# define AGX_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
# define AGX_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1129.15
#endif

static const CGFloat kPadding = 4.f;
static const CGFloat kLabelFontSize = 16.f;
static const CGFloat kDetailsLabelFontSize = 12.f;

@interface AGXProgressHUD () {
    BOOL useAnimation;
    SEL methodForExecution;
    id targetForExecution;
    id objectForExecution;
    UILabel *label;
    UILabel *detailsLabel;
    BOOL isFinished;
    CGAffineTransform rotationTransform;
}

@property (atomic, AGX_STRONG) UIView *indicator;
@property (atomic, AGX_STRONG) NSTimer *graceTimer;
@property (atomic, AGX_STRONG) NSTimer *minShowTimer;
@property (atomic, AGX_STRONG) NSDate *showStarted;
@end

@implementation AGXProgressHUD

#pragma mark - Properties

@synthesize animationType;
@synthesize delegate;
@synthesize opacity;
@synthesize color;
@synthesize labelFont;
@synthesize labelColor;
@synthesize detailsLabelFont;
@synthesize detailsLabelColor;
@synthesize indicator;
@synthesize xOffset;
@synthesize yOffset;
@synthesize minSize;
@synthesize square;
@synthesize margin;
@synthesize dimBackground;
@synthesize graceTime;
@synthesize minShowTime;
@synthesize graceTimer;
@synthesize minShowTimer;
@synthesize taskInProgress;
@synthesize removeFromSuperViewOnHide;
@synthesize customView;
@synthesize showStarted;
@synthesize mode;
@synthesize labelText;
@synthesize detailsLabelText;
@synthesize progress;
@synthesize size;
@synthesize activityIndicatorColor;
@synthesize completionBlock;

#pragma mark - Class methods

+ (AGX_INSTANCETYPE)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    AGXProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud show:animated];
    return AGX_AUTORELEASE(hud);
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    AGXProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:animated];
        return YES;
    }
    return NO;
}

+ (NSUInteger)hideAllHUDsForView:(UIView *)view animated:(BOOL)animated {
    NSArray *huds = [AGXProgressHUD allHUDsForView:view];
    for (AGXProgressHUD *hud in huds) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:animated];
    }
    return [huds count];
}

+ (AGX_INSTANCETYPE)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (AGXProgressHUD *)subview;
        }
    }
    return nil;
}

+ (NSArray *)allHUDsForView:(UIView *)view {
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    for (UIView *aView in subviews) {
        if ([aView isKindOfClass:self]) {
            [huds addObject:aView];
        }
    }
    return [NSArray arrayWithArray:huds];
}

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    if (AGX_EXPECT_F(self = [super initWithFrame:frame])) {
        // Set default values for properties
        self.animationType = AGXProgressHUDAnimationFade;
        self.mode = AGXProgressHUDModeIndeterminate;
        self.labelText = nil;
        self.detailsLabelText = nil;
        self.opacity = 0.8f;
        self.color = nil;
        self.labelFont = [UIFont boldSystemFontOfSize:kLabelFontSize];
        self.labelColor = [UIColor whiteColor];
        self.detailsLabelFont = [UIFont boldSystemFontOfSize:kDetailsLabelFontSize];
        self.detailsLabelColor = [UIColor whiteColor];
        self.activityIndicatorColor = [UIColor whiteColor];
        self.xOffset = 0.0f;
        self.yOffset = 0.0f;
        self.dimBackground = NO;
        self.margin = 20.0f;
        self.cornerRadius = 10.0f;
        self.graceTime = 0.0f;
        self.minShowTime = 0.0f;
        self.removeFromSuperViewOnHide = NO;
        self.minSize = CGSizeZero;
        self.square = NO;
        self.contentMode = UIViewContentModeCenter;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
								| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        // Transparent background
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        // Make it invisible for now
        self.alpha = 0.0f;
        
        taskInProgress = NO;
        rotationTransform = CGAffineTransformIdentity;
        
        [self setupLabels];
        [self updateIndicators];
        [self registerForKVO];
        [self registerForNotifications];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (id)initWithWindow:(UIWindow *)window {
    return [self initWithView:window];
}

- (void)dealloc {
    [self unregisterFromNotifications];
    [self unregisterFromKVO];
    AGX_RELEASE(color);
    AGX_RELEASE(indicator);
    AGX_RELEASE(label);
    AGX_RELEASE(detailsLabel);
    AGX_RELEASE(labelText);
    AGX_RELEASE(detailsLabelText);
    AGX_RELEASE(graceTimer);
    AGX_RELEASE(minShowTimer);
    AGX_RELEASE(showStarted);
    AGX_RELEASE(customView);
    AGX_RELEASE(labelFont);
    AGX_RELEASE(labelColor);
    AGX_RELEASE(detailsLabelFont);
    AGX_RELEASE(detailsLabelColor);
    AGX_RELEASE(completionBlock);
    AGX_SUPER_DEALLOC;
}

#pragma mark - Show & hide

- (void)show:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"MBProgressHUD needs to be accessed on the main thread.");
    useAnimation = animated;
    // If the grace time is set postpone the HUD display
    if (self.graceTime > 0.0) {
        NSTimer *newGraceTimer = [NSTimer timerWithTimeInterval:self.graceTime target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:newGraceTimer forMode:NSRunLoopCommonModes];
        self.graceTimer = newGraceTimer;
    }
    // ... otherwise show the HUD imediately
    else {
        [self showUsingAnimation:useAnimation];
    }
}

- (void)hide:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"MBProgressHUD needs to be accessed on the main thread.");
    useAnimation = animated;
    // If the minShow time is set, calculate how long the hud was shown,
    // and pospone the hiding operation if necessary
    if (self.minShowTime > 0.0 && showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:showStarted];
        if (interv < self.minShowTime) {
            self.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv) target:self
                                                               selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
            return;
        }
    }
    // ... otherwise hide the HUD immediately
    [self hideUsingAnimation:useAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
    [self hide:[animated boolValue]];
}

#pragma mark - Timer callbacks

- (void)handleGraceTimer:(NSTimer *)theTimer {
    // Show the HUD only if the task is still running
    if (taskInProgress) {
        [self showUsingAnimation:useAnimation];
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:useAnimation];
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview {
    [self updateForCurrentOrientationAnimated:NO];
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation:(BOOL)animated {
    // Cancel any scheduled hideDelayed: calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setNeedsDisplay];
    
    if (animated && animationType == AGXProgressHUDAnimationZoomIn) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
    } else if (animated && animationType == AGXProgressHUDAnimationZoomOut) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    self.showStarted = [NSDate date];
    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        self.alpha = 1.0f;
        if (animationType == AGXProgressHUDAnimationZoomIn || animationType == AGXProgressHUDAnimationZoomOut) {
            self.transform = rotationTransform;
        }
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    // Fade out
    if (animated && showStarted) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
        // in the done method
        if (animationType == AGXProgressHUDAnimationZoomIn) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
        } else if (animationType == AGXProgressHUDAnimationZoomOut) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        
        self.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
    self.showStarted = nil;
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

- (void)done {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    isFinished = YES;
    self.alpha = 0.0f;
    if (removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = NULL;
    }
    if ([delegate respondsToSelector:@selector(hudWasHidden:)]) {
        [delegate performSelector:@selector(hudWasHidden:) withObject:self];
    }
}

#pragma mark - Threading

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
    methodForExecution = method;
    targetForExecution = AGX_RETAIN(target);
    objectForExecution = AGX_RETAIN(object);
    // Launch execution in new thread
    self.taskInProgress = YES;
    [NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
    // Show HUD view
    [self show:animated];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showAnimated:animated whileExecutingBlock:block onQueue:queue completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showAnimated:animated whileExecutingBlock:block onQueue:queue completionBlock:completion];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue {
    [self showAnimated:animated whileExecutingBlock:block onQueue:queue	completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
     completionBlock:(AGXProgressHUDCompletionBlock)completion {
    self.taskInProgress = YES;
    self.completionBlock = completion;
    dispatch_async(queue, ^(void) {
        block();
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self cleanUp];
        });
    });
    [self show:animated];
}

- (void)launchExecution {
    @autoreleasepool {
        // Start executing the requested task
        AGX_PerformSelector([targetForExecution performSelector:methodForExecution withObject:objectForExecution];)
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread)
        [self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
    }
}

- (void)cleanUp {
    taskInProgress = NO;
    AGX_RELEASE(targetForExecution);
    targetForExecution = nil;
    AGX_RELEASE(objectForExecution);
    objectForExecution = nil;
    [self hide:useAnimation];
}

#pragma mark - UI

- (void)setupLabels {
    label = [[UILabel alloc] initWithFrame:self.bounds];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = AGXTextAlignmentCenter;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.labelColor;
    label.font = self.labelFont;
    label.text = self.labelText;
    [self addSubview:label];
    
    detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
    detailsLabel.font = self.detailsLabelFont;
    detailsLabel.adjustsFontSizeToFitWidth = NO;
    detailsLabel.textAlignment = AGXTextAlignmentCenter;
    detailsLabel.opaque = NO;
    detailsLabel.backgroundColor = [UIColor clearColor];
    detailsLabel.textColor = self.detailsLabelColor;
    detailsLabel.numberOfLines = 0;
    detailsLabel.font = self.detailsLabelFont;
    detailsLabel.text = self.detailsLabelText;
    [self addSubview:detailsLabel];
}

- (void)updateIndicators {
    
    BOOL isActivityIndicator = [indicator isKindOfClass:[UIActivityIndicatorView class]];
    BOOL isRoundIndicator = [indicator isKindOfClass:[AGXRoundProgressView class]];
    
    if (mode == AGXProgressHUDModeIndeterminate) {
        if (!isActivityIndicator) {
            // Update to indeterminate indicator
            [indicator removeFromSuperview];
            self.indicator = AGX_AUTORELEASE([[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]);
            [(UIActivityIndicatorView *)indicator startAnimating];
            [self addSubview:indicator];
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
        [(UIActivityIndicatorView *)indicator setColor:self.activityIndicatorColor];
#endif
    }
    else if (mode == AGXProgressHUDModeDeterminateHorizontalBar) {
        // Update to bar determinate indicator
        [indicator removeFromSuperview];
        self.indicator = AGX_AUTORELEASE([[AGXBarProgressView alloc] init]);
        [self addSubview:indicator];
    }
    else if (mode == AGXProgressHUDModeDeterminate || mode == AGXProgressHUDModeAnnularDeterminate) {
        if (!isRoundIndicator) {
            // Update to determinante indicator
            [indicator removeFromSuperview];
            self.indicator = AGX_AUTORELEASE([[AGXRoundProgressView alloc] init]);
            [self addSubview:indicator];
        }
        if (mode == AGXProgressHUDModeAnnularDeterminate) {
            [(AGXRoundProgressView *)indicator setAnnular:YES];
        }
    }
    else if (mode == AGXProgressHUDModeCustomView && customView != indicator) {
        // Update custom view indicator
        [indicator removeFromSuperview];
        self.indicator = customView;
        [self addSubview:indicator];
    } else if (mode == AGXProgressHUDModeText) {
        [indicator removeFromSuperview];
        self.indicator = nil;
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Entirely cover the parent view
    UIView *parent = self.superview;
    if (parent) {
        self.frame = parent.bounds;
    }
    CGRect bounds = self.bounds;
    
    // Determine the total widt and height needed
    CGFloat maxWidth = bounds.size.width - 4 * margin;
    CGSize totalSize = CGSizeZero;
    
    CGRect indicatorF = indicator.bounds;
    indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
    totalSize.width = MAX(totalSize.width, indicatorF.size.width);
    totalSize.height += indicatorF.size.height;
    
    CGSize labelSize = AGX_TEXTSIZE(label.text, label.font);
    labelSize.width = MIN(labelSize.width, maxWidth);
    totalSize.width = MAX(totalSize.width, labelSize.width);
    totalSize.height += labelSize.height;
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        totalSize.height += kPadding;
    }
    
    CGFloat remainingHeight = bounds.size.height - totalSize.height - kPadding - 4 * margin;
    CGSize maxSize = CGSizeMake(maxWidth, remainingHeight);
    CGSize detailsLabelSize = AGX_MULTILINE_TEXTSIZE
    (detailsLabel.text, detailsLabel.font, maxSize, detailsLabel.lineBreakMode);
    totalSize.width = MAX(totalSize.width, detailsLabelSize.width);
    totalSize.height += detailsLabelSize.height;
    if (detailsLabelSize.height > 0.f && (indicatorF.size.height > 0.f || labelSize.height > 0.f)) {
        totalSize.height += kPadding;
    }
    
    totalSize.width += 2 * margin;
    totalSize.height += 2 * margin;
    
    // Position elements
    CGFloat yPos = round(((bounds.size.height - totalSize.height) / 2)) + margin + yOffset;
    CGFloat xPos = xOffset;
    indicatorF.origin.y = yPos;
    indicatorF.origin.x = round((bounds.size.width - indicatorF.size.width) / 2) + xPos;
    indicator.frame = indicatorF;
    yPos += indicatorF.size.height;
    
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        yPos += kPadding;
    }
    CGRect labelF;
    labelF.origin.y = yPos;
    labelF.origin.x = round((bounds.size.width - labelSize.width) / 2) + xPos;
    labelF.size = labelSize;
    label.frame = labelF;
    yPos += labelF.size.height;
    
    if (detailsLabelSize.height > 0.f && (indicatorF.size.height > 0.f || labelSize.height > 0.f)) {
        yPos += kPadding;
    }
    CGRect detailsLabelF;
    detailsLabelF.origin.y = yPos;
    detailsLabelF.origin.x = round((bounds.size.width - detailsLabelSize.width) / 2) + xPos;
    detailsLabelF.size = detailsLabelSize;
    detailsLabel.frame = detailsLabelF;
    
    // Enforce minsize and quare rules
    if (square) {
        CGFloat max = MAX(totalSize.width, totalSize.height);
        if (max <= bounds.size.width - 2 * margin) {
            totalSize.width = max;
        }
        if (max <= bounds.size.height - 2 * margin) {
            totalSize.height = max;
        }
    }
    if (totalSize.width < minSize.width) {
        totalSize.width = minSize.width;
    }
    if (totalSize.height < minSize.height) {
        totalSize.height = minSize.height;
    }
    
    size = totalSize;
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (self.dimBackground) {
        //Gradient colours
        size_t gradLocationsNum = 2;
        CGFloat gradLocations[2] = {0.0f, 1.0f};
        CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
        CGColorSpaceRelease(colorSpace);
        //Gradient center
        CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        //Gradient radius
        float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter,
                                     0, gradCenter, gradRadius,
                                     kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
    }
    
    // Set background rect color
    if (self.color) {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
    } else {
        CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    }
    
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD backgroud rect
    CGRect boxRect = CGRectMake(round((allRect.size.width - size.width) / 2) + self.xOffset,
                                round((allRect.size.height - size.height) / 2) + self.yOffset, size.width, size.height);
    float radius = self.cornerRadius;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"mode", @"customView", @"labelText", @"labelFont", @"labelColor",
            @"detailsLabelText", @"detailsLabelFont", @"detailsLabelColor", @"progress", @"activityIndicatorColor", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    } else {
        [self updateUIForKeypath:keyPath];
    }
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"mode"] || [keyPath isEqualToString:@"customView"] ||
        [keyPath isEqualToString:@"activityIndicatorColor"]) {
        [self updateIndicators];
    } else if ([keyPath isEqualToString:@"labelText"]) {
        label.text = self.labelText;
    } else if ([keyPath isEqualToString:@"labelFont"]) {
        label.font = self.labelFont;
    } else if ([keyPath isEqualToString:@"labelColor"]) {
        label.textColor = self.labelColor;
    } else if ([keyPath isEqualToString:@"detailsLabelText"]) {
        detailsLabel.text = self.detailsLabelText;
    } else if ([keyPath isEqualToString:@"detailsLabelFont"]) {
        detailsLabel.font = self.detailsLabelFont;
    } else if ([keyPath isEqualToString:@"detailsLabelColor"]) {
        detailsLabel.textColor = self.detailsLabelColor;
    } else if ([keyPath isEqualToString:@"progress"]) {
        if ([indicator respondsToSelector:@selector(setProgress:)]) {
            [(id)indicator setValue:@(progress) forKey:@"progress"];
        }
        return;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)registerForNotifications {
#if !TARGET_OS_TV
    AGXAddNotification(statusBarOrientationDidChange:, UIApplicationDidChangeStatusBarOrientationNotification);
#endif
}

- (void)unregisterFromNotifications {
#if !TARGET_OS_TV
    AGXRemoveNotification(UIApplicationDidChangeStatusBarOrientationNotification);
#endif
}

#if !TARGET_OS_TV
- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else {
        [self updateForCurrentOrientationAnimated:YES];
    }
}
#endif

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    // Not needed on iOS 8+, compile out when the deployment target allows,
    // to avoid sharedApplication problems on extension targets
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // Only needed pre iOS 7 when added to a window
    BOOL iOS8OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]]) return;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
        else { radians = (CGFloat)M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
        else { radians = 0; }
    }
    rotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    [self setTransform:rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
#endif
}

@end

@implementation AGXRoundProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _annular = NO;
        _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
        [self registerForKVO];
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromKVO];
    AGX_RELEASE(_progressTintColor);
    AGX_RELEASE(_backgroundTintColor);
    AGX_SUPER_DEALLOC;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_annular) {
        // Draw background
        BOOL isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
        CGFloat lineWidth = isPreiOS7 ? 5.f : 2.f;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = (self.bounds.size.width - lineWidth)/2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_backgroundTintColor set];
        [processBackgroundPath stroke];
        // Draw progress
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = isPreiOS7 ? kCGLineCapRound : kCGLineCapSquare;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressTintColor set];
        [processPath stroke];
    } else {
        // Draw background
        [_progressTintColor setStroke];
        [_backgroundTintColor setFill];
        CGContextSetLineWidth(context, 2.0f);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // Draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (allRect.size.width - 4) / 2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [_progressTintColor setFill];
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"progressTintColor", @"backgroundTintColor", @"progress", @"annular", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

@end

@implementation AGXBarProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(.0f, .0f, 120.0f, 20.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.f;
        _lineColor = [UIColor whiteColor];
        _progressColor = [UIColor whiteColor];
        _progressRemainingColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self registerForKVO];
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromKVO];
    AGX_RELEASE(_lineColor);
    AGX_RELEASE(_progressColor);
    AGX_RELEASE(_progressRemainingColor);
    AGX_SUPER_DEALLOC;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context,[_lineColor CGColor]);
    CGContextSetFillColorWithColor(context, [_progressRemainingColor CGColor]);
    
    // Draw background
    float radius = (rect.size.height / 2) - 2;
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextFillPath(context);
    
    // Draw border
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [_progressColor CGColor]);
    radius = radius - 2;
    float amount = self.progress * rect.size.width;
    
    // Progress in the middle area
    if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, amount, 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, amount, rect.size.height - 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextFillPath(context);
    }
    
    // Progress in the right arc
    else if (amount > radius + 4) {
        float x = amount - (rect.size.width - radius - 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, 4);
        float angle = -acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height/2, radius, M_PI, angle, 0);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, rect.size.height - 4);
        angle = acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height/2, radius, -M_PI, angle, 1);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextFillPath(context);
    }
    
    // Progress is in the left arc
    else if (amount < radius + 4 && amount > 0) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextFillPath(context);
    }
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"lineColor", @"progressRemainingColor", @"progressColor", @"progress", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

@end

#pragma mark - categories implementations

@category_implementation(UIView, AGXHUD)

- (AGXProgressHUD *)agxProgressHUD {
    AGXProgressHUD *hud = [AGXProgressHUD HUDForView:self];
    if (!hud) {
        hud = AGX_AUTORELEASE([[AGXProgressHUD alloc] initWithView:self]);
        hud.square = YES;
        hud.animationType = AGXProgressHUDAnimationFade;
        hud.removeFromSuperViewOnHide = YES;
        [self addSubview:hud];
    }
    return hud;
}

- (void)showIndeterminateHUDWithText:(NSString *)text {
    AGXProgressHUD *hud = [self agxProgressHUD];
    hud.mode = AGXProgressHUDModeIndeterminate;
    hud.labelText = text;
    hud.detailsLabelText = nil;
    [hud show:YES];
}

- (void)showTextHUDWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showTextHUDWithText:text detailText:nil hideAfterDelay:delay];
}

- (void)showTextHUDWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    AGXProgressHUD *hud = [self agxProgressHUD];
    hud.mode = AGXProgressHUDModeText;
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

- (void)hideHUD:(BOOL)animated {
    [[self agxProgressHUD] hide:animated];
}

- (UIFont *)hudLabelFont {
    return [self agxProgressHUD].labelFont;
}

- (void)setHudLabelFont:(UIFont *)hudLabelFont {
    [self agxProgressHUD].labelFont = hudLabelFont;
}

- (UIFont *)hudDetailsLabelFont {
    return [self agxProgressHUD].detailsLabelFont;
}

- (void)setHudDetailsLabelFont:(UIFont *)hudDetailsLabelFont {
    [self agxProgressHUD].detailsLabelFont = hudDetailsLabelFont;
}

@end

@category_implementation(UIView, AGXHUDRecursive)

- (AGXProgressHUD *)recursiveAGXProgressHUD {
    NSEnumerator *subviewsEnum = [self.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:[AGXProgressHUD class]]) {
            return (AGXProgressHUD *)subview;
        } else {
            AGXProgressHUD *hud = [subview recursiveAGXProgressHUD];
            if (hud) return hud;
        }
    }
    return nil;
}

#define SELF_AGXProgressHUD ([self recursiveAGXProgressHUD] ?: [self agxProgressHUD])

- (void)showIndeterminateRecursiveHUDWithText:(NSString *)text {
    AGXProgressHUD *hud = SELF_AGXProgressHUD;
    hud.mode = AGXProgressHUDModeIndeterminate;
    hud.labelText = text;
    hud.detailsLabelText = nil;
    [hud show:YES];
}

- (void)showTextRecursiveHUDWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showTextRecursiveHUDWithText:text detailText:nil hideAfterDelay:delay];
}

- (void)showTextRecursiveHUDWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    AGXProgressHUD *hud = SELF_AGXProgressHUD;
    hud.mode = AGXProgressHUDModeText;
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

- (void)hideRecursiveHUD:(BOOL)animated {
    [SELF_AGXProgressHUD hide:animated];
}

- (UIFont *)recursiveHudLabelFont {
    return SELF_AGXProgressHUD.labelFont;
}

- (void)setRecursiveHudLabelFont:(UIFont *)recursiveHudLabelFont {
    SELF_AGXProgressHUD.labelFont = recursiveHudLabelFont;
}

- (UIFont *)recursiveHudDetailsLabelFont {
    return SELF_AGXProgressHUD.detailsLabelFont;
}

- (void)setRecursiveHudDetailsLabelFont:(UIFont *)recursiveHudDetailsLabelFont {
    SELF_AGXProgressHUD.detailsLabelFont = recursiveHudDetailsLabelFont;
}

@end