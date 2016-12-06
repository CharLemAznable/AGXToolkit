//
//  AGXPeripheral.m
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXPeripheral.h"
#import "AGXCharacteristic.h"
#import "AGXBLEService.h"
#import "AGXDescriptor.h"

@interface AGXPeripheral() <CBPeripheralDelegate>
@property (nonatomic, AGX_STRONG) NSNumber *RSSI;
@end

@implementation AGXPeripheral

+ (AGX_INSTANCETYPE)peripheralWithPeripheral:(CBPeripheral *)peripheral {
    return AGX_AUTORELEASE([[self alloc] initWithPeripheral:peripheral]);
}

- (AGX_INSTANCETYPE)initWithPeripheral:(CBPeripheral *)peripheral {
    NSAssert(peripheral, @"MPPeripheral cannot init with a nullable peripheral");
    if (self = [super init]) {
        _peripheral = AGX_RETAIN(peripheral);
        _peripheral.delegate = self;
    }
    return self;
}

- (void)dealloc {
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

- (void)readRSSI {
    [_peripheral readRSSI];
}

//static NSString *const DEVICE_INFO_SERVICE_UUID = @"180A";
//static NSString *const DEVICE_INFO_CHARACT_UUID = @"2A23";
//
//- (void)readMac:(AGXPeripheralReadMacBlock)block {
//    NSAssert(block, @"readMac: block cannot be nil");
//    AGXPeripheralReadMacBlock temp = AGX_BLOCK_COPY(block);
//    if (_readMacBlock) AGX_BLOCK_RELEASE(_readMacBlock);
//    _readMacBlock = temp;
//
//    CBUUID *DEVICE_INFO_SERVICE = [CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID];
//    CBUUID *DEVICE_INFO_CHARACT = [CBUUID UUIDWithString:DEVICE_INFO_CHARACT_UUID];
//    [self discoverServices:@[DEVICE_INFO_SERVICE] withBlock:
//     ^(AGXPeripheral *peripheral, NSError *error) {
//         for (AGXBLEService *service in peripheral.services) {
//             if (![service.UUID isEqual:DEVICE_INFO_SERVICE]) continue;
//
//             [service discoverCharacteristics:@[DEVICE_INFO_CHARACT] withBlock:
//              ^(AGXPeripheral *peripheral, AGXBLEService *service, NSError *error) {
//                  for (AGXCharacteristic *characteristic in service.characteristics) {
//                      if (![characteristic.UUID isEqual:DEVICE_INFO_CHARACT]) continue;
//
//                      [characteristic readValueWithBlock:
//                       ^(AGXPeripheral *peripheral, AGXCharacteristic *characteristic, NSError *error) {
//                           NSString *value = [NSString stringWithFormat:@"%@", characteristic.value];
//                           NSArray *items = @[[value substringWithRange:NSMakeRange(16, 2)],
//                                              [value substringWithRange:NSMakeRange(14, 2)],
//                                              [value substringWithRange:NSMakeRange(12, 2)],
//                                              [value substringWithRange:NSMakeRange(5, 2)],
//                                              [value substringWithRange:NSMakeRange(3, 2)],
//                                              [value substringWithRange:NSMakeRange(1, 2)]];
//                           NSString *macString = [NSString stringWithArray:items usingComparator:NULL separator:@":" filterEmpty:YES];
//
//                           [peripheral callReadMacBlock:macString withError:error];
//                       }];
//                      return;
//                  }
//                  [peripheral callReadMacBlock:nil withError:error];
//              }];
//             return;
//         }
//         [peripheral callReadMacBlock:nil withError:error];
//     }];
//}

//- (void)callReadMacBlock:(NSString *)macString withError:(NSError *)error {
//    if (!_readMacBlock) return;
//    _readMacBlock(self, macString, error);
//    AGX_BLOCK_RELEASE(_readMacBlock);
//    _readMacBlock = nil;
//}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs {
    [_peripheral discoverServices:serviceUUIDs];
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(AGXBLEService *)service {
    [_peripheral discoverIncludedServices:includedServiceUUIDs forService:service.service];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(AGXBLEService *)service {
    [_peripheral discoverCharacteristics:characteristicUUIDs forService:service.service];
}

-(void)discoverDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic {
    [_peripheral discoverDescriptorsForCharacteristic:characteristic.characteristic];
}

- (void)readValueForCharacteristic:(AGXCharacteristic *)characteristic {
    [_peripheral readValueForCharacteristic:characteristic.characteristic];
}

- (void)writeValue:(NSData *)data forCharacteristic:(AGXCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    [_peripheral writeValue:data forCharacteristic:characteristic.characteristic type:type];
}

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(AGXCharacteristic *)characteristic {
    [_peripheral setNotifyValue:enabled forCharacteristic:characteristic.characteristic];
}

- (void)readValueForDescriptor:(AGXDescriptor *)descriptor {
    [_peripheral readValueForDescriptor:descriptor.descriptor];
}

- (void)writeValue:(NSData *)data forDescriptor:(AGXDescriptor *)descriptor {
    [_peripheral writeValue:data forDescriptor:descriptor.descriptor];
}

#pragma mark - CBPeripheralDelegate

#define CBPeripheralAssert {if (_peripheral != peripheral) return;}
#define PeripheralIsEqual(peripheral) [peripheral.identifier.UUIDString isEqualToString:_peripheral.identifier.UUIDString]

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    CBPeripheralAssert
    self.RSSI = peripheral.RSSI;
    if ([self.delegate respondsToSelector:@selector(peripheral:didReadRSSI:error:)])
        [self.delegate peripheral:self didReadRSSI:_RSSI error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    CBPeripheralAssert
    self.RSSI = RSSI;
    if ([self.delegate respondsToSelector:@selector(peripheral:didReadRSSI:error:)])
        [self.delegate peripheral:self didReadRSSI:_RSSI error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverServices:)])
        [self.delegate peripheral:self didDiscoverServices:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)])
        [self.delegate peripheral:self didDiscoverIncludedServicesForService:
         [AGXBLEService serviceWithService:service andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)])
        [self.delegate peripheral:self didDiscoverCharacteristicsForService:
         [AGXBLEService serviceWithService:service andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)])
        [self.delegate peripheral:self didDiscoverDescriptorsForCharacteristic:
         [AGXCharacteristic characteristicWithCharacteristic:characteristic andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)])
        [self.delegate peripheral:self didUpdateValueForCharacteristic:
         [AGXCharacteristic characteristicWithCharacteristic:characteristic andOwnPeripheral:self] error:error];
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)])
        [self.delegate peripheral:self didUpdateNotificationStateForCharacteristic:
         [AGXCharacteristic characteristicWithCharacteristic:characteristic andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)])
        [self.delegate peripheral:self didWriteValueForCharacteristic:
         [AGXCharacteristic characteristicWithCharacteristic:characteristic andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)])
        [self.delegate peripheral:self didUpdateNotificationStateForCharacteristic:
         [AGXCharacteristic characteristicWithCharacteristic:characteristic andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForDescriptor:error:)])
        [self.delegate peripheral:self didUpdateValueForDescriptor:
         [AGXDescriptor descriptorWithDescriptor:descriptor andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    CBPeripheralAssert
    if ([self.delegate respondsToSelector:@selector(peripheral:didWriteValueForDescriptor:error:)])
        [self.delegate peripheral:self didWriteValueForDescriptor:
         [AGXDescriptor descriptorWithDescriptor:descriptor andOwnPeripheral:self] error:error];
}

#undef PeripheralIsEqual

@end
