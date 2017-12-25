//
//  AGXRefreshView.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
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
@property (nonatomic, assign) AGXRefreshState state;
@property (nonatomic, assign) AGXRefreshPullDirection direction;
@property (nonatomic, assign) CGFloat defaultPadding;
@property (nonatomic, assign) CGFloat pullingMargin;
@property (nonatomic, assign) CGFloat loadingMargin;

- (void)didScrollView:(UIScrollView *)scrollView;
- (void)didEndDragging:(UIScrollView *)scrollView;
- (void)didFinishedLoading:(UIScrollView *)scrollView;
- (void)setRefreshState:(AGXRefreshState)state;
@end

@protocol AGXRefreshViewDelegate <NSObject>
@optional
- (BOOL)refreshViewIsLoading:(AGXRefreshView *)refreshView;
- (void)refreshViewStartLoad:(AGXRefreshView *)refreshView;
@end

#endif /* AGXWidget_AGXRefreshView_h */
