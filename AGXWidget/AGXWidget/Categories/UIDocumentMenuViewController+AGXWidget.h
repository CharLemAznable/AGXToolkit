//
//  UIDocumentMenuViewController+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 17/7/27.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_UIDocumentMenuViewController_AGXWidget_h
#define AGXWidget_UIDocumentMenuViewController_AGXWidget_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@interface UIDocumentMenuViewController (AGXWidget)
+ (NSString *)menuOptionFilter;
+ (void)setMenuOptionFilter:(NSString *)menuOptionFilter;
@end

#endif /* AGXWidget_UIDocumentMenuViewController_AGXWidget_h */
