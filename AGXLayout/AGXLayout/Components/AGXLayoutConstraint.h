//
//  AGXLayoutConstraint.h
//  AGXLayout
//
//  Created by Char Aznable on 2016/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXLayout_AGXLayoutConstraint_h
#define AGXLayout_AGXLayoutConstraint_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXObjC.h>

typedef CGFloat (^AGXLayoutConstraintBlock)(UIView *view);

// AGXLayoutConstraint will copy its block.
// So use self in the block will produces self retain and circular reference.
// As far as possible use the block's parameter "view",
// or use "__weak/__block/__AGX_WEAK_RETAIN typeof(self) weakSelf = self" instead of "self".
@interface AGXLayoutConstraint : NSObject <NSCopying>
@property (nonatomic, readonly) AGXLayoutConstraintBlock block;

+ (AGX_INSTANCETYPE)layoutConstraintWithBlock:(AGXLayoutConstraintBlock)block;
- (AGX_INSTANCETYPE)initWithBlock:(AGXLayoutConstraintBlock)block;

- (BOOL)isEqualToLayoutConstraint:(AGXLayoutConstraint *)constraint;

+ (AGXLayoutConstraint *)nilConstraint;
+ (AGXLayoutConstraint *)fullWidthConstraint;
+ (AGXLayoutConstraint *)fullHeightConstraint;
+ (AGXLayoutConstraint *)halfWidthConstraint;
+ (AGXLayoutConstraint *)halfHeightConstraint;
+ (AGXLayoutConstraint *)aThirdWidthConstraint;
+ (AGXLayoutConstraint *)aThirdHeightConstraint;
+ (AGXLayoutConstraint *)quarterWidthConstraint;
+ (AGXLayoutConstraint *)quarterHeightConstraint;
@end

#endif /* AGXLayout_AGXLayoutConstraint_h */
