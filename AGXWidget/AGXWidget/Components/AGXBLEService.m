//
//  AGXBLEService.m
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
    if (self = [super init]) {
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

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs withBlock:(AGXPeripheralDiscoverIncludedServicesBlock)block {
    if (_ownPeipheral) [_ownPeipheral discoverIncludedServices:includedServiceUUIDs forService:self withBlock:block];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs withBlock:(AGXPeripheralDiscoverCharacteristicsBlock)block {
    if (_ownPeipheral) [_ownPeipheral discoverCharacteristics:characteristicUUIDs forService:self withBlock:block];
}

@end
