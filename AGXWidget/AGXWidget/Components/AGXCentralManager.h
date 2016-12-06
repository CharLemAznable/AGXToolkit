//
//  AGXCentralManager.h
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

#ifndef AGXWidget_AGXCentralManager_h
#define AGXWidget_AGXCentralManager_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXBluetooth.h"

@protocol AGXCentralManagerPeripheralFilter;

@interface AGXCentralManager : NSObject
@property (nonatomic, readonly) CBCentralManager *centralManager;
@property (nonatomic, readonly) CBCentralManagerState state;
@property (nonatomic)           AGXCentralDidUpdateStateBlock updateStateBlock;
@property (nonatomic, readonly) NSArray<AGXPeripheral *> *discoveredPeripherals;
@property (nonatomic, readonly) AGXPeripheral *connectedPeripheral;
@property (nonatomic, AGX_WEAK) id<AGXCentralManagerPeripheralFilter> filter;

- (AGX_INSTANCETYPE)init;
- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue;
- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary<NSString *, id> *)options NS_DESIGNATED_INITIALIZER;

- (NSArray<AGXPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;
- (NSArray<AGXPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs;
- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *, id> *)options withBlock:(AGXCentralDidDiscoverPeripheralBlock)block;
- (void)stopScan;
- (void)connectPeripheral:(AGXPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options withSuccessBlock:(AGXCentralDidConnectPeripheralBlock)successBlock withFailedBlock:(AGXCentralDidFailToConnectPeripheralBlock)failedBlock;
- (void)cancelPeripheralConnection:(AGXPeripheral *)peripheral withBlock:(AGXCentralDidDisconnectPeripheralBlock)block;
@end

@protocol AGXCentralManagerPeripheralFilter <NSObject>
- (BOOL)centralManager:(AGXCentralManager *)centralManager shouldShowPeripheral:(AGXPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData;
@end

#endif /* AGXWidget_AGXCentralManager_h */
