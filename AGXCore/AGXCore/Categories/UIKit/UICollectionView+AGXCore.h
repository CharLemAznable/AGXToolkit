//
//  UICollectionView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2018/1/29.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UICollectionView_AGXCore_h
#define AGXCore_UICollectionView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UICollectionView, AGXCore)
- (void)scrollToFirstItem:(BOOL)animated;
- (void)scrollToLastItem:(BOOL)animated;
@end

#endif /* AGXCore_UICollectionView_AGXCore_h */
