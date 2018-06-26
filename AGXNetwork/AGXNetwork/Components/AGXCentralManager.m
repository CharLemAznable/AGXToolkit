//
//  AGXCentralManager.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXCentralManager.h"
#import "AGXPeripheral.h"
#import "NSUUID+AGXNetwork.h"

@interface AGXCentralManager() <CBCentralManagerDelegate>
@property (nonatomic, AGX_STRONG) CBCentralManager *centralManager;
@property (nonatomic, AGX_STRONG) NSMutableArray<AGXPeripheral *> *discoveredPeripherals;
@property (nonatomic, AGX_STRONG) AGXPeripheral *connectedPeripheral;
@property (nonatomic, AGX_STRONG) NSMutableDictionary *connectTimers;
@end

@implementation AGXCentralManager

+ (AGX_INSTANCETYPE)centralManager {
    return AGX_AUTORELEASE([[self alloc] init]);
}

+ (AGX_INSTANCETYPE)centralManagerWithQueue:(dispatch_queue_t)queue {
    return AGX_AUTORELEASE([[self alloc] initWithQueue:queue]);
}

+ (AGX_INSTANCETYPE)centralManagerWithQueue:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options {
    return AGX_AUTORELEASE([[self alloc] initWithQueue:queue options:options]);
}

- (AGX_INSTANCETYPE)init {
    return [self initWithQueue:nil];
}

- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue {
    return [self initWithQueue:queue options:nil];
}

- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options {
    if AGX_EXPECT_T(self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
        _discoveredPeripherals = [[NSMutableArray alloc] init];
        _connectTimers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    _centralManager.delegate = nil;
    [self stopScan];
    [self disconnectPeripheral];

    for (NSUUID *identifier in _connectTimers.allKeys) {
        [self cleanConnectTimerForIdentifier:identifier];
    }
    AGX_RELEASE(_connectTimers);

    AGX_RELEASE(_connectedPeripheral);
    AGX_RELEASE(_discoveredPeripherals);
    AGX_RELEASE(_centralManager);
    AGX_SUPER_DEALLOC;
}

- (NSArray<AGXPeripheral *> *)discoveredPeripherals {
    return AGX_AUTORELEASE([_discoveredPeripherals copy]);
}

- (CBCentralManagerState)state {
    return (CBCentralManagerState)_centralManager.state;
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *,id> *)options {
    [_centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (AGXPeripheral *)retrievePeripheralWithIdentifier:(NSUUID *)identifier {
    for (AGXPeripheral *peripheral in self.discoveredPeripherals) {
        if ([peripheral.identifier isEqual:identifier]) return peripheral;
    }
    return nil;
}

- (void)connectPeripheral:(AGXPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options {
    if AGX_EXPECT_F(!peripheral.peripheral) {
        [self.delegate centralManager:self didFailToConnectPeripheral:peripheral error:
         [NSError errorWithDomain:@"Peripheral Error" code:997 userInfo:nil]];
        return;
    }
    if ([self checkConnectingForPeripheral:peripheral]) return;
    [self resetConnectTimerForPeripheral:peripheral];
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

#define CBCentralManagerAssert {if AGX_EXPECT_F(_centralManager != central) return;}

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

    @synchronized(self) {
        NSInteger index = NSNotFound;
        for (AGXPeripheral *kPeripheral in self.discoveredPeripherals) {
            if ([kPeripheral.identifier.UUIDString isEqualToString:mPeripheral.identifier.UUIDString]) {
                index = [_discoveredPeripherals indexOfObject:kPeripheral];
                break;
            }
        }
        if (NSNotFound == index) [_discoveredPeripherals addObject:mPeripheral];
        else [_discoveredPeripherals replaceObjectAtIndex:index withObject:mPeripheral];
    }

    if ([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)])
        [self.delegate centralManager:self didDiscoverPeripheral:mPeripheral
                    advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    CBCentralManagerAssert
    if (![self cleanConnectTimerForIdentifier:peripheral.identifier]) {
        [central cancelPeripheralConnection:peripheral];
        return;
    }
    self.connectedPeripheral = [AGXPeripheral peripheralWithPeripheral:peripheral];
    if ([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)])
        [self.delegate centralManager:self didConnectPeripheral:self.connectedPeripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBCentralManagerAssert
    if (![self cleanConnectTimerForIdentifier:peripheral.identifier]) return;
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

#pragma mark - Private methods

- (NSTimer *)connectTimerForIdentifier:(NSUUID *)identifier  {
    return _connectTimers[identifier];
}

- (void)setConnectTimer:(NSTimer *)connectTimer forIdentifier:(NSUUID *)identifier {
    _connectTimers[identifier] = connectTimer;
}

- (BOOL)checkConnectingForPeripheral:(AGXPeripheral *)peripheral {
    return [self connectTimerForIdentifier:peripheral.identifier] != nil;
}

NSTimeInterval AGXConnectPeripheralTimeout = 3;

- (void)resetConnectTimerForPeripheral:(AGXPeripheral *)peripheral {
    [self cleanConnectTimerForIdentifier:peripheral.identifier];
    NSTimeInterval ti = MAX(3, AGXConnectPeripheralTimeout);
    if ([self.delegate respondsToSelector:@selector(centralManager:connectPeripheralTimeout:)])
    { ti = MAX(ti, [self.delegate centralManager:self connectPeripheralTimeout:peripheral]); }

    NSTimer *timer = [NSTimer timerWithTimeInterval:ti target:self selector:
                      @selector(connectTimeout:) userInfo:peripheral.peripheral repeats:NO];
    [self setConnectTimer:timer forIdentifier:peripheral.identifier];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (BOOL)cleanConnectTimerForIdentifier:(NSUUID *)identifier {
    @synchronized(self) {
        NSTimer *timer = [self connectTimerForIdentifier:identifier];
        if (!timer) return NO;
        [timer invalidate];
        [self setConnectTimer:nil forIdentifier:identifier];
        return YES;
    }
}

- (void)connectTimeout:(NSTimer *)timer {
    [self centralManager:_centralManager didFailToConnectPeripheral:timer.userInfo
                   error:[NSError errorWithDomain:@"Connect Timeout" code:1009 userInfo:nil]];
}

@end
