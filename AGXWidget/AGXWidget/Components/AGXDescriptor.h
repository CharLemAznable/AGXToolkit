//
//  AGXDescriptor.h
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXDescriptor_h
#define AGXWidget_AGXDescriptor_h

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

#endif /* AGXWidget_AGXDescriptor_h */
