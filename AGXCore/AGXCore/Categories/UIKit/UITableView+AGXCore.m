//
//  UITableView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "UITableView+AGXCore.h"

@category_implementation(UITableView, AGXCore)

- (void)scrollToTop:(BOOL)animated {
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)scrollToBottom:(BOOL)animated {
    NSInteger lastSectionIndex = self.numberOfSections-1;
    NSInteger lastRowIndex = [self numberOfRowsInSection:lastSectionIndex]-1;
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex]
                atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

@end
