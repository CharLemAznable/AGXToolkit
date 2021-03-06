//
//  AGXLayoutConstraint.m
//  AGXLayout
//
//  Created by Char Aznable on 2016/2/21.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXLayoutConstraint.h"

@implementation AGXLayoutConstraint

+ (AGX_INSTANCETYPE)layoutConstraintWithBlock:(AGXLayoutConstraintBlock)block {
    return AGX_AUTORELEASE([[self alloc] initWithBlock:block]);
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) _block = nil;
    return self;
}

- (AGX_INSTANCETYPE)initWithBlock:(AGXLayoutConstraintBlock)block {
    if AGX_EXPECT_T(self = [super init]) _block = AGX_BLOCK_COPY(block);
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self.class allocWithZone:zone] initWithBlock:_block];
}

- (void)dealloc {
    if AGX_EXPECT_T(_block) AGX_BLOCK_RELEASE(_block);
    AGX_SUPER_DEALLOC;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if AGX_EXPECT_F(!object || ![object isKindOfClass:AGXLayoutConstraint.class]) return NO;
    return [self isEqualToLayoutConstraint:object];
}

- (BOOL)isEqualToLayoutConstraint:(AGXLayoutConstraint *)constraint {
    if (constraint == self) return YES;
    if (nil == _block && nil == constraint.block) return YES;
    if (nil == _block || nil == constraint.block) return NO;
    return _block == constraint.block;
}

#pragma mark - multi singleton instances

AGX_STATIC AGXLayoutConstraint *nilConstraint = nil;
AGX_STATIC AGXLayoutConstraint *fullWidthConstraint = nil;
AGX_STATIC AGXLayoutConstraint *fullHeightConstraint = nil;
AGX_STATIC AGXLayoutConstraint *halfWidthConstraint = nil;
AGX_STATIC AGXLayoutConstraint *halfHeightConstraint = nil;
AGX_STATIC AGXLayoutConstraint *aThirdWidthConstraint = nil;
AGX_STATIC AGXLayoutConstraint *aThirdHeightConstraint = nil;
AGX_STATIC AGXLayoutConstraint *quarterWidthConstraint = nil;
AGX_STATIC AGXLayoutConstraint *quarterHeightConstraint = nil;

#pragma mark - convenience constraints

#define AGXLayoutConstraint_implement(constraint, block)                \
+ (AGXLayoutConstraint *)constraint {                                   \
    agx_once                                                            \
    (constraint = [[AGXLayoutConstraint alloc] initWithBlock:block];);  \
    return constraint;                                                  \
}

AGXLayoutConstraint_implement(nilConstraint, nil)
AGXLayoutConstraint_implement(fullWidthConstraint, fullWidthBlock)
AGXLayoutConstraint_implement(fullHeightConstraint, fullHeightBlock)
AGXLayoutConstraint_implement(halfWidthConstraint, halfWidthBlock)
AGXLayoutConstraint_implement(halfHeightConstraint, halfHeightBlock)
AGXLayoutConstraint_implement(aThirdWidthConstraint, aThirdWidthBlock)
AGXLayoutConstraint_implement(aThirdHeightConstraint, aThirdHeightBlock)
AGXLayoutConstraint_implement(quarterWidthConstraint, quarterWidthBlock)
AGXLayoutConstraint_implement(quarterHeightConstraint, quarterHeightBlock)

#undef AGXLayoutConstraint_implement

#pragma mark - static constraint blocks

AGX_STATIC AGXLayoutConstraintBlock fullWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width; };

AGX_STATIC AGXLayoutConstraintBlock fullHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height; };

AGX_STATIC AGXLayoutConstraintBlock halfWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width / 2; };

AGX_STATIC AGXLayoutConstraintBlock halfHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height / 2; };

AGX_STATIC AGXLayoutConstraintBlock aThirdWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width / 3; };

AGX_STATIC AGXLayoutConstraintBlock aThirdHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height / 3; };

AGX_STATIC AGXLayoutConstraintBlock quarterWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width / 4; };

AGX_STATIC AGXLayoutConstraintBlock quarterHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height / 4; };

@end
