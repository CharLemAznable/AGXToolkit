//
//  AGXCentralManager.m
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

#import "AGXCentralManager.h"
#import "AGXPeripheral.h"

@interface AGXCentralManager() <CBCentralManagerDelegate>
@property (nonatomic, AGX_STRONG) CBCentralManager *centralManager;
@property (nonatomic, AGX_STRONG) NSMutableArray<AGXPeripheral *> *discoveredPeripherals;
@property (nonatomic, AGX_STRONG) AGXPeripheral *connectedPeripheral;
@end

@implementation AGXCentralManager {
    AGXCentralDidUpdateStateBlock _updateStateBlock;
    AGXCentralDidDiscoverPeripheralBlock _didDiscoverPeripheralBlock;
    AGXCentralDidConnectPeripheralBlock _didConnectPeripheralBlock;
    AGXCentralDidFailToConnectPeripheralBlock _didFailToConnectPeripheralBlock;
    AGXCentralDidDisconnectPeripheralBlock _didDisconnectPeripheralBlock;
}

- (AGX_INSTANCETYPE)init {
    return [self initWithQueue:nil];
}

- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue {
    return [self initWithQueue:queue options:nil];
}

- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options {
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
        _discoveredPeripherals = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    _centralManager.delegate = nil;
    [_centralManager stopScan];

    if (AGX_EXPECT_T(_updateStateBlock)) AGX_BLOCK_RELEASE(_updateStateBlock);
    if (AGX_EXPECT_T(_didDiscoverPeripheralBlock)) AGX_BLOCK_RELEASE(_didDiscoverPeripheralBlock);
    if (AGX_EXPECT_T(_didConnectPeripheralBlock)) AGX_BLOCK_RELEASE(_didConnectPeripheralBlock);
    if (AGX_EXPECT_T(_didFailToConnectPeripheralBlock)) AGX_BLOCK_RELEASE(_didFailToConnectPeripheralBlock);
    if (AGX_EXPECT_T(_didDisconnectPeripheralBlock)) AGX_BLOCK_RELEASE(_didDisconnectPeripheralBlock);
    AGX_RELEASE(_connectedPeripheral);
    AGX_RELEASE(_discoveredPeripherals);
    AGX_RELEASE(_centralManager);
    _filter = nil;
    AGX_SUPER_DEALLOC;
}

- (AGXCentralDidUpdateStateBlock)updateStateBlock {
    return _updateStateBlock;
}

- (void)setUpdateStateBlock:(AGXCentralDidUpdateStateBlock)updateStateBlock {
    AGXCentralDidUpdateStateBlock temp = AGX_BLOCK_COPY(updateStateBlock);
    if (AGX_EXPECT_T(_updateStateBlock)) AGX_BLOCK_RELEASE(_updateStateBlock);
    _updateStateBlock = temp;
}

- (CBCentralManagerState)state {
    return (CBCentralManagerState)_centralManager.state;
}

- (NSArray<AGXPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers {
    NSArray *peripherals = [_centralManager retrievePeripheralsWithIdentifiers:identifiers];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:peripherals.count];
    for (CBPeripheral *peripheral in peripherals) {
        [result addObject:[AGXPeripheral peripheralWithPeripheral:peripheral]];
    }
    return result;
}

- (NSArray<AGXPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs {
    NSArray *peripherals = [_centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:peripherals.count];
    for (CBPeripheral *peripheral in peripherals) {
        [result addObject:[AGXPeripheral peripheralWithPeripheral:peripheral]];
    }
    return result;
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *,id> *)options withBlock:(AGXCentralDidDiscoverPeripheralBlock)block {
    AGXCentralDidDiscoverPeripheralBlock temp = AGX_BLOCK_COPY(block);
    if (AGX_EXPECT_T(_didDiscoverPeripheralBlock)) AGX_BLOCK_RELEASE(_didDiscoverPeripheralBlock);
    _didDiscoverPeripheralBlock = temp;

    [_centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void)stopScan {
    [_discoveredPeripherals removeAllObjects];
    [_centralManager stopScan];
}

- (void)connectPeripheral:(AGXPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options withSuccessBlock:(AGXCentralDidConnectPeripheralBlock)successBlock withFailedBlock:(AGXCentralDidFailToConnectPeripheralBlock)failedBlock {
    AGXCentralDidConnectPeripheralBlock success = AGX_BLOCK_COPY(successBlock);
    if (AGX_EXPECT_T(_didConnectPeripheralBlock)) AGX_BLOCK_RELEASE(_didConnectPeripheralBlock);
    _didConnectPeripheralBlock = success;
    AGXCentralDidFailToConnectPeripheralBlock failed = AGX_BLOCK_COPY(failedBlock);
    if (AGX_EXPECT_T(_didFailToConnectPeripheralBlock)) AGX_BLOCK_RELEASE(_didFailToConnectPeripheralBlock);
    _didFailToConnectPeripheralBlock = failed;

    [_centralManager connectPeripheral:peripheral.peripheral options:options];
}

- (void)cancelPeripheralConnection:(AGXPeripheral *)peripheral withBlock:(AGXCentralDidDisconnectPeripheralBlock)block {
    AGXCentralDidDisconnectPeripheralBlock temp = AGX_BLOCK_COPY(block);
    if (AGX_EXPECT_T(_didDisconnectPeripheralBlock)) AGX_BLOCK_RELEASE(_didDisconnectPeripheralBlock);
    _didDisconnectPeripheralBlock = temp;

    [_centralManager cancelPeripheralConnection:peripheral.peripheral];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [_discoveredPeripherals removeAllObjects];
    if (_updateStateBlock) _updateStateBlock(self);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    AGXPeripheral *mPeripheral = [AGXPeripheral peripheralWithPeripheral:peripheral];
    BOOL shouldShow = YES;
    NSInteger index = NSNotFound;

    if (_filter) shouldShow = [_filter centralManager:self shouldShowPeripheral:mPeripheral
                                    advertisementData:advertisementData];
    if (!shouldShow) return;

    for (AGXPeripheral *kPeripheral in _discoveredPeripherals) {
        if ([kPeripheral.identifier.UUIDString isEqualToString:mPeripheral.identifier.UUIDString]) {
            index = [_discoveredPeripherals indexOfObject:kPeripheral];
        }
    }

    if (index != NSNotFound) {
        [_discoveredPeripherals replaceObjectAtIndex:index withObject:mPeripheral];
    } else {
        [_discoveredPeripherals addObject:mPeripheral];
    }

    if (_didDiscoverPeripheralBlock) _didDiscoverPeripheralBlock
        (self, mPeripheral, advertisementData, RSSI);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.connectedPeripheral = [AGXPeripheral peripheralWithPeripheral:peripheral];
    if (_didConnectPeripheralBlock) _didConnectPeripheralBlock(self, self.connectedPeripheral);
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (_didFailToConnectPeripheralBlock) _didFailToConnectPeripheralBlock(self, self.connectedPeripheral, error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (_didDisconnectPeripheralBlock) _didDisconnectPeripheralBlock(self, self.connectedPeripheral, error);
    self.connectedPeripheral = nil;
}

@end
