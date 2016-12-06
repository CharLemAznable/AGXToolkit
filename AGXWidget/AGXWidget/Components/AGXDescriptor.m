//
//  AGXDescriptor.m
//  AGXWidget
//
//  Created by Char Aznable on 16/12/5.
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
    if (self = [super init]) {
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
    if (!_charactreistic) {
        _charactreistic = [[AGXCharacteristic alloc] initWithCharacteristic:_descriptor.characteristic andOwnPeripheral:_ownPeripheral];
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
    if (_ownPeripheral) [_ownPeripheral readValueForDescriptor:self];
}

- (void)writeValue:(NSData *)data {
    if (_ownPeripheral) [_ownPeripheral writeValue:data forDescriptor:self];
}

@end
