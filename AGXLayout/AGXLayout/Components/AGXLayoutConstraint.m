//
//  AGXLayoutConstraint.m
//  AGXLayout
//
//  Created by Char Aznable on 16/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
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
    return [[[self class] allocWithZone:zone] initWithBlock:_block];
}

- (void)dealloc {
    if AGX_EXPECT_T(_block) AGX_BLOCK_RELEASE(_block);
    AGX_SUPER_DEALLOC;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if AGX_EXPECT_F(!object || ![object isKindOfClass:[AGXLayoutConstraint class]]) return NO;
    return [self isEqualToLayoutConstraint:object];
}

- (BOOL)isEqualToLayoutConstraint:(AGXLayoutConstraint *)constraint {
    if (constraint == self) return YES;
    if (_block == nil && constraint.block == nil) return YES;
    if (_block == nil || constraint.block == nil) return NO;
    return _block == constraint.block;
}

#pragma mark - multi singleton instances

static AGXLayoutConstraint *nilConstraint = nil;
static AGXLayoutConstraint *fullWidthConstraint = nil;
static AGXLayoutConstraint *fullHeightConstraint = nil;
static AGXLayoutConstraint *halfWidthConstraint = nil;
static AGXLayoutConstraint *halfHeightConstraint = nil;
static AGXLayoutConstraint *aThirdWidthConstraint = nil;
static AGXLayoutConstraint *aThirdHeightConstraint = nil;
static AGXLayoutConstraint *quarterWidthConstraint = nil;
static AGXLayoutConstraint *quarterHeightConstraint = nil;

#pragma mark - convenience constraints

#define AGXLayoutConstraint_implement(constraint, block)                \
+ (AGXLayoutConstraint *)constraint {                                   \
    agx_once                                                            \
    (constraint = [[AGXLayoutConstraint alloc] initWithBlock:block];)   \
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

static AGXLayoutConstraintBlock fullWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width; };

static AGXLayoutConstraintBlock fullHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height; };

static AGXLayoutConstraintBlock halfWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width / 2; };

static AGXLayoutConstraintBlock halfHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height / 2; };

static AGXLayoutConstraintBlock aThirdWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width / 3; };

static AGXLayoutConstraintBlock aThirdHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height / 3; };

static AGXLayoutConstraintBlock quarterWidthBlock =
^CGFloat(UIView *view) { return view.bounds.size.width / 4; };

static AGXLayoutConstraintBlock quarterHeightBlock =
^CGFloat(UIView *view) { return view.bounds.size.height / 4; };

@end
