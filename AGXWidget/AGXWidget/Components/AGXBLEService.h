//
//  AGXBLEService.h
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXBLEService_h
#define AGXWidget_AGXBLEService_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>

@class AGXPeripheral;
@class AGXCharacteristic;

@interface AGXBLEService : NSObject
@property (nonatomic, readonly) CBService *service;
@property (nonatomic, readonly) CBUUID *UUID;
@property (nonatomic, readonly) BOOL isPrimary;
@property (nonatomic, readonly) NSArray<AGXBLEService *> *includedServices;
@property (nonatomic, readonly) NSArray<AGXCharacteristic *> *characteristics;

+ (AGX_INSTANCETYPE)serviceWithService:(CBService *)service andOwnPeripheral:(AGXPeripheral *)peripheral;
- (AGX_INSTANCETYPE)initWithService:(CBService *)service andOwnPeripheral:(AGXPeripheral *)peripheral;

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs;
- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs;
@end

#endif /* AGXWidget_AGXBLEService_h */
