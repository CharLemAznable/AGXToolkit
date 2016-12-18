//
//  AGXPeripheral.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXPeripheral_h
#define AGXNetwork_AGXPeripheral_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>

AGX_EXTERN NSTimeInterval AGXDiscoverServicesTimeout;
AGX_EXTERN NSTimeInterval AGXDiscoverIncludedServicesTimeout;
AGX_EXTERN NSTimeInterval AGXDiscoverCharacteristicsTimeout;
AGX_EXTERN NSTimeInterval AGXDiscoverDescriptorsTimeout;

@class AGXBLEService;
@class AGXCharacteristic;
@class AGXDescriptor;
@protocol AGXPeripheralDelegate;

@interface AGXPeripheral : NSObject
@property (nonatomic, readonly) CBPeripheral *peripheral;
@property (nonatomic, readonly) NSUUID *identifier;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CBPeripheralState state;
@property (nonatomic, readonly) NSArray<AGXBLEService *> *services;
@property (nonatomic, readonly) NSNumber *RSSI;
@property (nonatomic, AGX_WEAK) id<AGXPeripheralDelegate> delegate;

+ (AGX_INSTANCETYPE)peripheralWithPeripheral:(CBPeripheral *)peripheral;
- (AGX_INSTANCETYPE)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)readRSSI;
- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs;
- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(AGXBLEService *)service;
- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(AGXBLEService *)service;
- (void)discoverDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic;
- (void)readValueForCharacteristic:(AGXCharacteristic *)characteristic;
- (void)writeValue:(NSData *)data forCharacteristic:(AGXCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;
- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(AGXCharacteristic *)characteristic;
- (void)readValueForDescriptor:(AGXDescriptor *)descriptor;
- (void)writeValue:(NSData *)data forDescriptor:(AGXDescriptor *)descriptor;
@end

@protocol AGXPeripheralDelegate <NSObject>
@optional
- (void)peripheral:(AGXPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error;
- (NSTimeInterval)peripheralDiscoverServicesTimeout:(AGXPeripheral *)peripheral;
- (void)peripheral:(AGXPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (NSTimeInterval)peripheral:(AGXPeripheral *)peripheral discoverIncludedServicesTimeout:(AGXBLEService *)service;
- (void)peripheral:(AGXPeripheral *)peripheral didDiscoverIncludedServicesForService:(AGXBLEService *)service error:(NSError *)error;
- (NSTimeInterval)peripheral:(AGXPeripheral *)peripheral discoverCharacteristicsTimeout:(AGXBLEService *)service;
- (void)peripheral:(AGXPeripheral *)peripheral didDiscoverCharacteristicsForService:(AGXBLEService *)service error:(NSError *)error;
- (NSTimeInterval)peripheral:(AGXPeripheral *)peripheral discoverDescriptorsTimeout:(AGXCharacteristic *)characteristic;
- (void)peripheral:(AGXPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(AGXPeripheral *)peripheral didUpdateValueForCharacteristic:(AGXCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(AGXPeripheral *)peripheral didWriteValueForCharacteristic:(AGXCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(AGXPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(AGXCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(AGXPeripheral *)peripheral didUpdateValueForDescriptor:(AGXDescriptor *)descriptor error:(NSError *)error;
- (void)peripheral:(AGXPeripheral *)peripheral didWriteValueForDescriptor:(AGXDescriptor *)descriptor error:(NSError *)error;
@end

#endif /* AGXNetwork_AGXPeripheral_h */
