//
//  AGXDescriptor.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXDescriptor_h
#define AGXNetwork_AGXDescriptor_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXCore/AGXCore/AGXArc.h>

@class AGXPeripheral;
@class AGXCharacteristic;

@interface AGXDescriptor : NSObject
@property (nonatomic, readonly) CBDescriptor *descriptor;
@property (nonatomic, readonly) AGXCharacteristic *characteristic;
@property (nonatomic, readonly) CBUUID *UUID;
@property (nonatomic, readonly) id value;

+ (AGX_INSTANCETYPE)descriptorWithDescriptor:(CBDescriptor *)descriptor andOwnPeripheral:(AGXPeripheral *)peripheral;
- (AGX_INSTANCETYPE)initWithDescriptor:(CBDescriptor *)descriptor andOwnPeripheral:(AGXPeripheral *)peripheral;

- (void)readValue;
- (void)writeValue:(NSData *)data;
@end

#endif /* AGXNetwork_AGXDescriptor_h */
