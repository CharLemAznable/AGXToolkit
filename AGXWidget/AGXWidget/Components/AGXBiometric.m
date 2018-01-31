//
//  AGXBiometric.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/8/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import "AGXBiometric.h"

@implementation AGXBiometric {
    LAContext *_context;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _context = [[LAContext alloc] init];
        _authenticationReasonString = @"Biometric Authentication Accessing...";
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    AGX_RELEASE(_context);
    AGX_RELEASE(_authenticationReasonString);
    AGX_SUPER_DEALLOC;
}

- (NSString *)fallbackTitle {
    return _context.localizedFallbackTitle;
}

- (void)setFallbackTitle:(NSString *)fallbackTitle {
    _context.localizedFallbackTitle = fallbackTitle;
}

- (void)evaluate {
    if AGX_EXPECT_F(!_context) return;
    NSError* error = nil;
    if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:_authenticationReasonString reply:
         ^(BOOL success, NSError *error) {
             agx_async_main
             (if (success) {
                 if ([self.delegate respondsToSelector:@selector(biometricSuccess:)])
                     [self.delegate biometricSuccess:self];
             } else {
                 if ([self.delegate respondsToSelector:@selector(biometricFailure:withError:)])
                     [self.delegate biometricFailure:self withError:error];

                 switch (error.code) {
                     case kLAErrorAuthenticationFailed:
                         if ([self.delegate respondsToSelector:@selector(biometricAuthFailed:withError:)])
                             [self.delegate biometricAuthFailed:self withError:error];
                         break;
                     case kLAErrorUserCancel:
                         if ([self.delegate respondsToSelector:@selector(biometricUserCancel:withError:)])
                             [self.delegate biometricUserCancel:self withError:error];
                         break;
                     case kLAErrorUserFallback:
                         if ([self.delegate respondsToSelector:@selector(biometricUserFallback:withError:)])
                             [self.delegate biometricUserFallback:self withError:error];
                         break;
                     case kLAErrorSystemCancel:
                         if ([self.delegate respondsToSelector:@selector(biometricSystemCancel:withError:)])
                             [self.delegate biometricSystemCancel:self withError:error];
                         break;
                     case kLAErrorBiometryLockout:
                         if ([self.delegate respondsToSelector:@selector(biometricLockout:withError:)])
                             [self.delegate biometricLockout:self withError:error];
                         break;
                     case kLAErrorAppCancel:
                         if ([self.delegate respondsToSelector:@selector(biometricAppCancel:withError:)])
                             [self.delegate biometricAppCancel:self withError:error];
                         break;
                     case kLAErrorInvalidContext:
                         if ([self.delegate respondsToSelector:@selector(biometricInvalidContext:withError:)])
                             [self.delegate biometricInvalidContext:self withError:error];
                         break;
                     case kLAErrorNotInteractive:
                         if ([self.delegate respondsToSelector:@selector(biometricNotInteractive:withError:)])
                             [self.delegate biometricNotInteractive:self withError:error];
                         break;
                     default:
                         break;
                 }
             })
         }];
    } else {
        agx_async_main
        (if ([self.delegate respondsToSelector:@selector(biometricUnavailable:withError:)])
         [self.delegate biometricUnavailable:self withError:error];

         switch (error.code) {
             case kLAErrorPasscodeNotSet:
                 if ([self.delegate respondsToSelector:@selector(biometricPasscodeNotSet:withError:)])
                     [self.delegate biometricPasscodeNotSet:self withError:error];
                 break;
             case kLAErrorBiometryNotAvailable:
                 if ([self.delegate respondsToSelector:@selector(biometricNotAvailable:withError:)])
                     [self.delegate biometricNotAvailable:self withError:error];
                 break;
             case kLAErrorBiometryNotEnrolled:
                 if ([self.delegate respondsToSelector:@selector(biometricNotEnrolled:withError:)])
                     [self.delegate biometricNotEnrolled:self withError:error];
                 break;
             default:
                 break;
         })
    }
}

@end
