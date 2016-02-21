//
//  UIView+AGXLayout.h
//  AGXLayout
//
//  Created by Char Aznable on 16/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import <AGXCore/AGXCore/AGXArc.h>

@class AGXLayoutTransform;

@category_interface(UIView, AGXLayout)
@property (nonatomic, AGX_STRONG) AGXLayoutTransform *agxTransform; // animatable.

@property (nonatomic, AGX_STRONG) id agxLeft; // animatable.
@property (nonatomic, AGX_STRONG) id agxRight; // animatable.
@property (nonatomic, AGX_STRONG) id agxTop; // animatable.
@property (nonatomic, AGX_STRONG) id agxBottom; // animatable.
@property (nonatomic, AGX_STRONG) id agxWidth; // animatable.
@property (nonatomic, AGX_STRONG) id agxHeight; // animatable.
@property (nonatomic, AGX_STRONG) id agxCenterX; // animatable.
@property (nonatomic, AGX_STRONG) id agxCenterY; // animatable.
@property (nonatomic, AGX_WEAK) UIView *agxLayoutView;

- (AGX_INSTANCETYPE)initWithLayoutTransform:(AGXLayoutTransform *)transform;
@end
