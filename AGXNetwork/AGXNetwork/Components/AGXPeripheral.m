//
//  AGXPeripheral.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXPeripheral.h"
#import "AGXCharacteristic.h"
#import "AGXBLEService.h"
#import "AGXDescriptor.h"

@interface AGXPeripheral() <CBPeripheralDelegate>
@property (nonatomic, AGX_STRONG) NSNumber *RSSI;
@property (nonatomic, AGX_STRONG) NSTimer *discoverServicesTimer;
@property (nonatomic, AGX_STRONG) NSMutableDictionary *discoverIncludedServicesTimers;
@property (nonatomic, AGX_STRONG) NSMutableDictionary *discoverCharacteristicsTimers;
@property (nonatomic, AGX_STRONG) NSMutableDictionary *discoverDescriptorsTimers;
@end

@implementation AGXPeripheral

+ (AGX_INSTANCETYPE)peripheralWithPeripheral:(CBPeripheral *)peripheral {
    return AGX_AUTORELEASE([[self alloc] initWithPeripheral:peripheral]);
}

- (AGX_INSTANCETYPE)initWithPeripheral:(CBPeripheral *)peripheral {
    if AGX_EXPECT_T(self = [super init]) {
        _peripheral = AGX_RETAIN(peripheral);
        _peripheral.delegate = self;
        _discoverIncludedServicesTimers = [[NSMutableDictionary alloc] init];
        _discoverCharacteristicsTimers = [[NSMutableDictionary alloc] init];
        _discoverDescriptorsTimers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self cleanDiscoverServicesTimer];
    for (CBUUID *UUID in _discoverIncludedServicesTimers.allKeys) {
        [self cleanDiscoverIncludedServicesTimerForUUID:UUID];
    }
    AGX_RELEASE(_discoverIncludedServicesTimers);
    for (CBUUID *UUID in _discoverCharacteristicsTimers.allKeys) {
        [self cleanDiscoverCharacteristicsTimerForUUID:UUID];
    }
    AGX_RELEASE(_discoverCharacteristicsTimers);
    for (CBUUID *UUID in _discoverDescriptorsTimers.allKeys) {
        [self cleanDiscoverDescriptorsTimerForUUID:UUID];
    }
    AGX_RELEASE(_discoverDescriptorsTimers);
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

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs {
    if ([self checkDiscoveringServices]) return;
    [self resetDiscoverServicesTimer];
    [_peripheral discoverServices:serviceUUIDs];
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(AGXBLEService *)service {
    if ([self checkDiscoveringIncludedServicesForService:service]) return;
    [self resetDiscoverIncludedServicesTimerForService:service];
    [_peripheral discoverIncludedServices:includedServiceUUIDs forService:service.service];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(AGXBLEService *)service {
    if ([self checkDiscoveringCharacteristicsForService:service]) return;
    [self resetDiscoverCharacteristicsTimerForService:service];
    [_peripheral discoverCharacteristics:characteristicUUIDs forService:service.service];
}

-(void)discoverDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic {
    if ([self checkDiscoveringDescriptorsForCharacteristic:characteristic]) return;
    [self resetDiscoverDescriptorsTimerForCharacteristic:characteristic];
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

#define CBPeripheralAssert {if AGX_EXPECT_F(_peripheral != peripheral) return;}
#define PeripheralIsEqual(peripheral) [peripheral.identifier.UUIDString isEqualToString:_peripheral.identifier.UUIDString]

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    CBPeripheralAssert
    self.RSSI = RSSI;
    if ([self.delegate respondsToSelector:@selector(peripheral:didReadRSSI:error:)])
        [self.delegate peripheral:self didReadRSSI:_RSSI error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBPeripheralAssert
    if (![self cleanDiscoverServicesTimer]) return;
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverServices:)])
        [self.delegate peripheral:self didDiscoverServices:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    CBPeripheralAssert
    if (![self cleanDiscoverIncludedServicesTimerForUUID:service.UUID]) return;
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)])
        [self.delegate peripheral:self didDiscoverIncludedServicesForService:
         [AGXBLEService serviceWithService:service andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    CBPeripheralAssert
    if (![self cleanDiscoverCharacteristicsTimerForUUID:service.UUID]) return;
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)])
        [self.delegate peripheral:self didDiscoverCharacteristicsForService:
         [AGXBLEService serviceWithService:service andOwnPeripheral:self] error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBPeripheralAssert
    if (![self cleanDiscoverDescriptorsTimerForUUID:characteristic.UUID]) return;
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
#undef CBPeripheralAssert

#pragma mark - Private methods

#pragma mark - discoverServicesTimer

- (BOOL)checkDiscoveringServices {
    return _discoverServicesTimer != nil;
}

NSTimeInterval AGXDiscoverServicesTimeout = 3;

- (void)resetDiscoverServicesTimer {
    [self cleanDiscoverServicesTimer];
    NSTimeInterval ti = MAX(3, AGXDiscoverServicesTimeout);
    if ([self.delegate respondsToSelector:@selector(peripheralDiscoverServicesTimeout:)])
    { ti = MAX(ti, [self.delegate peripheralDiscoverServicesTimeout:self]); }

    _discoverServicesTimer = AGX_RETAIN([NSTimer scheduledTimerWithTimeInterval:ti target:self selector:
                                         @selector(discoverServicesTimeout:) userInfo:nil repeats:NO]);
}

- (BOOL)cleanDiscoverServicesTimer {
    @synchronized(self) {
        if (!_discoverServicesTimer) return NO;
        [_discoverServicesTimer invalidate];
        AGX_RELEASE(_discoverServicesTimer);
        _discoverServicesTimer = nil;
        return YES;
    }
}

- (void)discoverServicesTimeout:(NSTimer *)timer {
    [self peripheral:_peripheral didDiscoverServices:
     [NSError errorWithDomain:@"Discover Services Timeout" code:1013 userInfo:nil]];
}

#pragma mark - discoverIncludedServicesTimer

- (NSTimer *)discoverIncludedServicesTimerForUUID:(CBUUID *)UUID  {
    return _discoverIncludedServicesTimers[UUID];
}

- (void)setDiscoverIncludedServicesTimer:(NSTimer *)discoverIncludedServicesTimer forUUID:(CBUUID *)UUID {
    _discoverIncludedServicesTimers[UUID] = discoverIncludedServicesTimer;
}

- (BOOL)checkDiscoveringIncludedServicesForService:(AGXBLEService *)service {
    return [self discoverIncludedServicesTimerForUUID:service.UUID] != nil;
}

NSTimeInterval AGXDiscoverIncludedServicesTimeout = 3;

- (void)resetDiscoverIncludedServicesTimerForService:(AGXBLEService *)service {
    [self cleanDiscoverIncludedServicesTimerForUUID:service.UUID];
    NSTimeInterval ti = MAX(3, AGXDiscoverIncludedServicesTimeout);
    if ([self.delegate respondsToSelector:@selector(peripheral:discoverIncludedServicesTimeout:)])
    { ti = MAX(ti, [self.delegate peripheral:self discoverIncludedServicesTimeout:service]); }

    [self setDiscoverIncludedServicesTimer:
     [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:
      @selector(discoverIncludedServicesTimeout:) userInfo:service.service repeats:NO]
                                   forUUID:service.UUID];
}

- (BOOL)cleanDiscoverIncludedServicesTimerForUUID:(CBUUID *)UUID {
    @synchronized(self) {
        NSTimer *timer = [self discoverIncludedServicesTimerForUUID:UUID];
        if (!timer) return NO;
        [timer invalidate];
        [self setDiscoverIncludedServicesTimer:nil forUUID:UUID];
        return YES;
    }
}

- (void)discoverIncludedServicesTimeout:(NSTimer *)timer {
    [self peripheral:_peripheral didDiscoverIncludedServicesForService:timer.userInfo
               error:[NSError errorWithDomain:@"Discover Included Services Timeout" code:1019 userInfo:nil]];
}

#pragma mark - discoverCharacteristicsTimer

- (NSTimer *)discoverCharacteristicsTimerForUUID:(CBUUID *)UUID  {
    return _discoverCharacteristicsTimers[UUID];
}

- (void)setDiscoverCharacteristicsTimer:(NSTimer *)discoverCharacteristicsTimer forUUID:(CBUUID *)UUID {
    _discoverCharacteristicsTimers[UUID] = discoverCharacteristicsTimer;
}

- (BOOL)checkDiscoveringCharacteristicsForService:(AGXBLEService *)service {
    return [self discoverCharacteristicsTimerForUUID:service.UUID] != nil;
}

NSTimeInterval AGXDiscoverCharacteristicsTimeout = 3;

- (void)resetDiscoverCharacteristicsTimerForService:(AGXBLEService *)service {
    [self cleanDiscoverCharacteristicsTimerForUUID:service.UUID];
    NSTimeInterval ti = MAX(3, AGXDiscoverCharacteristicsTimeout);
    if ([self.delegate respondsToSelector:@selector(peripheral:discoverCharacteristicsTimeout:)])
    { ti = MAX(ti, [self.delegate peripheral:self discoverCharacteristicsTimeout:service]); }

    [self setDiscoverCharacteristicsTimer:
     [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:
      @selector(discoverCharacteristicsTimeout:) userInfo:service.service repeats:NO]
                                  forUUID:service.UUID];
}

- (BOOL)cleanDiscoverCharacteristicsTimerForUUID:(CBUUID *)UUID {
    @synchronized(self) {
        NSTimer *timer = [self discoverCharacteristicsTimerForUUID:UUID];
        if (!timer) return NO;
        [timer invalidate];
        [self setDiscoverCharacteristicsTimer:nil forUUID:UUID];
        return YES;
    }
}

- (void)discoverCharacteristicsTimeout:(NSTimer *)timer {
    [self peripheral:_peripheral didDiscoverCharacteristicsForService:timer.userInfo
               error:[NSError errorWithDomain:@"Discover Characteristics Timeout" code:1021 userInfo:nil]];
}

#pragma mark - discoverDescriptorsTimer

- (NSTimer *)discoverDescriptorsTimerForUUID:(CBUUID *)UUID  {
    return _discoverDescriptorsTimers[UUID];
}

- (void)setDiscoverDescriptorsTimer:(NSTimer *)discoverDescriptorsTimer forUUID:(CBUUID *)UUID {
    _discoverDescriptorsTimers[UUID] = discoverDescriptorsTimer;
}

- (BOOL)checkDiscoveringDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic {
    return [self discoverCharacteristicsTimerForUUID:characteristic.UUID] != nil;
}

NSTimeInterval AGXDiscoverDescriptorsTimeout = 3;

- (void)resetDiscoverDescriptorsTimerForCharacteristic:(AGXCharacteristic *)characteristic {
    [self cleanDiscoverDescriptorsTimerForUUID:characteristic.UUID];
    NSTimeInterval ti = MAX(3, AGXDiscoverDescriptorsTimeout);
    if ([self.delegate respondsToSelector:@selector(peripheral:discoverDescriptorsTimeout:)])
    { ti = MAX(ti, [self.delegate peripheral:self discoverDescriptorsTimeout:characteristic]); }

    [self setDiscoverDescriptorsTimer:
     [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:
      @selector(discoverDescriptorsTimeout:) userInfo:characteristic.characteristic repeats:NO]
                              forUUID:characteristic.UUID];
}

- (BOOL)cleanDiscoverDescriptorsTimerForUUID:(CBUUID *)UUID {
    @synchronized(self) {
        NSTimer *timer = [self discoverDescriptorsTimerForUUID:UUID];
        if (!timer) return NO;
        [timer invalidate];
        [self setDiscoverDescriptorsTimer:nil forUUID:UUID];
        return YES;
    }
}

- (void)discoverDescriptorsTimeout:(NSTimer *)timer {
    [self peripheral:_peripheral didDiscoverDescriptorsForCharacteristic:timer.userInfo
               error:[NSError errorWithDomain:@"Discover Descriptors Timeout" code:1031 userInfo:nil]];
}

@end
