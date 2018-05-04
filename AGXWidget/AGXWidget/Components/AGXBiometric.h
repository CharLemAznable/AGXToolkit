//
//  AGXBiometric.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/8/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXBiometric_h
#define AGXWidget_AGXBiometric_h

#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXBiometricDelegate;

@interface AGXBiometric : NSObject
@property (nonatomic, AGX_WEAK) id<AGXBiometricDelegate> delegate;
@property (nonatomic, copy)     NSString *authenticationReasonString;
@property (nonatomic, copy)     NSString *fallbackTitle;

- (void)evaluate;
- (void)invalidate;
@end

@protocol AGXBiometricDelegate <NSObject>
@optional
- (void)biometricSuccess:(AGXBiometric *)biometric;
- (void)biometricFailure:(AGXBiometric *)biometric withError:(NSError *)error; // called when failed anyway

- (void)biometricUnavailable:(AGXBiometric *)biometric withError:(NSError *)error; // called when unavailable anyway
- (void)biometricAuthFailed:(AGXBiometric *)biometric withError:(NSError *)error; // failed to provide valid credentials
- (void)biometricUserCancel:(AGXBiometric *)biometric withError:(NSError *)error; // canceled by user (e.g. tapped Cancel button)
- (void)biometricUserFallback:(AGXBiometric *)biometric withError:(NSError *)error; // user tapped the (Enter Password) button
- (void)biometricSystemCancel:(AGXBiometric *)biometric withError:(NSError *)error; // canceled by system (e.g. another application went to foreground)
- (void)biometricLockout:(AGXBiometric *)biometric withError:(NSError *)error; // not successful, because there were too many failed biometry attempts and biometry is now locked
- (void)biometricAppCancel:(AGXBiometric *)biometric withError:(NSError *)error; // canceled by application (e.g. invalidate was called while authentication was in progress).
- (void)biometricInvalidContext:(AGXBiometric *)biometric withError:(NSError *)error; // LAContext passed to this call has been previously invalidated.
- (void)biometricNotInteractive:(AGXBiometric *)biometric withError:(NSError *)error; // failed because it would require showing UI which has been forbidden by using interactionNotAllowed property

- (void)biometricPasscodeNotSet:(AGXBiometric *)biometric withError:(NSError *)error; // could not start, passcode is not set on the device
- (void)biometricNotAvailable:(AGXBiometric *)biometric withError:(NSError *)error; // could not start, not available on the device
- (void)biometricNotEnrolled:(AGXBiometric *)biometric withError:(NSError *)error; // could not start, no enrolled identities
@end

#endif /* AGXWidget_AGXBiometric_h */
