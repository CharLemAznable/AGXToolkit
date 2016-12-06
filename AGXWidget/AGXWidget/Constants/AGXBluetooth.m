//
//  AGXBluetooth.m
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

#import "AGXBluetooth.h"

@implementation AGXBluetooth

+ (int8_t)dataToByte:(NSData *)data {
    char val[data.length];
    [data getBytes:&val length:data.length];
    int8_t result = val[0];
    return result;
}

+ (int16_t)dataToInt16:(NSData *)data {
    char val[data.length];
    [data getBytes:&val length:data.length];
    int16_t result = (val[0] & 0x00FF) | (val[1] << 8 & 0xFF00);
    return result;
}

+ (int32_t)dataToInt32:(NSData *)data {
    char val[data.length];
    [data getBytes:&val length:data.length];
    int32_t result = ((val[0] & 0x00FF) |
                      (val[1] << 8 & 0xFF00) |
                      (val[2] << 16 & 0xFF0000) |
                      (val[3] << 24 & 0xFF000000));
    return result;
}

@end
