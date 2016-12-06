//
//  AGXPeripheral.m
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

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXPeripheral.h"
#import "AGXCharacteristic.h"
#import "AGXBLEService.h"
#import "AGXDescriptor.h"

@interface AGXPeripheral() <CBPeripheralDelegate>
@property (nonatomic, AGX_STRONG) NSNumber *RSSI;
@end

@implementation AGXPeripheral {
    AGXPeripheralRedRSSIBlock           _readRSSIBlock;
    AGXPeripheralReadMacBlock           _readMacBlock;
    AGXPeripheralDiscoverServicesBlock  _discoverServicesBlock;

    NSMutableDictionary *_discoverIncludedServicesBlocks;
    NSMutableDictionary *_discoverCharacteristicsBlocks;
    NSMutableDictionary *_discoverDescriptorsForCharacteristicBlocks;

    NSMutableDictionary *_readValueForCharacteristicsBlocks;
    NSMutableDictionary *_writeValueForCharacteristicsBlocks;
    NSMutableDictionary *_notifyValueForCharacteristicsBlocks;
    NSMutableDictionary *_readValueForDescriptorsBlock;
    NSMutableDictionary *_writeValueForDescriptorsBlock;
}

+ (AGX_INSTANCETYPE)peripheralWithPeripheral:(CBPeripheral *)peripheral {
    return AGX_AUTORELEASE([[self alloc] initWithPeripheral:peripheral]);
}

- (AGX_INSTANCETYPE)initWithPeripheral:(CBPeripheral *)peripheral {
    NSAssert(peripheral, @"MPPeripheral cannot init with a nullable peripheral");
    if (self = [super init]) {
        _peripheral = AGX_RETAIN(peripheral);
        _peripheral.delegate = self;

        _discoverIncludedServicesBlocks = [[NSMutableDictionary alloc] init];
        _discoverCharacteristicsBlocks = [[NSMutableDictionary alloc] init];
        _discoverDescriptorsForCharacteristicBlocks = [[NSMutableDictionary alloc] init];

        _readValueForCharacteristicsBlocks = [[NSMutableDictionary alloc] init];
        _writeValueForCharacteristicsBlocks = [[NSMutableDictionary alloc] init];
        _notifyValueForCharacteristicsBlocks = [[NSMutableDictionary alloc] init];
        _readValueForDescriptorsBlock = [[NSMutableDictionary alloc] init];
        _writeValueForDescriptorsBlock = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (AGX_EXPECT_T(_readRSSIBlock)) AGX_BLOCK_RELEASE(_readRSSIBlock);
    if (AGX_EXPECT_T(_readMacBlock)) AGX_BLOCK_RELEASE(_readMacBlock);
    if (AGX_EXPECT_T(_discoverServicesBlock)) AGX_BLOCK_RELEASE(_discoverServicesBlock);

    AGX_RELEASE(_discoverIncludedServicesBlocks);
    AGX_RELEASE(_discoverCharacteristicsBlocks);
    AGX_RELEASE(_discoverDescriptorsForCharacteristicBlocks);

    AGX_RELEASE(_readValueForCharacteristicsBlocks);
    AGX_RELEASE(_writeValueForCharacteristicsBlocks);
    AGX_RELEASE(_notifyValueForCharacteristicsBlocks);
    AGX_RELEASE(_readValueForDescriptorsBlock);
    AGX_RELEASE(_writeValueForDescriptorsBlock);

    AGX_RELEASE(_RSSI);
    AGX_RELEASE(_peripheral);
    AGX_SUPER_DEALLOC;
}

- (NSUUID *)identifier {
    return _peripheral.identifier;
}

- (NSString *)name {
    return _peripheral.name;
}

- (CBPeripheralState)state {
    return _peripheral.state;
}

- (NSArray<AGXBLEService *> *)services {
    NSMutableArray *array = [NSMutableArray array];
    for (CBService *service in _peripheral.services) {
        [array addObject:[AGXBLEService serviceWithService:service andOwnPeripheral:self]];
    }
    return array;
}

- (void)readRSSI:(AGXPeripheralRedRSSIBlock)block {
    NSAssert(block, @"readRSSI: block cannot be nil");
    AGXPeripheralRedRSSIBlock temp = AGX_BLOCK_COPY(block);
    if (AGX_EXPECT_T(_readRSSIBlock)) AGX_BLOCK_RELEASE(_readRSSIBlock);
    _readRSSIBlock = temp;
    [_peripheral readRSSI];
}

static NSString *const DEVICE_INFO_SERVICE_UUID = @"180A";
static NSString *const DEVICE_INFO_CHARACT_UUID = @"2A23";

- (void)readMac:(AGXPeripheralReadMacBlock)block {
    NSAssert(block, @"readMac: block cannot be nil");
    AGXPeripheralReadMacBlock temp = AGX_BLOCK_COPY(block);
    if (AGX_EXPECT_T(_readMacBlock)) AGX_BLOCK_RELEASE(_readMacBlock);
    _readMacBlock = temp;

    CBUUID *DEVICE_INFO_SERVICE = [CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID];
    CBUUID *DEVICE_INFO_CHARACT = [CBUUID UUIDWithString:DEVICE_INFO_CHARACT_UUID];

    [self discoverServices:@[DEVICE_INFO_SERVICE] withBlock:
     ^(AGXPeripheral *peripheral, NSError *error) {
         for (AGXBLEService *service in peripheral.services) {
             if (![service.UUID isEqual:DEVICE_INFO_SERVICE]) continue;

             [service discoverCharacteristics:@[DEVICE_INFO_CHARACT] withBlock:
              ^(AGXPeripheral *peripheral, AGXBLEService *service, NSError *error) {
                  for (AGXCharacteristic *characteristic in service.characteristics) {
                      if (![characteristic.UUID isEqual:DEVICE_INFO_CHARACT]) continue;

                      [characteristic readValueWithBlock:
                       ^(AGXPeripheral *peripheral, AGXCharacteristic *characteristic, NSError *error) {
                           NSString *value = [NSString stringWithFormat:@"%@", characteristic.value];
                           NSArray *items = @[[value substringWithRange:NSMakeRange(16, 2)],
                                              [value substringWithRange:NSMakeRange(14, 2)],
                                              [value substringWithRange:NSMakeRange(12, 2)],
                                              [value substringWithRange:NSMakeRange(5, 2)],
                                              [value substringWithRange:NSMakeRange(3, 2)],
                                              [value substringWithRange:NSMakeRange(1, 2)]];
                           NSString *macString = [NSString stringWithArray:items usingComparator:NULL separator:@":" filterEmpty:YES];

                           [self callReadMacBlock:macString withError:error];
                       }];
                      return;
                  }
                  [self callReadMacBlock:nil withError:error];
              }];
             return;
         }
         [self callReadMacBlock:nil withError:error];
     }];
}

- (void)callReadMacBlock:(NSString *)macString withError:(NSError *)error {
    if (AGX_EXPECT_T(_readMacBlock)) {
        _readMacBlock(self, macString, error);
        AGX_BLOCK_RELEASE(_readMacBlock);
    }
    _readMacBlock = nil;
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs withBlock:(AGXPeripheralDiscoverServicesBlock)block {
    NSAssert(block, @"discoverServices:withBlock: block cannot be nil");
    AGXPeripheralDiscoverServicesBlock temp = AGX_BLOCK_COPY(block);
    if (AGX_EXPECT_T(_discoverServicesBlock)) AGX_BLOCK_RELEASE(_discoverServicesBlock);
    _discoverServicesBlock = temp;
    [_peripheral discoverServices:serviceUUIDs];
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(AGXBLEService *)service withBlock:(AGXPeripheralDiscoverIncludedServicesBlock)block {
    NSAssert(block, @"discoverIncludedServices:forService:withBlock: block cannot be nil");
    AGXPeripheralDiscoverIncludedServicesBlock temp = AGX_BLOCK_COPY(block);
    _discoverIncludedServicesBlocks[service.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral discoverIncludedServices:includedServiceUUIDs forService:service.service];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(AGXBLEService *)service withBlock:(AGXPeripheralDiscoverCharacteristicsBlock)block {
    NSAssert(block, @"discoverCharacteristics:forService:withBlock: block cannot be nil");
    AGXPeripheralDiscoverCharacteristicsBlock temp = AGX_BLOCK_COPY(block);
    _discoverCharacteristicsBlocks[service.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral discoverCharacteristics:characteristicUUIDs forService:service.service];
}

-(void)discoverDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic withBlock:(AGXPeripheralDiscoverDescriptorsForCharacteristicBlock)block {
    NSAssert(block, @"discoverDescriptorsForCharacteristic:withBlcok: block cannot be nil");
    AGXPeripheralDiscoverDescriptorsForCharacteristicBlock temp = AGX_BLOCK_COPY(block);
    _discoverDescriptorsForCharacteristicBlocks[characteristic.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral discoverDescriptorsForCharacteristic:characteristic.characteristic];
}

- (void)readValueForCharacteristic:(AGXCharacteristic *)characteristic withBlock:(AGXPeripheralReadValueForCharacteristicBlock)block {
    NSAssert(block, @"readValueForCharacteristic:withBlock: block cannot be nil");
    AGXPeripheralReadValueForCharacteristicBlock temp = AGX_BLOCK_COPY(block);
    _readValueForCharacteristicsBlocks[characteristic.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral readValueForCharacteristic:characteristic.characteristic];
}

- (void)writeValue:(NSData *)data forCharacteristic:(AGXCharacteristic *)characteristic type:(CBCharacteristicWriteType)type withBlock:(AGXPeripheralWriteValueForCharacteristicsBlock)block {
    NSAssert(block, @"writeValue:forCharacteristic:type:withBlock: block cannot be nil");
    AGXPeripheralWriteValueForCharacteristicsBlock temp = AGX_BLOCK_COPY(block);
    _writeValueForCharacteristicsBlocks[characteristic.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral writeValue:data forCharacteristic:characteristic.characteristic type:type];
}

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(AGXCharacteristic *)characteristic withBlock:(AGXPeripheralNotifyValueForCharacteristicsBlock)block {
    NSAssert(block, @"setNotifyValue:forCharacteristic:withBlock: block cannot be nil");
    if (enabled) {
        AGXPeripheralNotifyValueForCharacteristicsBlock temp = AGX_BLOCK_COPY(block);
        _notifyValueForCharacteristicsBlocks[characteristic.UUID] = temp;
        AGX_BLOCK_RELEASE(temp);
    } else [_notifyValueForCharacteristicsBlocks removeObjectForKey:characteristic.UUID];
    [_peripheral setNotifyValue:enabled forCharacteristic:characteristic.characteristic];
}

- (void)readValueForDescriptor:(AGXDescriptor *)descriptor withBlock:(AGXPeripheralReadValueForDescriptorsBlock)block {
    NSAssert(block, @"readValueForDescriptor:withBlock: block cannot be nil");
    AGXPeripheralReadValueForDescriptorsBlock temp = AGX_BLOCK_COPY(block);
    _readValueForDescriptorsBlock[descriptor.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral readValueForDescriptor:descriptor.descriptor];
}

- (void)writeValue:(NSData *)data forDescriptor:(AGXDescriptor *)descriptor withBlock:(AGXPeripheralWriteValueForDescriptorsBlock)block {
    NSAssert(block, @"writeValue:forDescriptor:withBlock: block cannot be nil");
    AGXPeripheralWriteValueForDescriptorsBlock temp = AGX_BLOCK_COPY(block);
    _writeValueForDescriptorsBlock[descriptor.UUID] = temp;
    AGX_BLOCK_RELEASE(temp);
    [_peripheral writeValue:data forDescriptor:descriptor.descriptor];
}

#pragma mark - CBPeripheralDelegate

#define PeripheralIsEqual(peripheral) [peripheral.identifier.UUIDString isEqualToString:_peripheral.identifier.UUIDString]

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    self.RSSI = peripheral.RSSI;
    if (AGX_EXPECT_T(_readRSSIBlock)) {
        _readRSSIBlock(self, _RSSI, error);
        AGX_BLOCK_RELEASE(_readRSSIBlock);
    }
    _readRSSIBlock = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    self.RSSI = RSSI;
    if (AGX_EXPECT_T(_readRSSIBlock)) {
        _readRSSIBlock(self, _RSSI, error);
        AGX_BLOCK_RELEASE(_readRSSIBlock);
    }
    _readRSSIBlock = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    if (AGX_EXPECT_T(_discoverServicesBlock)) {
        _discoverServicesBlock(self, error);
        AGX_BLOCK_RELEASE(_discoverServicesBlock);
    }
    _discoverServicesBlock = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralDiscoverIncludedServicesBlock block = _discoverIncludedServicesBlocks[service.UUID];
    if (block) block(self, [AGXBLEService serviceWithService:service andOwnPeripheral:self], error);
    _discoverIncludedServicesBlocks[service.UUID] = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralDiscoverCharacteristicsBlock block = _discoverCharacteristicsBlocks[service.UUID];
    if (block) block(self, [AGXBLEService serviceWithService:service andOwnPeripheral:self], error);
    _discoverCharacteristicsBlocks[service.UUID] = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralDiscoverDescriptorsForCharacteristicBlock block =
    _discoverDescriptorsForCharacteristicBlocks[characteristic.UUID];
    if (block) block(self, [AGXCharacteristic characteristicWithCharacteristic:
                            characteristic andOwnPeripheral:self], error);
    _discoverDescriptorsForCharacteristicBlocks[characteristic.UUID] = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXCharacteristic *mCharacteristic = [AGXCharacteristic characteristicWithCharacteristic:characteristic andOwnPeripheral:self];
    AGXPeripheralReadValueForCharacteristicBlock readBlock = _readValueForCharacteristicsBlocks[characteristic.UUID];
    if (readBlock) readBlock(self, mCharacteristic, error);
    _readValueForCharacteristicsBlocks[characteristic.UUID] = nil;

    AGXPeripheralNotifyValueForCharacteristicsBlock notifyBlock =
    _notifyValueForCharacteristicsBlocks[characteristic.UUID];
    if (notifyBlock) notifyBlock(self, mCharacteristic, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralWriteValueForCharacteristicsBlock block = _writeValueForCharacteristicsBlocks[characteristic.UUID];
    if (block) block(self, [AGXCharacteristic characteristicWithCharacteristic:
                            characteristic andOwnPeripheral:self], error);
    _writeValueForCharacteristicsBlocks[characteristic.UUID] = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralNotifyValueForCharacteristicsBlock block = _notifyValueForCharacteristicsBlocks[characteristic.UUID];
    if (block) block(self, [AGXCharacteristic characteristicWithCharacteristic:
                            characteristic andOwnPeripheral:self], error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralReadValueForDescriptorsBlock block = _readValueForDescriptorsBlock[descriptor.UUID];
    if (block) block(self, [AGXDescriptor descriptorWithDescriptor:descriptor andOwnPeripheral:self], error);
    _readValueForDescriptorsBlock[descriptor.UUID] = nil;;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    if (!PeripheralIsEqual(peripheral)) return;
    AGXPeripheralWriteValueForDescriptorsBlock block = _writeValueForDescriptorsBlock[descriptor.UUID];
    if (block) block(self, [AGXDescriptor descriptorWithDescriptor:descriptor andOwnPeripheral:self], error);
    _writeValueForDescriptorsBlock[descriptor.UUID] = nil;
}

@end
