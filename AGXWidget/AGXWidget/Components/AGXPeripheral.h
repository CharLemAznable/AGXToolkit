//
//  AGXPeripheral.h
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

#ifndef AGXWidget_AGXPeripheral_h
#define AGXWidget_AGXPeripheral_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXBluetooth.h"

@interface AGXPeripheral : NSObject
@property (nonatomic, readonly) CBPeripheral *peripheral;
@property (nonatomic, readonly) NSUUID *identifier;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CBPeripheralState state;
@property (nonatomic, readonly) NSArray<AGXBLEService *> *services;
@property (nonatomic, readonly) NSNumber *RSSI;

+ (AGX_INSTANCETYPE)peripheralWithPeripheral:(CBPeripheral *)peripheral;
- (AGX_INSTANCETYPE)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)readRSSI:(AGXPeripheralRedRSSIBlock)block;
- (void)readMac:(AGXPeripheralReadMacBlock)block;
- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs withBlock:(AGXPeripheralDiscoverServicesBlock)block;
- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(AGXBLEService *)service withBlock:(AGXPeripheralDiscoverIncludedServicesBlock)block;
- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(AGXBLEService *)service withBlock:(AGXPeripheralDiscoverCharacteristicsBlock)block;
- (void)discoverDescriptorsForCharacteristic:(AGXCharacteristic *)characteristic withBlock:(AGXPeripheralDiscoverDescriptorsForCharacteristicBlock)block;
- (void)readValueForCharacteristic:(AGXCharacteristic *)characteristic withBlock:(AGXPeripheralReadValueForCharacteristicBlock)block;
- (void)writeValue:(NSData *)data forCharacteristic:(AGXCharacteristic *)characteristic type:(CBCharacteristicWriteType)type withBlock:(AGXPeripheralWriteValueForCharacteristicsBlock)block;
- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(AGXCharacteristic *)characteristic withBlock:(AGXPeripheralNotifyValueForCharacteristicsBlock)block;
- (void)readValueForDescriptor:(AGXDescriptor *)descriptor withBlock:(AGXPeripheralReadValueForDescriptorsBlock)block;
- (void)writeValue:(NSData *)data forDescriptor:(AGXDescriptor *)descriptor withBlock:(AGXPeripheralWriteValueForDescriptorsBlock)block;
@end

#endif /* AGXWidget_AGXPeripheral_h */
