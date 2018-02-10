//
//  AGXLocationManager.m
//  AGXWidget
//
//  Created by Char Aznable on 17/3/20.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXLocationManager.h"

typedef void (^AGXLocationUpdateBlock)(CLLocation *location);
typedef void (^AGXLocationErrorBlock)(NSError *error);

@interface AGXLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, AGX_STRONG) CLLocationManager            *locationManager;
@property (nonatomic, AGX_STRONG) CLLocation                   *lastLocation;
@property (nonatomic, AGX_STRONG) NSError                      *lastError;
@end

@implementation AGXLocationManager

+ (BOOL)locationServicesEnabled {
    return CLLocationManager.locationServicesEnabled;
}

+ (BOOL)locationServicesAuthorized {
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    return(status != kCLAuthorizationStatusRestricted && status != kCLAuthorizationStatusDenied);
}

+ (AGX_INSTANCETYPE)locationManager {
    return AGX_AUTORELEASE([[self alloc] init]);
}

+ (AGX_INSTANCETYPE)locationManagerWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    return AGX_AUTORELEASE([[self alloc] initWithDistanceFilter:distanceFilter desiredAccuracy:desiredAccuracy]);
}

+ (AGX_INSTANCETYPE)locationManagerWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy useInBackground:(BOOL)useInBackground {
    return AGX_AUTORELEASE([[self alloc] initWithDistanceFilter:distanceFilter desiredAccuracy:desiredAccuracy useInBackground:useInBackground]);
}

- (AGX_INSTANCETYPE)init {
    return [self initWithDistanceFilter:10 desiredAccuracy:10]; // default accuracy: 10
}

- (AGX_INSTANCETYPE)initWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    return [self initWithDistanceFilter:distanceFilter desiredAccuracy:desiredAccuracy useInBackground:NO];
}

- (AGX_INSTANCETYPE)initWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy useInBackground:(BOOL)useInBackground {
    if AGX_EXPECT_T(self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = distanceFilter;
        _locationManager.desiredAccuracy = desiredAccuracy;

        if (kCLAuthorizationStatusNotDetermined == CLLocationManager.authorizationStatus) {
            if (useInBackground) [_locationManager requestAlwaysAuthorization];
            else [_locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)dealloc {
    if AGX_EXPECT_T(_locationManager) [_locationManager stopUpdatingLocation];
    AGX_RELEASE(_locationManager);
    AGX_RELEASE(_lastLocation);
    AGX_RELEASE(_lastError);
    AGX_BLOCK_RELEASE(_updateBlock);
    AGX_BLOCK_RELEASE(_errorBlock);
    AGX_SUPER_DEALLOC;
}

- (void)setUpdateBlock:(AGXLocationUpdateBlock)updateBlock {
    AGXLocationUpdateBlock temp = AGX_BLOCK_COPY(updateBlock);
    AGX_BLOCK_RELEASE(_updateBlock);
    _updateBlock = temp;
}

- (void)setErrorBlock:(AGXLocationErrorBlock)errorBlock {
    AGXLocationErrorBlock temp = AGX_BLOCK_COPY(errorBlock);
    AGX_BLOCK_RELEASE(_errorBlock);
    _errorBlock = temp;
}

- (void)startUpdatingLocation {
    if AGX_EXPECT_T(_locationManager) [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    if AGX_EXPECT_T(_locationManager) [_locationManager stopUpdatingLocation];
    self.lastLocation = nil;
    self.lastError = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if AGX_EXPECT_F(manager != _locationManager) return;
    self.lastLocation = locations.lastObject;
    !_updateBlock ?: _updateBlock(_lastLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if AGX_EXPECT_F(manager != _locationManager) return;
    self.lastError = error;
    !_errorBlock ?: _errorBlock(_lastError);
}

@end
