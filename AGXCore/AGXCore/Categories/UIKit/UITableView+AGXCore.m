//
//  UITableView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "UITableView+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "UIView+AGXCore.h"

@category_implementation(UITableView, AGXCore)

- (void)scrollToTop:(BOOL)animated {
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)scrollToBottom:(BOOL)animated {
    NSInteger lastSectionIndex = self.numberOfSections-1;
    if (lastSectionIndex < 0) return;
    NSInteger lastRowIndex = [self numberOfRowsInSection:lastSectionIndex]-1;
    if (lastRowIndex < 0) return;
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex]
                atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

+ (void)initialize {
    if (self == [UITableView class]) {
        // default disabled AutomaticDimension
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
    }
}

@end
