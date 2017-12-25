//
//  AGXImageView.h
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXImageView_h
#define AGXWidget_AGXImageView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXImageViewDelegate;

@interface AGXImageView : UIImageView
@property (nonatomic, AGX_WEAK) id<AGXImageViewDelegate> delegate;
@property (nonatomic, assign, getter=canCopy) BOOL canCopy;
@property (nonatomic, assign, getter=canSave) BOOL canSave;
@end

@protocol AGXImageViewDelegate <NSObject>
@optional
- (void)saveImageSuccessInImageView:(AGXImageView *)imageView;
- (void)saveImageFailedInImageView:(AGXImageView *)imageView withError:(NSError *)error;
@end

#endif /* AGXWidget_AGXImageView_h */
