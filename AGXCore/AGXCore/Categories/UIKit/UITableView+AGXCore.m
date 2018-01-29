//
//  UITableView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "UITableView+AGXCore.h"

@category_implementation(UITableView, AGXCore)

- (void)scrollToFirstRow:(BOOL)animated {
    NSInteger sectionCount = self.numberOfSections;
    if (sectionCount < 1) return;
    NSInteger rowCount = [self numberOfRowsInSection:0];
    if (rowCount < 1) return;
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)scrollToLastRow:(BOOL)animated {
    NSInteger sectionCount = self.numberOfSections;
    if (sectionCount < 1) return;
    NSInteger rowCount = [self numberOfRowsInSection:sectionCount-1];
    if (rowCount < 1) return;
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowCount-1 inSection:sectionCount-1]
                atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

+ (void)initialize {
    if ([UITableView class] == self) {
        // default disabled AutomaticDimension
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
    }
}

@end
