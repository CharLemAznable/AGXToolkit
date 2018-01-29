//
//  UICollectionView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2018/1/29.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import "UICollectionView+AGXCore.h"

@category_implementation(UICollectionView, AGXCore)

- (void)scrollToFirstItem:(BOOL)animated {
    NSInteger sectionCount = self.numberOfSections;
    if (sectionCount < 1) return;
    NSInteger itemCount = [self numberOfItemsInSection:0];
    if (itemCount < 1) return;
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                 atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
}

- (void)scrollToLastItem:(BOOL)animated {
    NSInteger sectionCount = self.numberOfSections;
    if (sectionCount < 1) return;
    NSInteger itemCount = [self numberOfItemsInSection:sectionCount-1];
    if (itemCount < 1) return;
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:itemCount-1 inSection:sectionCount-1]
                 atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
}

@end
