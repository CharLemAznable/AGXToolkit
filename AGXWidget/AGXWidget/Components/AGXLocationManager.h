//
//  AGXLocationManager.h
//  AGXWidget
//
//  Created by Char Aznable on 17/3/20.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXLocationManager_h
#define AGXWidget_AGXLocationManager_h

#import <CoreLocation/CoreLocation.h>
#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXLocationManager : NSObject
@property (nonatomic, readonly) CLLocation  *lastLocation;
@property (nonatomic, readonly) NSError     *lastError;

+ (AGX_INSTANCETYPE)locationManager;
+ (AGX_INSTANCETYPE)locationManagerWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy;
+ (AGX_INSTANCETYPE)locationManagerWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy useInBackground:(BOOL)useInBackground;
- (AGX_INSTANCETYPE)init;
- (AGX_INSTANCETYPE)initWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy;
- (AGX_INSTANCETYPE)initWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy useInBackground:(BOOL)useInBackground;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
@end

#endif /* AGXWidget_AGXLocationManager_h */
