//
//  AGXLocationManager.m
//  AGXWidget
//
//  Created by Char Aznable on 17/3/20.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXLocationManager.h"

@interface AGXLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, AGX_STRONG) CLLocationManager *locationManager;
@property (nonatomic, AGX_STRONG) CLLocation        *lastLocation;
@property (nonatomic, AGX_STRONG) NSError           *lastError;
@end

@implementation AGXLocationManager

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
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = distanceFilter;
        _locationManager.desiredAccuracy = desiredAccuracy;

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            if (useInBackground) [_locationManager requestAlwaysAuthorization];
            else [_locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)dealloc {
    if (_locationManager) [_locationManager stopUpdatingLocation];
    AGX_RELEASE(_locationManager);
    AGX_RELEASE(_lastLocation);
    AGX_RELEASE(_lastError);
    AGX_SUPER_DEALLOC;
}

- (void)startUpdatingLocation {
    if (_locationManager) [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    if (_locationManager) [_locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (manager != _locationManager) return;
    self.lastLocation = locations.lastObject;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (manager != _locationManager) return;
    self.lastError = error;
}

@end
