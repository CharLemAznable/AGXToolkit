//
//  AGXDescriptor.m
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

- (void)readValueForWithBlock:(AGXPeripheralReadValueForDescriptorsBlock)block {
    if (_ownPeripheral) [_ownPeripheral readValueForDescriptor:self withBlock:block];
}

- (void)writeValue:(NSData *)data withBlock:(AGXPeripheralWriteValueForDescriptorsBlock)block {
    if (_ownPeripheral) [_ownPeripheral writeValue:data forDescriptor:self withBlock:block];
}

@end
