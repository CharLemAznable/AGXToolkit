//
//  AGXCharacteristic.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXCharacteristic_h
#define AGXNetwork_AGXCharacteristic_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>

@class AGXPeripheral;
@class AGXBLEService;
@class AGXDescriptor;

@interface AGXCharacteristic : NSObject
@property (nonatomic, readonly) CBCharacteristic *characteristic;
@property (nonatomic, readonly) AGXBLEService *service;
@property (nonatomic, readonly) CBUUID *UUID;
@property (nonatomic, readonly) CBCharacteristicProperties properties;
@property (nonatomic, readonly) NSData *value;
@property (nonatomic, readonly) NSArray<AGXDescriptor *> *descriptors;
@property (nonatomic, readonly) BOOL isBroadcasted;
@property (nonatomic, readonly) BOOL isNotifying;

+ (AGX_INSTANCETYPE)characteristicWithCharacteristic:(CBCharacteristic *)characteristic andOwnPeripheral:(AGXPeripheral *)peripheral;
- (AGX_INSTANCETYPE)initWithCharacteristic:(CBCharacteristic *)characteristic andOwnPeripheral:(AGXPeripheral *)peripheral;

- (void)discoverDescriptors;
- (void)readValue;
- (void)writeValue:(NSData *)data type:(CBCharacteristicWriteType)type;
- (void)setNotifyValue:(BOOL)enabled;
@end

#endif /* AGXNetwork_AGXCharacteristic_h */
