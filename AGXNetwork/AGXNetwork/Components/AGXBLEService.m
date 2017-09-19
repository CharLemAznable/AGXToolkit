//
//  AGXBLEService.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXBLEService.h"
#import "AGXPeripheral.h"
#import "AGXCharacteristic.h"

@interface AGXBLEService ()
@property (nonatomic, AGX_STRONG)   CBService *service;
@property (nonatomic, AGX_WEAK)     AGXPeripheral *ownPeipheral;
@end

@implementation AGXBLEService

+ (AGX_INSTANCETYPE)serviceWithService:(CBService *)service andOwnPeripheral:(AGXPeripheral *)peripheral {
    return AGX_AUTORELEASE([[self alloc] initWithService:service andOwnPeripheral:peripheral]);
}

- (AGX_INSTANCETYPE)initWithService:(CBService *)service andOwnPeripheral:(AGXPeripheral *)peripheral {
    if (AGX_EXPECT_T(self = [super init])) {
        _service = AGX_RETAIN(service);
        _ownPeipheral = peripheral;
    }
    return self;
}

- (void)dealloc {
    _ownPeipheral = nil;
    AGX_RELEASE(_service);
    AGX_SUPER_DEALLOC;
}

- (CBUUID *)UUID {
    return _service.UUID;
}

- (BOOL)isPrimary {
    return _service.isPrimary;
}

- (NSArray<AGXBLEService *> *)includedServices {
    NSMutableArray *array = [NSMutableArray array];
    for (CBService *service in _service.includedServices) {
        [array addObject:[AGXBLEService serviceWithService:service
                                          andOwnPeripheral:_ownPeipheral]];
    }
    return array;
}

- (NSArray<AGXCharacteristic *> *)characteristics {
    NSMutableArray *array = [NSMutableArray array];
    for (CBCharacteristic *characteristic in _service.characteristics) {
        [array addObject:[AGXCharacteristic characteristicWithCharacteristic:characteristic
                                                            andOwnPeripheral:_ownPeipheral]];
    }
    return array;
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs {
    if (_ownPeipheral) [_ownPeipheral discoverIncludedServices:includedServiceUUIDs forService:self];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs {
    if (_ownPeipheral) [_ownPeipheral discoverCharacteristics:characteristicUUIDs forService:self];
}

@end
