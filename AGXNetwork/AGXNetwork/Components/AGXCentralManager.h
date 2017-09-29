//
//  AGXCentralManager.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXCentralManager_h
#define AGXNetwork_AGXCentralManager_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>

AGX_EXTERN NSTimeInterval AGXConnectPeripheralTimeout;

@class AGXPeripheral;
@protocol AGXCentralManagerDelegate;

@interface AGXCentralManager : NSObject
@property (nonatomic, readonly) CBCentralManager *centralManager;
@property (nonatomic, readonly) NSArray<AGXPeripheral *> *discoveredPeripherals;
@property (nonatomic, readonly) AGXPeripheral *connectedPeripheral;
@property (nonatomic, readonly) CBCentralManagerState state;
@property (nonatomic, AGX_WEAK) id<AGXCentralManagerDelegate> delegate;

+ (AGX_INSTANCETYPE)centralManager;
+ (AGX_INSTANCETYPE)centralManagerWithQueue:(dispatch_queue_t)queue;
+ (AGX_INSTANCETYPE)centralManagerWithQueue:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options;
- (AGX_INSTANCETYPE)init;
- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue;
- (AGX_INSTANCETYPE)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options;

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *, id> *)options;
- (AGXPeripheral *)retrievePeripheralWithIdentifier:(NSUUID *)identifier;
- (void)connectPeripheral:(AGXPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options;
- (void)disconnectPeripheral;
- (void)stopScan;
@end

@protocol AGXCentralManagerDelegate <NSObject>
@optional
- (void)centralManagerDidUpdateState:(AGXCentralManager *)central;
- (BOOL)centralManager:(AGXCentralManager *)central shouldDiscoverPeripheral:(AGXPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)centralManager:(AGXCentralManager *)central didDiscoverPeripheral:(AGXPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI;
- (NSTimeInterval)centralManager:(AGXCentralManager *)central connectPeripheralTimeout:(AGXPeripheral *)peripheral;
- (void)centralManager:(AGXCentralManager *)central didConnectPeripheral:(AGXPeripheral *)peripheral;
- (void)centralManager:(AGXCentralManager *)central didFailToConnectPeripheral:(AGXPeripheral *)peripheral error:(NSError *)error;
- (void)centralManager:(AGXCentralManager *)central didDisconnectPeripheral:(AGXPeripheral *)peripheral error:(NSError *)error;
@end

#endif /* AGXNetwork_AGXCentralManager_h */
