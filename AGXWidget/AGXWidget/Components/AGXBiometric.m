//
//  AGXBiometric.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/8/22.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import "AGXBiometric.h"
#import "AGXWidgetLocalization.h"

@implementation AGXBiometric {
    LAContext *_context;
}

- (void)dealloc {
    _delegate = nil;
    [_context invalidate];
    AGX_RELEASE(_context);
    AGX_RELEASE(_authenticationReasonString);
    AGX_RELEASE(_fallbackTitle);
    AGX_SUPER_DEALLOC;
}

- (void)evaluate {
    @synchronized(self) {
        [_context invalidate];
        AGX_RELEASE(_context);

        _context = [[LAContext alloc] init];
        _context.localizedFallbackTitle = _fallbackTitle;
        NSError* error = nil;
        if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:
             _authenticationReasonString?:AGXWidgetLocalizedStringDefault
             (@"AGXBiometric.authenticationReason", @"Biometric Authentication Accessing...") reply:
             ^(BOOL success, NSError *error) {
                 agx_async_main
                 (if (success) {
                     if ([_delegate respondsToSelector:@selector(biometricSuccess:)])
                         [_delegate biometricSuccess:self];
                 } else {
                     if ([_delegate respondsToSelector:@selector(biometricFailure:withError:)])
                         [_delegate biometricFailure:self withError:error];

                     switch (error.code) {
                         case kLAErrorAuthenticationFailed:
                             if ([_delegate respondsToSelector:@selector(biometricAuthFailed:withError:)])
                                 [_delegate biometricAuthFailed:self withError:error];
                             break;
                         case kLAErrorUserCancel:
                             if ([_delegate respondsToSelector:@selector(biometricUserCancel:withError:)])
                                 [_delegate biometricUserCancel:self withError:error];
                             break;
                         case kLAErrorUserFallback:
                             if ([_delegate respondsToSelector:@selector(biometricUserFallback:withError:)])
                                 [_delegate biometricUserFallback:self withError:error];
                             break;
                         case kLAErrorSystemCancel:
                             if ([_delegate respondsToSelector:@selector(biometricSystemCancel:withError:)])
                                 [_delegate biometricSystemCancel:self withError:error];
                             break;
                         case kLAErrorBiometryLockout:
                             if ([_delegate respondsToSelector:@selector(biometricLockout:withError:)])
                                 [_delegate biometricLockout:self withError:error];
                             break;
                         case kLAErrorAppCancel:
                             if ([_delegate respondsToSelector:@selector(biometricAppCancel:withError:)])
                                 [_delegate biometricAppCancel:self withError:error];
                             break;
                         case kLAErrorInvalidContext:
                             if ([_delegate respondsToSelector:@selector(biometricInvalidContext:withError:)])
                                 [_delegate biometricInvalidContext:self withError:error];
                             break;
                         case kLAErrorNotInteractive:
                             if ([_delegate respondsToSelector:@selector(biometricNotInteractive:withError:)])
                                 [_delegate biometricNotInteractive:self withError:error];
                             break;
                         default:
                             break;
                     }
                 });
             }];
        } else {
            agx_async_main
            (if ([_delegate respondsToSelector:@selector(biometricUnavailable:withError:)])
             [_delegate biometricUnavailable:self withError:error];

             switch (error.code) {
                 case kLAErrorPasscodeNotSet:
                     if ([_delegate respondsToSelector:@selector(biometricPasscodeNotSet:withError:)])
                         [_delegate biometricPasscodeNotSet:self withError:error];
                     break;
                 case kLAErrorBiometryNotAvailable:
                     if ([_delegate respondsToSelector:@selector(biometricNotAvailable:withError:)])
                         [_delegate biometricNotAvailable:self withError:error];
                     break;
                 case kLAErrorBiometryNotEnrolled:
                     if ([_delegate respondsToSelector:@selector(biometricNotEnrolled:withError:)])
                         [_delegate biometricNotEnrolled:self withError:error];
                     break;
                 default:
                     break;
             });
        }
    }
}

- (void)invalidate {
    @synchronized(self) {
        [_context invalidate];
        AGX_RELEASE(_context);
        _context = nil;
    }
}

@end
