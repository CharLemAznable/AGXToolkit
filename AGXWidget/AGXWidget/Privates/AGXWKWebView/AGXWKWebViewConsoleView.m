//
//  AGXWKWebViewConsoleView.m
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/21.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
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
#import "AGXWKWebViewConsoleView.h"
#import "AGXLine.h"
#import "UIView+AGXWidgetAnimation.h"

AGX_STATIC NSString *const AGXWKWebViewConsoleViewLogCellReuseIdentifier = @"AGXWKWebViewConsoleViewLogCell";

AGX_STATIC const float AGXWKWebViewConsoleViewOpacity = .8;
AGX_STATIC const CGFloat AGXWKWebViewConsoleViewButtonImageEdge = 20;
AGX_STATIC const CGFloat AGXWKWebViewConsoleViewButtonEdge = 28;
AGX_STATIC const CGFloat AGXWKWebViewConsoleViewToolbarHeight = 44;
AGX_STATIC const CGFloat AGXWKWebViewConsoleViewLogCellXMargin = 12;
AGX_STATIC const CGFloat AGXWKWebViewConsoleViewLogCellYMargin = 8;

AGX_STATIC const AGXAnimation AGXHideLogConsoleAnimation =
{ .type = AGXAnimateFade|AGXAnimateOut|AGXAnimateNotReset,
    .direction = AGXAnimateStay, .duration = .2, .delay = 0 };
AGX_STATIC const AGXAnimation AGXShowLogConsoleAnimation =
{ .type = AGXAnimateFade, .direction = AGXAnimateStay, .duration = .2, .delay = 0 };

AGX_STATIC const NSInteger MAX_LOG_COUNT = 256;

@interface AGXWKWebViewConsoleViewLog : NSObject
@property (nonatomic, readonly) AGXWKWebViewLogLevel level;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *stackInfo;
@property (nonatomic, assign)   BOOL showStack;

+ (AGX_INSTANCETYPE)logWithLogLevel:(AGXWKWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack;
- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWKWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack;
@end

@interface AGXWKWebViewConsoleViewLogCell : UITableViewCell
@property (nonatomic, AGX_STRONG) AGXWKWebViewConsoleViewLog *log;

+ (CGSize)sizeBriefWithMessageString:(NSString *)message forWidth:(CGFloat)width;
+ (CGSize)sizeFullWithMessageString:(NSString *)message forWidth:(CGFloat)width;
+ (CGSize)sizeWithStackInfoString:(NSString *)stackInfo forWidth:(CGFloat)width;
@end

@interface AGXWKWebViewConsoleView () <UITableViewDataSource, UITableViewDelegate>
@end
@implementation AGXWKWebViewConsoleView {
    BOOL _showLogConsole;

    UIView *_hideLogConsoleView;
    UIButton *_showLogConsoleButton;

    UIView *_showLogConsoleView;
    UIView *_logTopBar;
    UITableView *_logTableView;
    UIView *_logToolBar;
    UIButton *_hideLogConsoleButton;
    UIButton *_clearButton;
    UISegmentedControl *_levelSegment;

    NSMutableArray<AGXWKWebViewConsoleViewLog *> *_logArray;
    dispatch_queue_t _queue;
}

- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWKWebViewLogLevel)level {
    if AGX_EXPECT_T(self = [super init]) {
        [self agxInitial];
        _levelSegment.selectedSegmentIndex =
        BETWEEN(level, AGXWKWebViewLogDebug, AGXWKWebViewLogError);
    }
    return self;
}

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.clearColor;
    self.opacity = AGXWKWebViewConsoleViewOpacity;

    // hide view
    _hideLogConsoleView = [[UIView alloc] init];
    _hideLogConsoleView.backgroundColor = UIColor.clearColor;

    _showLogConsoleButton = [[UIButton alloc] initWithFrame:AGX_CGRectMake
                             (AGXWKWebViewConsoleViewButtonEdge, AGXWKWebViewConsoleViewButtonEdge)];
    _showLogConsoleButton.cornerRadius = AGXWKWebViewConsoleViewButtonEdge/2;
    [_showLogConsoleButton setBackgroundColor:UIColor.blackColor
                                     forState:UIControlStateNormal];
    [_showLogConsoleButton setImage:[UIImage imageEllipsisWithColor:UIColor.whiteColor edge:
                                     AGXWKWebViewConsoleViewButtonImageEdge]
                           forState:UIControlStateNormal];
    _showLogConsoleButton.acceptEventInterval = 0.3;
    [_showLogConsoleButton addTarget:self action:@selector(showLogConsole:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_hideLogConsoleView addSubview:_showLogConsoleButton];
    // hide view end

    // show view
    _showLogConsoleView = [[UIView alloc] init];
    _showLogConsoleView.backgroundColor = UIColor.blackColor;

    _logTopBar = [[UIView alloc] init];
    _logTopBar.backgroundColor = AGXColor(@"2f2f2f");
    [_showLogConsoleView addSubview:_logTopBar];

    _logTableView = [[UITableView alloc] init];
    _logTableView.delegate = self;
    _logTableView.dataSource = self;
    [_logTableView registerClass:AGXWKWebViewConsoleViewLogCell.class
          forCellReuseIdentifier:AGXWKWebViewConsoleViewLogCellReuseIdentifier];
    [_showLogConsoleView addSubview:_logTableView];

    _logToolBar = [[UIView alloc] init];
    _logToolBar.backgroundColor = AGXColor(@"2f2f2f");
    _logToolBar.borderColor = UIColor.whiteColor;
    _logToolBar.borderWidth = AGX_SinglePixel;
    [_showLogConsoleView addSubview:_logToolBar];

    _hideLogConsoleButton = [[UIButton alloc] initWithFrame:AGX_CGRectMake
                             (AGXWKWebViewConsoleViewButtonEdge, AGXWKWebViewConsoleViewButtonEdge)];
    _hideLogConsoleButton.cornerRadius = AGXWKWebViewConsoleViewButtonEdge/2;
    [_hideLogConsoleButton setBackgroundColor:UIColor.whiteColor
                                     forState:UIControlStateNormal];
    [_hideLogConsoleButton setImage:[UIImage imageCrossWithColor:AGXColor(@"2f2f2f") edge:
                                     AGXWKWebViewConsoleViewButtonImageEdge lineWidth:4]
                           forState:UIControlStateNormal];
    _hideLogConsoleButton.acceptEventInterval = 0.3;
    [_hideLogConsoleButton addTarget:self action:@selector(hideLogConsole:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_logToolBar addSubview:_hideLogConsoleButton];

    _clearButton = [[UIButton alloc] initWithFrame:AGX_CGRectMake
                    (AGXWKWebViewConsoleViewButtonEdge, AGXWKWebViewConsoleViewButtonEdge)];
    _clearButton.cornerRadius = AGXWKWebViewConsoleViewButtonEdge/2;
    [_clearButton setBackgroundColor:UIColor.whiteColor
                            forState:UIControlStateNormal];
    [_clearButton setTitle:@"C" forState:UIControlStateNormal];
    [_clearButton setTitleColor:AGXColor(@"2f2f2f")
                       forState:UIControlStateNormal];
    _clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:AGXWKWebViewConsoleViewButtonImageEdge];
    [_clearButton addTarget:self action:@selector(clearLogConsole:)
           forControlEvents:UIControlEventTouchUpInside];
    [_logToolBar addSubview:_clearButton];

    _levelSegment = [[UISegmentedControl alloc] initWithItems:
                     @[NSStringFromWKWebViewLogLevel(AGXWKWebViewLogDebug),
                       NSStringFromWKWebViewLogLevel(AGXWKWebViewLogInfo),
                       NSStringFromWKWebViewLogLevel(AGXWKWebViewLogWarn),
                       NSStringFromWKWebViewLogLevel(AGXWKWebViewLogError)]];
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
    _queue = dispatch_queue_create("com.agxwidget.wkwebviewlogqueue", DISPATCH_QUEUE_SERIAL);
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
    AGX_RELEASE(_logTopBar);
    AGX_RELEASE(_showLogConsoleView);

    AGX_RELEASE(_showLogConsoleButton);
    AGX_RELEASE(_hideLogConsoleView);

    AGX_SUPER_DEALLOC;
}

- (void)setLayoutContentInset:(UIEdgeInsets)layoutContentInset {
    _layoutContentInset = layoutContentInset;
    [self setNeedsLayout];
}

- (AGXWKWebViewLogLevel)javascriptLogLevel {
    return _levelSegment.selectedSegmentIndex;
}

- (void)setJavascriptLogLevel:(AGXWKWebViewLogLevel)javascriptLogLevel {
    _levelSegment.selectedSegmentIndex =
    BETWEEN(javascriptLogLevel, AGXWKWebViewLogDebug, AGXWKWebViewLogError);
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
    if ([_delegate respondsToSelector:@selector(webViewConsoleView:didSelectSegmentIndex:)])
        [_delegate webViewConsoleView:self didSelectSegmentIndex:_levelSegment.selectedSegmentIndex];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGXWKWebViewConsoleViewLogCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                            AGXWKWebViewConsoleViewLogCellReuseIdentifier forIndexPath:indexPath];
    cell.log = _logArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat tableWidth = tableView.bounds.size.width;
    AGXWKWebViewConsoleViewLog *log = _logArray[indexPath.row];
    if (!log.showStack) return([AGXWKWebViewConsoleViewLogCell sizeBriefWithMessageString:log.message forWidth:
                                tableWidth-AGXWKWebViewConsoleViewLogCellXMargin*2]
                               .height+AGXWKWebViewConsoleViewLogCellYMargin*2);
    return([AGXWKWebViewConsoleViewLogCell sizeFullWithMessageString:log.message forWidth:
            tableWidth-AGXWKWebViewConsoleViewLogCellXMargin*2].height
           +[AGXWKWebViewConsoleViewLogCell sizeWithStackInfoString:log.stackInfo forWidth:
             tableWidth-AGXWKWebViewConsoleViewLogCellXMargin*3].height
           +AGXWKWebViewConsoleViewLogCellYMargin*3);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _logArray[indexPath.row].showStack = !_logArray[indexPath.row].showStack;
    [tableView reloadData];
}

#pragma mark - public methods

- (void)addLogLevel:(AGXWKWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack {
    dispatch_async(_queue, ^{
        [_logArray addObject:[AGXWKWebViewConsoleViewLog logWithLogLevel:level message:message stack:stack]];
        if (_logArray.count > MAX_LOG_COUNT) [_logArray removeObjectAtIndex:0];
        agx_async_main
        ([_logTableView reloadData];
         agx_async_main([_logTableView scrollToBottom:YES];););
    });
}

#pragma mark - private methods

- (void)p_layoutShowLogConsoleView {
    _showLogConsoleView.frame = self.bounds;
    [self addSubview:_showLogConsoleView];

    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    _logTopBar.frame = AGX_CGRectMake(width, _layoutContentInset.top);
    _logTableView.frame = UIEdgeInsetsInsetRect(UIEdgeInsetsInsetRect(_showLogConsoleView.frame, _layoutContentInset),
                                                UIEdgeInsetsMake(0, 0, AGXWKWebViewConsoleViewToolbarHeight, 0));
    _logTableView.backgroundColor = UIColor.clearColor;
    _logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _logTableView.tableHeaderView = [UIView instance];
    _logTableView.tableFooterView = [UIView instance];
    _logToolBar.frame = CGRectMake(0, height-_layoutContentInset.bottom-AGXWKWebViewConsoleViewToolbarHeight,
                                   width, AGXWKWebViewConsoleViewToolbarHeight+_layoutContentInset.bottom);
    _hideLogConsoleButton.center = CGPointMake(_layoutContentInset.left+AGXWKWebViewConsoleViewToolbarHeight/2,
                                               AGXWKWebViewConsoleViewToolbarHeight/2);
    _clearButton.center = CGPointMake(width-_layoutContentInset.right-AGXWKWebViewConsoleViewToolbarHeight/2,
                                      AGXWKWebViewConsoleViewToolbarHeight/2);
    [_levelSegment sizeToFit];
    _levelSegment.center = CGPointMake(width-_layoutContentInset.right-AGXWKWebViewConsoleViewToolbarHeight
                                       -_levelSegment.bounds.size.width/2,
                                       AGXWKWebViewConsoleViewToolbarHeight/2);
}

- (void)p_layoutHideLogConsoleView {
    _hideLogConsoleView.frame = CGRectMake
    (0, self.bounds.size.height-_layoutContentInset.bottom-AGXWKWebViewConsoleViewToolbarHeight,
     AGXWKWebViewConsoleViewToolbarHeight, AGXWKWebViewConsoleViewToolbarHeight);
    [self addSubview:_hideLogConsoleView];

    _showLogConsoleButton.center = CGPointMake(AGXWKWebViewConsoleViewToolbarHeight/2,
                                               AGXWKWebViewConsoleViewToolbarHeight/2);
}

@end

@implementation AGXWKWebViewConsoleViewLog

+ (AGX_INSTANCETYPE)logWithLogLevel:(AGXWKWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack {
    return AGX_AUTORELEASE([[self alloc] initWithLogLevel:level message:message stack:stack]);
}

- (AGX_INSTANCETYPE)init {
    return [self initWithLogLevel:AGXWKWebViewLogError message:@"Unknown Error" stack:@[]];
}

- (AGX_INSTANCETYPE)initWithLogLevel:(AGXWKWebViewLogLevel)level message:(NSString *)message stack:(NSArray *)stack {
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

@implementation AGXWKWebViewConsoleViewLogCell {
    UILabel *_messageLabel;
    UILabel *_stackInfoLabel;
    AGXLine *_bottomLine;
    BOOL _showStack;
}

- (AGX_INSTANCETYPE)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if AGX_EXPECT_T(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _messageLabel = AGX_RETAIN([AGXWKWebViewConsoleViewLogCell messageLabelInstance]);
        _messageLabel.numberOfLines = 1;
        [self addSubview:_messageLabel];

        _stackInfoLabel = AGX_RETAIN([AGXWKWebViewConsoleViewLogCell stackInfoLabelInstance]);
        [self addSubview:_stackInfoLabel];

        _bottomLine = [[AGXLine alloc] init];
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_log);
    AGX_RELEASE(_bottomLine);
    AGX_RELEASE(_stackInfoLabel);
    AGX_RELEASE(_messageLabel);
    AGX_SUPER_DEALLOC;
}

- (void)setLog:(AGXWKWebViewConsoleViewLog *)log {
    AGXWKWebViewConsoleViewLog *temp = AGX_RETAIN(log);
    AGX_RELEASE(_log);
    _log = temp;

    self.backgroundColor = AGXWKWebViewLogError == _log.level ? AGXColor(@"2f0000") :
    (AGXWKWebViewLogWarn == _log.level ? AGXColor(@"2f2f00") : AGXColor(@"2f2f2f"));

    _showStack = _log.showStack;

    _messageLabel.textColor = AGXWKWebViewLogError == _log.level ? AGXColor(@"ff0000") :
    (AGXWKWebViewLogWarn == _log.level ? AGXColor(@"ffff00") : UIColor.whiteColor);
    _messageLabel.text = _log.message;
    _messageLabel.numberOfLines = _showStack ? 0 : 1;

    _stackInfoLabel.textColor = AGXWKWebViewLogError == _log.level ? AGXColor(@"ff0000") :
    (AGXWKWebViewLogWarn == _log.level ? AGXColor(@"ffff00") : UIColor.whiteColor);
    _stackInfoLabel.text = _log.stackInfo;
    _stackInfoLabel.hidden = !_showStack;

    _bottomLine.lineColor = AGXWKWebViewLogError == _log.level ? AGXColor(@"ff0000") :
    (AGXWKWebViewLogWarn == _log.level ? AGXColor(@"ffff00") : UIColor.whiteColor);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    CGSize messageLabelSize = [AGXWKWebViewConsoleViewLogCell sizeOfLabel:_messageLabel forWidth:
                               width-AGXWKWebViewConsoleViewLogCellXMargin*2];
    _messageLabel.frame = AGX_CGRectMake
    (CGPointMake(AGXWKWebViewConsoleViewLogCellXMargin, AGXWKWebViewConsoleViewLogCellYMargin), messageLabelSize);

    CGSize stackInfoLabelSize = [AGXWKWebViewConsoleViewLogCell sizeOfLabel:_stackInfoLabel forWidth:
                                 width-AGXWKWebViewConsoleViewLogCellXMargin*3];
    _stackInfoLabel.frame = AGX_CGRectMake
    (CGPointMake(AGXWKWebViewConsoleViewLogCellXMargin*2,
                 messageLabelSize.height+AGXWKWebViewConsoleViewLogCellYMargin*2), stackInfoLabelSize);

    _bottomLine.frame = CGRectMake(0, height-AGX_SinglePixel, width, AGX_SinglePixel);
}

#pragma mark - public methods

+ (CGSize)sizeBriefWithMessageString:(NSString *)message forWidth:(CGFloat)width {
    AGX_STATIC UILabel *label; agx_once(label = AGX_RETAIN([AGXWKWebViewConsoleViewLogCell messageLabelInstance]););
    label.numberOfLines = 1;
    label.text = message;
    return [self sizeOfLabel:label forWidth:width];
}

+ (CGSize)sizeFullWithMessageString:(NSString *)message forWidth:(CGFloat)width {
    AGX_STATIC UILabel *label; agx_once(label = AGX_RETAIN([AGXWKWebViewConsoleViewLogCell messageLabelInstance]););
    label.numberOfLines = 0;
    label.text = message;
    return [self sizeOfLabel:label forWidth:width];
}

+ (CGSize)sizeWithStackInfoString:(NSString *)stackInfo forWidth:(CGFloat)width {
    AGX_STATIC UILabel *label; agx_once(label = AGX_RETAIN([AGXWKWebViewConsoleViewLogCell stackInfoLabelInstance]););
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
        label.paragraphStyleLinesSpacing = 4; label; });
}

+ (UILabel *)stackInfoLabelInstance {
    return({
        UILabel *label = UILabel.instance;
        label.backgroundColor = UIColor.clearColor;
        label.font = [UIFont fontWithName:@"Courier" size:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.numberOfLines = 0;
        label.paragraphStyleLinesSpacing = 4;
        label.paragraphStyleParagraphSpacing = 8; label; });
}

+ (CGSize)sizeOfLabel:(UILabel *)label forWidth:(CGFloat)width {
    return [label textRectForBounds:AGX_CGRectMake(width, 1000)
             limitedToNumberOfLines:label.numberOfLines].size;
}

@end
