//
//  AGXCharacteristic.h
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

#ifndef AGXWidget_AGXCharacteristic_h
#define AGXWidget_AGXCharacteristic_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXBluetooth.h"

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

- (void)discoverDescriptorsWithBlock:(AGXPeripheralDiscoverDescriptorsForCharacteristicBlock)block;
- (void)readValueWithBlock:(AGXPeripheralReadValueForCharacteristicBlock)block;
- (void)writeValue:(NSData *)data type:(CBCharacteristicWriteType)type withBlock:(AGXPeripheralWriteValueForCharacteristicsBlock)block;
- (void)setNotifyValue:(BOOL)enabled withBlock:(AGXPeripheralNotifyValueForCharacteristicsBlock)block;
@end

#endif /* AGXWidget_AGXCharacteristic_h */
