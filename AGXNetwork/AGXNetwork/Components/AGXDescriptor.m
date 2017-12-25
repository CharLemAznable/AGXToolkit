//
//  AGXDescriptor.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXDescriptor.h"
#import "AGXPeripheral.h"
#import "AGXCharacteristic.h"

@interface AGXDescriptor ()
@property (nonatomic, AGX_STRONG)   CBDescriptor *descriptor;
@property (nonatomic, AGX_WEAK)     AGXPeripheral *ownPeripheral;
@end

@implementation AGXDescriptor {
    AGXCharacteristic *_charactreistic;
}

+ (AGX_INSTANCETYPE)descriptorWithDescriptor:(CBDescriptor *)descriptor andOwnPeripheral:(AGXPeripheral *)peripheral {
    return AGX_AUTORELEASE([[self alloc] initWithDescriptor:descriptor andOwnPeripheral:peripheral]);
}

- (AGX_INSTANCETYPE)initWithDescriptor:(CBDescriptor *)descriptor andOwnPeripheral:(AGXPeripheral *)peripheral {
    if AGX_EXPECT_T(self = [super init]) {
        _descriptor = AGX_RETAIN(descriptor);
        _ownPeripheral = peripheral;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_charactreistic);
    _ownPeripheral = nil;
    AGX_RELEASE(_descriptor);
    AGX_SUPER_DEALLOC;
}

- (AGXCharacteristic *)characteristic {
    if AGX_EXPECT_F(!_charactreistic) {
        _charactreistic = [[AGXCharacteristic alloc] initWithCharacteristic:
                           _descriptor.characteristic andOwnPeripheral:_ownPeripheral];
    }
    return _charactreistic;
}

- (CBUUID *)UUID {
    return _descriptor.UUID;
}

- (id)value {
    return _descriptor.value;
}

- (void)readValue {
    if AGX_EXPECT_T(_ownPeripheral) [_ownPeripheral readValueForDescriptor:self];
}

- (void)writeValue:(NSData *)data {
    if AGX_EXPECT_T(_ownPeripheral) [_ownPeripheral writeValue:data forDescriptor:self];
}

@end
