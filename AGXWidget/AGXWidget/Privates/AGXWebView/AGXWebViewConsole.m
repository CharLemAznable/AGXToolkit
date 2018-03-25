//
//  AGXWebViewConsole.m
//  AGXWidget
//
//  Created by Char Aznable on 2017/12/12.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIControl+AGXCore.h>
#import <AGXCore/AGXCore/UIButton+AGXCore.h>
#import <AGXCore/AGXCore/UILabel+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIImageView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXWebViewConsole.h"
#import "AGXLine.h"
#import "UIView+AGXWidgetAnimation.h"

static NSString *const AGXWebViewConsoleLogCellReuseIdentifier = @"AGXWebViewConsoleLogCell";

static const float AGXWebViewConsoleOpacity = .8;
static const CGFloat AGXWebViewConsoleButtonImageEdge = 20;
static const CGFloat AGXWebViewConsoleButtonEdge = 28;
static const CGFloat AGXWebViewConsoleToolbarHeight = 44;
static const CGFloat AGXWebViewConsoleLogCellXMargin = 12;
static const CGFloat AGXWebViewConsoleLogCellYMargin = 8;
static const CGFloat AGXWebViewConsoleToolbarIPhoneXOffset = 44;

static const AGXAnimation AGXHideLogConsoleAnimation =
{ .type = AGXAnimateFade|AGXAnimateOut|AGXAnimateNotReset,
    .direction = AGXAnimateStay, .duration = .2, .delay = 0 };
static const AGXAnimation AGXShowLogConsoleAnimation =
{ .type = AGXAnimateFade, .direction = AGXAnimateStay, .duration = .2, .delay = 0 };

static const NSInteger MAX_LOG_COUNT = 256;

@interface AGXWebViewConsoleLog : NSObject
@property (nonatomic, readonly) AGXWebViewLogLevel level;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *stackInfo;
@property (nonatomic, assign)   BOOL showStack;

+ (AGX_INSTANCETYPE)consoleLogWithLogLevel:(AGXWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack;
- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack;
@end

@interface AGXWebViewConsoleLogCell : UITableViewCell
@property (nonatomic, AGX_STRONG) AGXWebViewConsoleLog *consoleLog;

+ (CGSize)sizeBriefWithMessageString:(NSString *)message forWidth:(CGFloat)width;
+ (CGSize)sizeFullWithMessageString:(NSString *)message forWidth:(CGFloat)width;
+ (CGSize)sizeWithStackInfoString:(NSString *)stackInfo forWidth:(CGFloat)width;
@end

@interface AGXWebViewConsole () <UITableViewDataSource, UITableViewDelegate>
@end
@implementation AGXWebViewConsole {
    BOOL _showLogConsole;

    UIView *_hideLogConsoleView;
    UIButton *_showLogConsoleButton;

    UIView *_showLogConsoleView;
    UITableView *_logTableView;
    UIView *_logToolBar;
    UIButton *_hideLogConsoleButton;
    UIButton *_clearButton;
    UISegmentedControl *_levelSegment;

    NSMutableArray<AGXWebViewConsoleLog *> *_logArray;
    dispatch_queue_t _queue;
}

- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWebViewLogLevel)level {
    if AGX_EXPECT_T(self = [super init]) {
        [self agxInitial];
        _levelSegment.selectedSegmentIndex =
        BETWEEN(level, AGXWebViewLogDebug, AGXWebViewLogError);
    }
    return self;
}

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.clearColor;
    self.opacity = AGXWebViewConsoleOpacity;

    // hide view
    _hideLogConsoleView = [[UIView alloc] init];
    _hideLogConsoleView.backgroundColor = UIColor.clearColor;

    _showLogConsoleButton = [[UIButton alloc] initWithFrame:
                             AGX_CGRectMake(AGXWebViewConsoleButtonEdge, AGXWebViewConsoleButtonEdge)];
    _showLogConsoleButton.cornerRadius = AGXWebViewConsoleButtonEdge/2;
    [_showLogConsoleButton setBackgroundColor:UIColor.blackColor
                                     forState:UIControlStateNormal];
    [_showLogConsoleButton setImage:[UIImage imageEllipsisWithColor:UIColor.whiteColor edge:
                                     AGXWebViewConsoleButtonImageEdge]
                           forState:UIControlStateNormal];
    _showLogConsoleButton.acceptEventInterval = 0.3;
    [_showLogConsoleButton addTarget:self action:@selector(showLogConsole:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_hideLogConsoleView addSubview:_showLogConsoleButton];
    // hide view end

    // show view
    _showLogConsoleView = [[UIView alloc] init];
    _showLogConsoleView.backgroundColor = UIColor.blackColor;

    _logTableView = [[UITableView alloc] init];
    _logTableView.delegate = self;
    _logTableView.dataSource = self;
    [_logTableView registerClass:AGXWebViewConsoleLogCell.class
          forCellReuseIdentifier:AGXWebViewConsoleLogCellReuseIdentifier];
    [_showLogConsoleView addSubview:_logTableView];

    _logToolBar = [[UIView alloc] init];
    _logToolBar.backgroundColor = AGXColor(@"2f2f2f");
    _logToolBar.borderColor = UIColor.whiteColor;
    _logToolBar.borderWidth = AGX_SinglePixel;
    [_showLogConsoleView addSubview:_logToolBar];

    _hideLogConsoleButton = [[UIButton alloc] initWithFrame:
                             AGX_CGRectMake(AGXWebViewConsoleButtonEdge, AGXWebViewConsoleButtonEdge)];
    _hideLogConsoleButton.cornerRadius = AGXWebViewConsoleButtonEdge/2;
    [_hideLogConsoleButton setBackgroundColor:UIColor.whiteColor
                                     forState:UIControlStateNormal];
    [_hideLogConsoleButton setImage:[UIImage imageCrossWithColor:AGXColor(@"2f2f2f") edge:
                                     AGXWebViewConsoleButtonImageEdge lineWidth:4]
                           forState:UIControlStateNormal];
    _hideLogConsoleButton.acceptEventInterval = 0.3;
    [_hideLogConsoleButton addTarget:self action:@selector(hideLogConsole:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_logToolBar addSubview:_hideLogConsoleButton];

    _clearButton = [[UIButton alloc] initWithFrame:
                    AGX_CGRectMake(AGXWebViewConsoleButtonEdge, AGXWebViewConsoleButtonEdge)];
    _clearButton.cornerRadius = AGXWebViewConsoleButtonEdge/2;
    [_clearButton setBackgroundColor:UIColor.whiteColor
                            forState:UIControlStateNormal];
    [_clearButton setTitle:@"C" forState:UIControlStateNormal];
    [_clearButton setTitleColor:AGXColor(@"2f2f2f")
                       forState:UIControlStateNormal];
    _clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:AGXWebViewConsoleButtonImageEdge];
    [_clearButton addTarget:self action:@selector(clearLogConsole:)
           forControlEvents:UIControlEventTouchUpInside];
    [_logToolBar addSubview:_clearButton];

    _levelSegment = [[UISegmentedControl alloc] initWithItems:
                     @[NSStringFromWebViewLogLevel(AGXWebViewLogDebug),
                       NSStringFromWebViewLogLevel(AGXWebViewLogInfo),
                       NSStringFromWebViewLogLevel(AGXWebViewLogWarn),
                       NSStringFromWebViewLogLevel(AGXWebViewLogError)]];
    _levelSegment.selectedSegmentIndex = 0;
    _levelSegment.tintColor = UIColor.whiteColor;
    [_levelSegment setTitleTextAttributes:
     @{NSFontAttributeName: [UIFont boldSystemFontOfSize:10],
       NSForegroundColorAttributeName: UIColor.whiteColor
       } forState:UIControlStateNormal];
    [_levelSegment addTarget:self action:@selector(levelSegmentClicked:)
            forControlEvents:UIControlEventValueChanged];
    [_logToolBar addSubview:_levelSegment];
    // show view end

    _logArray = [[NSMutableArray alloc] init];
    _queue = dispatch_queue_create("com.agxwidget.webviewlogqueue", DISPATCH_QUEUE_SERIAL);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_showLogConsole) [self p_layoutShowLogConsoleView];
    else [self p_layoutHideLogConsoleView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    return self != hitView ? hitView : nil;
}

- (void)dealloc {
    _delegate = nil;

    agx_dispatch_release(_queue);
    AGX_RELEASE(_logArray);

    AGX_RELEASE(_levelSegment);
    AGX_RELEASE(_clearButton);
    AGX_RELEASE(_hideLogConsoleButton);
    AGX_RELEASE(_logToolBar);
    AGX_RELEASE(_logTableView);
    AGX_RELEASE(_showLogConsoleView);

    AGX_RELEASE(_showLogConsoleButton);
    AGX_RELEASE(_hideLogConsoleView);

    AGX_SUPER_DEALLOC;
}

- (AGXWebViewLogLevel)javascriptLogLevel {
    return _levelSegment.selectedSegmentIndex;
}

- (void)setJavascriptLogLevel:(AGXWebViewLogLevel)javascriptLogLevel {
    _levelSegment.selectedSegmentIndex =
    BETWEEN(javascriptLogLevel, AGXWebViewLogDebug, AGXWebViewLogError);
}

#pragma mark - user event

- (void)showLogConsole:(id)sender {
    _showLogConsole = YES;
    if AGX_EXPECT_F(!self.superview) return;

    [_hideLogConsoleView agxAnimate:AGXHideLogConsoleAnimation
                         completion:^{ [_hideLogConsoleView removeFromSuperview]; }];
    [self p_layoutShowLogConsoleView];
    [_showLogConsoleView agxAnimate:AGXShowLogConsoleAnimation];
}

- (void)hideLogConsole:(id)sender {
    _showLogConsole = NO;
    if AGX_EXPECT_F(!self.superview) return;

    [_showLogConsoleView agxAnimate:AGXHideLogConsoleAnimation
                         completion:^{ [_showLogConsoleView removeFromSuperview]; }];
    [self p_layoutHideLogConsoleView];
    [_hideLogConsoleView agxAnimate:AGXShowLogConsoleAnimation];
}

- (void)clearLogConsole:(id)sender {
    dispatch_async(_queue, ^{
        [_logArray removeAllObjects];
        agx_async_main
        ([_logTableView reloadData];
         agx_async_main([_logTableView scrollToTop:YES];););
    });
}

- (void)levelSegmentClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(webViewConsole:didSelectSegmentIndex:)])
        [self.delegate webViewConsole:self didSelectSegmentIndex:_levelSegment.selectedSegmentIndex];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGXWebViewConsoleLogCell *cell = [tableView dequeueReusableCellWithIdentifier:AGXWebViewConsoleLogCellReuseIdentifier
                                                                     forIndexPath:indexPath];
    cell.consoleLog = _logArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat tableWidth = tableView.bounds.size.width;
    AGXWebViewConsoleLog *consoleLog = _logArray[indexPath.row];
    if (!consoleLog.showStack) return([AGXWebViewConsoleLogCell sizeBriefWithMessageString:consoleLog.message forWidth:
                                       tableWidth-AGXWebViewConsoleLogCellXMargin*2].height+AGXWebViewConsoleLogCellYMargin*2);
    return([AGXWebViewConsoleLogCell sizeFullWithMessageString:consoleLog.message forWidth:
            tableWidth-AGXWebViewConsoleLogCellXMargin*2].height
           +[AGXWebViewConsoleLogCell sizeWithStackInfoString:consoleLog.stackInfo forWidth:
             tableWidth-AGXWebViewConsoleLogCellXMargin*3].height
           +AGXWebViewConsoleLogCellYMargin*3);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _logArray[indexPath.row].showStack = !_logArray[indexPath.row].showStack;
    [tableView reloadData];
}

#pragma mark - public methods

- (void)addLogLevel:(AGXWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack {
    dispatch_async(_queue, ^{
        [_logArray addObject:[AGXWebViewConsoleLog consoleLogWithLogLevel:level message:message stack:stack]];
        if (_logArray.count > MAX_LOG_COUNT) [_logArray removeObjectAtIndex:0];
        agx_async_main
        ([_logTableView reloadData];
         agx_async_main([_logTableView scrollToBottom:YES];););
    });
}

#pragma mark - private methods

- (void)p_layoutShowLogConsoleView {
    CGFloat offset = AGX_IS_IPHONEX ? AGXWebViewConsoleToolbarIPhoneXOffset : 0;
    _showLogConsoleView.frame = self.bounds;
    [self addSubview:_showLogConsoleView];

    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    _logTableView.frame = AGX_CGRectMake(width, height-AGXWebViewConsoleToolbarHeight-offset);
    _logTableView.backgroundColor = UIColor.clearColor;
    _logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _logTableView.tableHeaderView = [UIView instance];
    _logTableView.tableFooterView = [UIView instance];
    _logToolBar.frame = CGRectMake(0, height-AGXWebViewConsoleToolbarHeight-offset,
                                   width, AGXWebViewConsoleToolbarHeight+offset);
    _hideLogConsoleButton.center = CGPointMake(AGXWebViewConsoleToolbarHeight/2,
                                               AGXWebViewConsoleToolbarHeight/2);
    _clearButton.center = CGPointMake(width-AGXWebViewConsoleToolbarHeight/2,
                                      AGXWebViewConsoleToolbarHeight/2);
    [_levelSegment sizeToFit];
    _levelSegment.center = CGPointMake(width-AGXWebViewConsoleToolbarHeight
                                       -_levelSegment.bounds.size.width/2,
                                       AGXWebViewConsoleToolbarHeight/2);
}

- (void)p_layoutHideLogConsoleView {
    CGFloat offset = AGX_IS_IPHONEX ? AGXWebViewConsoleToolbarIPhoneXOffset : 0;
    _hideLogConsoleView.frame = CGRectMake(0, self.bounds.size.height-AGXWebViewConsoleToolbarHeight-offset,
                                           AGXWebViewConsoleToolbarHeight, AGXWebViewConsoleToolbarHeight);
    [self addSubview:_hideLogConsoleView];

    _showLogConsoleButton.center = CGPointMake(AGXWebViewConsoleToolbarHeight/2,
                                               AGXWebViewConsoleToolbarHeight/2);
}

@end

@implementation AGXWebViewConsoleLog

+ (AGX_INSTANCETYPE)consoleLogWithLogLevel:(AGXWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack {
    return AGX_AUTORELEASE([[self alloc] initWithLogLevel:level message:message stack:stack]);
}

- (AGX_INSTANCETYPE)init {
    return [self initWithLogLevel:AGXWebViewLogError message:@"Unknown Error" stack:@[]];
}

- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack {
    if AGX_EXPECT_T(self = [super init]) {
        _level = level;
        _message = [message copy];
        _stackInfo = AGX_RETAIN([NSString stringWithArray:stack joinedByString:@"\n"
                                          usingComparator:NULL filterEmpty:YES]);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_stackInfo);
    AGX_RELEASE(_message);
    AGX_SUPER_DEALLOC;
}

@end

@implementation AGXWebViewConsoleLogCell {
    UILabel *_messageLabel;
    UILabel *_stackInfoLabel;
    AGXLine *_bottomLine;
    BOOL _showStack;
}

- (AGX_INSTANCETYPE)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if AGX_EXPECT_T(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _messageLabel = AGX_RETAIN([AGXWebViewConsoleLogCell messageLabelInstance]);
        _messageLabel.numberOfLines = 1;
        [self addSubview:_messageLabel];

        _stackInfoLabel = AGX_RETAIN([AGXWebViewConsoleLogCell stackInfoLabelInstance]);
        [self addSubview:_stackInfoLabel];

        _bottomLine = [[AGXLine alloc] init];
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_consoleLog);
    AGX_RELEASE(_bottomLine);
    AGX_RELEASE(_stackInfoLabel);
    AGX_RELEASE(_messageLabel);
    AGX_SUPER_DEALLOC;
}

- (void)setConsoleLog:(AGXWebViewConsoleLog *)consoleLog {
    AGXWebViewConsoleLog *temp = AGX_RETAIN(consoleLog);
    AGX_RELEASE(_consoleLog);
    _consoleLog = temp;

    self.backgroundColor = AGXWebViewLogError == _consoleLog.level ? AGXColor(@"2f0000") :
    (AGXWebViewLogWarn == _consoleLog.level ? AGXColor(@"2f2f00") : AGXColor(@"2f2f2f"));

    _showStack = _consoleLog.showStack;

    _messageLabel.textColor = AGXWebViewLogError == _consoleLog.level ? AGXColor(@"ff0000") :
    (AGXWebViewLogWarn == _consoleLog.level ? AGXColor(@"ffff00") : UIColor.whiteColor);
    _messageLabel.text = _consoleLog.message;
    _messageLabel.numberOfLines = _showStack ? 0 : 1;

    _stackInfoLabel.textColor = AGXWebViewLogError == _consoleLog.level ? AGXColor(@"ff0000") :
    (AGXWebViewLogWarn == _consoleLog.level ? AGXColor(@"ffff00") : UIColor.whiteColor);
    _stackInfoLabel.text = _consoleLog.stackInfo;
    _stackInfoLabel.hidden = !_showStack;

    _bottomLine.lineColor = AGXWebViewLogError == _consoleLog.level ? AGXColor(@"ff0000") :
    (AGXWebViewLogWarn == _consoleLog.level ? AGXColor(@"ffff00") : UIColor.whiteColor);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    CGSize messageLabelSize = [AGXWebViewConsoleLogCell sizeOfLabel:_messageLabel forWidth:
                               width-AGXWebViewConsoleLogCellXMargin*2];
    _messageLabel.frame = AGX_CGRectMake
    (CGPointMake(AGXWebViewConsoleLogCellXMargin, AGXWebViewConsoleLogCellYMargin), messageLabelSize);

    CGSize stackInfoLabelSize = [AGXWebViewConsoleLogCell sizeOfLabel:_stackInfoLabel forWidth:
                                 width-AGXWebViewConsoleLogCellXMargin*3];
    _stackInfoLabel.frame = AGX_CGRectMake
    (CGPointMake(AGXWebViewConsoleLogCellXMargin*2,
                 messageLabelSize.height+AGXWebViewConsoleLogCellYMargin*2), stackInfoLabelSize);

    _bottomLine.frame = CGRectMake(0, height-AGX_SinglePixel, width, AGX_SinglePixel);
}

#pragma mark - public methods

+ (CGSize)sizeBriefWithMessageString:(NSString *)message forWidth:(CGFloat)width {
    static UILabel *label; agx_once(label = AGX_RETAIN([AGXWebViewConsoleLogCell messageLabelInstance]););
    label.numberOfLines = 1;
    label.text = message;
    return [self sizeOfLabel:label forWidth:width];
}

+ (CGSize)sizeFullWithMessageString:(NSString *)message forWidth:(CGFloat)width {
    static UILabel *label; agx_once(label = AGX_RETAIN([AGXWebViewConsoleLogCell messageLabelInstance]););
    label.numberOfLines = 0;
    label.text = message;
    return [self sizeOfLabel:label forWidth:width];
}

+ (CGSize)sizeWithStackInfoString:(NSString *)stackInfo forWidth:(CGFloat)width {
    static UILabel *label; agx_once(label = AGX_RETAIN([AGXWebViewConsoleLogCell stackInfoLabelInstance]););
    label.text = stackInfo;
    return [self sizeOfLabel:label forWidth:width];
}

#pragma mark - private methods

+ (UILabel *)messageLabelInstance {
    return({
        UILabel *label = UILabel.instance;
        label.backgroundColor = UIColor.clearColor;
        label.font = [UIFont fontWithName:@"Courier-Bold" size:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.linesSpacing = 4; label; });
}

+ (UILabel *)stackInfoLabelInstance {
    return({
        UILabel *label = UILabel.instance;
        label.backgroundColor = UIColor.clearColor;
        label.font = [UIFont fontWithName:@"Courier" size:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.numberOfLines = 0;
        label.linesSpacing = 4;
        label.paragraphSpacing = 8; label; });
}

+ (CGSize)sizeOfLabel:(UILabel *)label forWidth:(CGFloat)width {
    return [label textRectForBounds:AGX_CGRectMake(width, 1000)
             limitedToNumberOfLines:label.numberOfLines].size;
}

@end
