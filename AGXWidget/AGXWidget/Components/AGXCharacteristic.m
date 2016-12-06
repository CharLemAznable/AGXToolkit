//
//  AGXCharacteristic.m
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  MacPu/MPBluetoothKit
//

//  Copyright (c) 2014-2015 MPBluetoothKit https://github.com/MacPu/MPBluetoothKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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

- (void)discoverDescriptorsWithBlock:(AGXPeripheralDiscoverDescriptorsForCharacteristicBlock)block {
    if (_ownPeripheral) [_ownPeripheral discoverDescriptorsForCharacteristic:self withBlock:block];
}

- (void)readValueWithBlock:(AGXPeripheralReadValueForCharacteristicBlock)block {
    if (_ownPeripheral) [_ownPeripheral readValueForCharacteristic:self withBlock:block];
}

- (void)writeValue:(NSData *)data type:(CBCharacteristicWriteType)type withBlock:(AGXPeripheralWriteValueForCharacteristicsBlock)block {
    if (_ownPeripheral) [_ownPeripheral writeValue:data forCharacteristic:self type:type withBlock:block];
}

- (void)setNotifyValue:(BOOL)enabled withBlock:(AGXPeripheralNotifyValueForCharacteristicsBlock)block {
    if (_ownPeripheral) [_ownPeripheral setNotifyValue:enabled forCharacteristic:self withBlock:block];
}

@end
