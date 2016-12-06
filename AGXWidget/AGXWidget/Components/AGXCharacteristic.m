//
//  AGXCharacteristic.m
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXAdapt.h>
#import "AGXCharacteristic.h"
#import "AGXPeripheral.h"
#import "AGXBLEService.h"

@interface AGXCharacteristic ()
@property (nonatomic, AGX_STRONG)   CBCharacteristic *characteristic;
@property (nonatomic, AGX_WEAK)     AGXPeripheral *ownPeripheral;
@end

@implementation AGXCharacteristic {
    AGXBLEService *_service;
}

+ (instancetype)characteristicWithCharacteristic:(CBCharacteristic *)characteristic andOwnPeripheral:(AGXPeripheral *)peripheral {
    return AGX_AUTORELEASE([[self alloc] initWithCharacteristic:characteristic andOwnPeripheral:peripheral]);
}

- (AGX_INSTANCETYPE)initWithCharacteristic:(CBCharacteristic *)characteristic andOwnPeripheral:(AGXPeripheral *)peripheral {
    if (self = [super init]) {
        _characteristic = AGX_RETAIN(characteristic);
        _ownPeripheral = peripheral;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_service);
    _ownPeripheral = nil;
    AGX_RELEASE(_characteristic);
    AGX_SUPER_DEALLOC;
}

- (AGXBLEService *)service {
    if (!_service) {
        _service = [[AGXBLEService alloc] initWithService:_characteristic.service andOwnPeripheral:_ownPeripheral];
    }
    return _service;
}

- (CBUUID *)UUID {
    return _characteristic.UUID;
}

- (CBCharacteristicProperties)properties {
    return _characteristic.properties;
}

- (NSData *)value {
    return _characteristic.value;
}

- (NSArray<AGXDescriptor *> *)descriptors {
    return nil;
}

- (BOOL)isBroadcasted {
    return AGX_BEFORE_IOS8_0 ? _characteristic.isBroadcasted : NO;
}

- (BOOL)isNotifying {
    return _characteristic.isNotifying;
}

- (void)discoverDescriptors {
    if (_ownPeripheral) [_ownPeripheral discoverDescriptorsForCharacteristic:self];
}

- (void)readValue {
    if (_ownPeripheral) [_ownPeripheral readValueForCharacteristic:self];
}

- (void)writeValue:(NSData *)data type:(CBCharacteristicWriteType)type {
    if (_ownPeripheral) [_ownPeripheral writeValue:data forCharacteristic:self type:type];
}

- (void)setNotifyValue:(BOOL)enabled {
    if (_ownPeripheral) [_ownPeripheral setNotifyValue:enabled forCharacteristic:self];
}

@end
