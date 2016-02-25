//
//  AGXLabel.h
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXLabel_h
#define AGXWidget_AGXLabel_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXLabelDataSource;

@interface AGXLabel : UILabel
@property (nonatomic, AGX_WEAK) id<AGXLabelDataSource> dataSource;
@property (nonatomic, assign, getter=canCopy) BOOL canCopy;
@property (nonatomic, assign) CGFloat linesSpacing;
@end

@protocol AGXLabelDataSource <NSObject>
@optional
- (NSString *)menuTitleStringOfCopyInLabel:(AGXLabel *)label;
- (CGPoint)menuLocationPointInLabel:(AGXLabel *)label;
@end

#endif /* AGXWidget_AGXLabel_h */
