//
//  AGXRefreshView.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXRefreshView_h
#define AGXWidget_AGXRefreshView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

typedef NS_ENUM(NSInteger, AGXRefreshState) {
    AGXRefreshNormal,
    AGXRefreshPulling,
    AGXRefreshLoading,
};
typedef NS_ENUM(NSInteger, AGXRefreshPullDirection) {
    AGXRefreshPullDown,
    AGXRefreshPullUp,
    AGXRefreshPullRight,
    AGXRefreshPullLeft,
};

@protocol AGXRefreshViewDelegate;

@interface AGXRefreshView : UIView
@property (nonatomic, AGX_WEAK) id<AGXRefreshViewDelegate> delegate;
@property (nonatomic, assign)   AGXRefreshPullDirection direction;
@property (nonatomic, assign)   CGFloat defaultPadding;
@property (nonatomic, assign)   CGFloat pullingMargin;
@property (nonatomic, assign)   CGFloat loadingMargin;
@property (nonatomic, assign)   NSTimeInterval insetsUpdateDuration;

- (void)didScrollView:(UIScrollView *)scrollView;
- (void)didEndDragging:(UIScrollView *)scrollView;

- (void)scrollViewStartLoad:(UIScrollView *)scrollView;
- (void)scrollViewFinishLoad:(UIScrollView *)scrollView;
@end

@protocol AGXRefreshViewDelegate <NSObject>
@optional
- (void)refreshViewStartLoad:(AGXRefreshView *)refreshView;
- (void)refreshView:(AGXRefreshView *)refreshView updateState:(AGXRefreshState)state pullingOffset:(CGFloat)offset;
@end

#endif /* AGXWidget_AGXRefreshView_h */
