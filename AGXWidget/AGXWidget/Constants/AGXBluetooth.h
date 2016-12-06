//
//  AGXBluetooth.h
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

#ifndef AGXWidget_AGXBluetooth_h
#define AGXWidget_AGXBluetooth_h

#import <Foundation/Foundation.h>

@class AGXCentralManager;
@class AGXPeripheral;
@class AGXCharacteristic;
@class AGXBLEService;
@class AGXDescriptor;

#pragma mark - central

typedef void (^AGXCentralDidDiscoverPeripheralBlock)(AGXCentralManager *centralManager, AGXPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);
typedef void (^AGXCentralDidConnectPeripheralBlock)(AGXCentralManager *centralManager, AGXPeripheral *peripheral);
typedef void (^AGXCentralDidDisconnectPeripheralBlock)(AGXCentralManager *centralManager, AGXPeripheral *peripheral, NSError *error);
typedef void (^AGXCentralDidUpdateStateBlock)(AGXCentralManager *centralManager);
typedef void (^AGXCentralDidFailToConnectPeripheralBlock)(AGXCentralManager *centralManager, AGXPeripheral *peripheral, NSError *error);

#pragma mark - peripheral

typedef void (^AGXPeripheralDiscoverServicesBlock)(AGXPeripheral *peripheral, NSError *error);
typedef void (^AGXPeripheralDiscoverIncludedServicesBlock)(AGXPeripheral *peripheral, AGXBLEService *service, NSError *error);
typedef void (^AGXPeripheralDiscoverCharacteristicsBlock)(AGXPeripheral *peripheral, AGXBLEService *service, NSError *error);
typedef void (^AGXPeripheralReadValueForCharacteristicBlock)(AGXPeripheral *peripheral, AGXCharacteristic *characteristic, NSError *error);
typedef void (^AGXPeripheralWriteValueForCharacteristicsBlock)(AGXPeripheral *peripheral, AGXCharacteristic *characteristic, NSError *error);
typedef void (^AGXPeripheralNotifyValueForCharacteristicsBlock)(AGXPeripheral *peripheral, AGXCharacteristic *characteristic, NSError *error);
typedef void (^AGXPeripheralDiscoverDescriptorsForCharacteristicBlock)(AGXPeripheral *peripheral, AGXCharacteristic *service, NSError *error);
typedef void (^AGXPeripheralReadValueForDescriptorsBlock)(AGXPeripheral *peripheral, AGXDescriptor *descriptor, NSError *error);
typedef void (^AGXPeripheralWriteValueForDescriptorsBlock)(AGXPeripheral *peripheral, AGXDescriptor *descriptor, NSError *error);
typedef void (^AGXPeripheralRedRSSIBlock)(AGXPeripheral *peripheral, NSNumber *RSSI, NSError *error);
typedef void (^AGXPeripheralReadMacBlock)(AGXPeripheral *peripheral, NSString *macString, NSError *error);

#pragma mark - utils

@interface AGXBluetooth : NSObject
+ (int8_t)dataToByte:(NSData *)data;
+ (int16_t)dataToInt16:(NSData *)data;
+ (int32_t)dataToInt32:(NSData *)data;
@end

#endif /* AGXWidget_AGXBluetooth_h */
