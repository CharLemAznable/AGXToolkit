//
//  AGXSearchBar.h
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXSearchBar_h
#define AGXWidget_AGXSearchBar_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXSearchBarDelegate;

@interface AGXSearchBar : UIView
@property (nonatomic, AGX_WEAK) id<AGXSearchBarDelegate> delegate;
@property (nonatomic, copy) UIColor *maskBackgroundColor; // default [UIColor clearColor]
@property (nonatomic, AGX_STRONG) UITextField *searchTextField;
@property (nonatomic, copy) NSString *searchText;
@end

@protocol AGXSearchBarDelegate <NSObject>
@optional
- (void)searchBarDidBeginInput:(AGXSearchBar *)searchBar;
- (void)searchBarDidEndInput:(AGXSearchBar *)searchBar;
- (void)searchBar:(AGXSearchBar *)searchBar searchWithText:(NSString *)searchText editEnded:(BOOL)ended;
@end

#endif /* AGXWidget_AGXSearchBar_h */
