//
//  AGXBLEService.h
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

#ifndef AGXWidget_AGXBLEService_h
#define AGXWidget_AGXBLEService_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXBluetooth.h"

@interface AGXBLEService : NSObject
@property (nonatomic, readonly) CBService *service;
@property (nonatomic, readonly) CBUUID *UUID;
@property (nonatomic, readonly) BOOL isPrimary;
@property (nonatomic, readonly) NSArray<AGXBLEService *> *includedServices;
@property (nonatomic, readonly) NSArray<AGXCharacteristic *> *characteristics;

+ (AGX_INSTANCETYPE)serviceWithService:(CBService *)service andOwnPeripheral:(AGXPeripheral *)peripheral;
- (AGX_INSTANCETYPE)initWithService:(CBService *)service andOwnPeripheral:(AGXPeripheral *)peripheral;

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs withBlock:(AGXPeripheralDiscoverIncludedServicesBlock)block;
- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs withBlock:(AGXPeripheralDiscoverCharacteristicsBlock)block;
@end

#endif /* AGXWidget_AGXBLEService_h */
