//
//  AGXLayoutTransform.h
//  AGXLayout
//
//  Created by Char Aznable on 2016/2/21.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXLayout_AGXLayoutTransform_h
#define AGXLayout_AGXLayoutTransform_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXLayoutTransform : NSObject
@property (nonatomic, AGX_WEAK) UIView *view;
@property (nonatomic, AGX_STRONG) id left;
@property (nonatomic, AGX_STRONG) id right;
@property (nonatomic, AGX_STRONG) id top;
@property (nonatomic, AGX_STRONG) id bottom;
@property (nonatomic, AGX_STRONG) id width;
@property (nonatomic, AGX_STRONG) id height;
@property (nonatomic, AGX_STRONG) id centerX;
@property (nonatomic, AGX_STRONG) id centerY;

- (BOOL)isEqualToLayoutTransform:(AGXLayoutTransform *)transform;
- (CGRect)transformRect;
@end

#endif /* AGXLayout_AGXLayoutTransform_h */
