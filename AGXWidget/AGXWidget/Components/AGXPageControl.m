//
//  AGXPageControl.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import "AGXPageControl.h"

@interface AGXPageControl () {
    UIImage *_pageIndicatorImage;
    UIImage *_currentPageIndicatorImage;
}
@end

@implementation AGXPageControl

- (void)layoutSubviews {
    [super layoutSubviews];

    for (int i = 0; i < [self.subviews count]; i++) {
        UIImageView *dot = [self.subviews objectAtIndex:i];
        if ([dot isKindOfClass:[UIImageView class]]) {
            if (i == self.currentPage && _currentPageIndicatorColor) {
                dot.image = _currentPageIndicatorImage;
            } else if (_pageIndicatorColor) {
                dot.image = _pageIndicatorImage;
            }
        } else {
            if (i == self.currentPage && _currentPageIndicatorColor) {
                dot.backgroundColor = _currentPageIndicatorColor;
            } else if (_pageIndicatorColor) {
                dot.backgroundColor = _pageIndicatorColor;
            }
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    [self setNeedsLayout];
}

- (void)dealloc {
    AGX_RELEASE(_pageIndicatorColor);
    AGX_RELEASE(_currentPageIndicatorColor);
    AGX_RELEASE(_pageIndicatorImage);
    AGX_RELEASE(_currentPageIndicatorImage);
    AGX_SUPER_DEALLOC;
}

- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor {
    if AGX_EXPECT_F([_pageIndicatorColor isEqual:pageIndicatorColor]) return;

    AGX_RELEASE(_pageIndicatorColor);
    _pageIndicatorColor = AGX_RETAIN(pageIndicatorColor);

    AGX_RELEASE(_pageIndicatorImage);
    _pageIndicatorImage = AGX_RETAIN([UIImage imageEllipseWithColor:_pageIndicatorColor
                                                               size:CGSizeMake(20, 20)]);
}

- (void)setCurrentPageIndicatorColor:(UIColor *)currentPageIndicatorColor {
    if AGX_EXPECT_F([_currentPageIndicatorColor isEqual:currentPageIndicatorColor]) return;

    AGX_RELEASE(_currentPageIndicatorColor);
    _currentPageIndicatorColor = AGX_RETAIN(currentPageIndicatorColor);

    AGX_RELEASE(_currentPageIndicatorImage);
    _currentPageIndicatorImage = AGX_RETAIN([UIImage imageEllipseWithColor:_currentPageIndicatorColor
                                                                      size:CGSizeMake(20, 20)]);
}

@end
