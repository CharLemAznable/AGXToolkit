//
//  AGXCentralManager.m
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXCentralManager.h"
#import "AGXPeripheral.h"

@interface AGXCentralManager() <CBCentralManagerDelegate>
@property (nonatomic, AGX_STRONG) CBCentralManager *centralManager;
@property (nonatomic, AGX_STRONG) NSMutableArray<AGXPeripheral *> *discoveredPeripherals;
@property (nonatomic, AGX_STRONG) AGXPeripheral *connectedPeripheral;
@end

@implementation AGXCentralManager

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
    _delegate = nil;
    _centralManager.delegate = nil;
    [self stopScan];
    [self disconnectPeripheral];

    AGX_RELEASE(_connectedPeripheral);
    AGX_RELEASE(_discoveredPeripherals);
    AGX_RELEASE(_centralManager);
    AGX_SUPER_DEALLOC;
}

- (CBCentralManagerState)state {
    return (CBCentralManagerState)_centralManager.state;
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *,id> *)options {
    [_centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (AGXPeripheral *)retrievePeripheralWithIdentifier:(NSUUID *)identifier {
    for (AGXPeripheral *peripheral in _discoveredPeripherals) {
        if ([peripheral.identifier isEqual:identifier]) return peripheral;
    }
    return nil;
}

- (void)connectPeripheral:(AGXPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options {
    [_centralManager connectPeripheral:peripheral.peripheral options:options];
}

- (void)disconnectPeripheral {
    if (!_connectedPeripheral || !_connectedPeripheral.peripheral) return;
    [_centralManager cancelPeripheralConnection:_connectedPeripheral.peripheral];
}

- (void)stopScan {
    [_discoveredPeripherals removeAllObjects];
    [_centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate

#define CBCentralManagerAssert {if (_centralManager != central) return;}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    CBCentralManagerAssert
    [_discoveredPeripherals removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(centralManagerDidUpdateState:)])
        [self.delegate centralManagerDidUpdateState:self];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    CBCentralManagerAssert
    AGXPeripheral *mPeripheral = [AGXPeripheral peripheralWithPeripheral:peripheral];

    BOOL shouldDiscover = YES;
    if ([self.delegate respondsToSelector:@selector(centralManager:shouldDiscoverPeripheral:advertisementData:RSSI:)])
        shouldDiscover = [self.delegate centralManager:self shouldDiscoverPeripheral:mPeripheral
                                     advertisementData:advertisementData RSSI:RSSI];
    if (!shouldDiscover) return;

    NSInteger index = NSNotFound;
    for (AGXPeripheral *kPeripheral in _discoveredPeripherals) {
        if ([kPeripheral.identifier.UUIDString isEqualToString:mPeripheral.identifier.UUIDString]) {
            index = [_discoveredPeripherals indexOfObject:kPeripheral];
            break;
        }
    }
    if (index == NSNotFound) [_discoveredPeripherals addObject:mPeripheral];
    else [_discoveredPeripherals replaceObjectAtIndex:index withObject:mPeripheral];

    if ([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)])
        [self.delegate centralManager:self didDiscoverPeripheral:mPeripheral
                    advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    CBCentralManagerAssert
    self.connectedPeripheral = [AGXPeripheral peripheralWithPeripheral:peripheral];
    if ([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)])
        [self.delegate centralManager:self didConnectPeripheral:self.connectedPeripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBCentralManagerAssert
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)])
        [self.delegate centralManager:self didFailToConnectPeripheral:
         [AGXPeripheral peripheralWithPeripheral:peripheral] error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBCentralManagerAssert
    self.connectedPeripheral = nil;
    if ([self.delegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)])
        [self.delegate centralManager:self didDisconnectPeripheral:
         [AGXPeripheral peripheralWithPeripheral:peripheral] error:error];
}

#undef CBCentralManagerAssert

@end
