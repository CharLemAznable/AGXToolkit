//
//  UITableView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UITableView_AGXCore_h
#define AGXCore_UITableView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UITableView, AGXCore)
- (void)scrollToFirstRow:(BOOL)animated;
- (void)scrollToLastRow:(BOOL)animated;
@end

#endif /* AGXCore_UITableView_AGXCore_h */
