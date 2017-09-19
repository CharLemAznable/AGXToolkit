//
//  AGXBiometric.m
//  AGXWidget
//
//  Created by Char Aznable on 16/8/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import "AGXBiometric.h"

@implementation AGXBiometric {
    id _context;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
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
    return [_context localizedFallbackTitle];
}

- (void)setFallbackTitle:(NSString *)fallbackTitle {
    [_context setLocalizedFallbackTitle:fallbackTitle];
}

- (void)evaluate {
    if (!_context) return;
    NSError* error = nil;
    if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:_authenticationReasonString reply:
         ^(BOOL success, NSError *error) {
             if (success) {
                 if ([self.delegate respondsToSelector:@selector(biometricSuccess:)])
                     [self.delegate biometricSuccess:self];
             } else {
                 switch (error.code) {
                     case LAErrorAuthenticationFailed:
                         if ([self.delegate respondsToSelector:@selector(biometricAuthFailed:withError:)])
                             [self.delegate biometricAuthFailed:self withError:error];
                         break;
                     case LAErrorUserCancel:
                         if ([self.delegate respondsToSelector:@selector(biometricUserCancel:withError:)])
                             [self.delegate biometricUserCancel:self withError:error];
                         break;
                     case LAErrorUserFallback:
                         if ([self.delegate respondsToSelector:@selector(biometricUserFallback:withError:)])
                             [self.delegate biometricUserFallback:self withError:error];
                         break;
                     case LAErrorSystemCancel:
                         if ([self.delegate respondsToSelector:@selector(biometricSystemCancel:withError:)])
                             [self.delegate biometricSystemCancel:self withError:error];
                         break;
                     default:
                         break;
                 }
             }
         }];
    } else {
        switch (error.code) {
            case LAErrorPasscodeNotSet:
                if ([self.delegate respondsToSelector:@selector(biometricPasscodeNotSet:withError:)])
                    [self.delegate biometricPasscodeNotSet:self withError:error];
                break;
            case LAErrorTouchIDNotAvailable:
                if ([self.delegate respondsToSelector:@selector(biometricNotAvailable:withError:)])
                    [self.delegate biometricNotAvailable:self withError:error];
                break;
            case LAErrorTouchIDNotEnrolled:
                if ([self.delegate respondsToSelector:@selector(biometricNotEnrolled:withError:)])
                    [self.delegate biometricNotEnrolled:self withError:error];
                break;
            default:
                break;
        }
    }
}

@end
