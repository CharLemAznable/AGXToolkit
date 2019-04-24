//
//  AGXNetwork.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/2/29.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXNetwork_h
#define AGXNetwork_h

#import <CoreBluetooth/CoreBluetooth.h>
#import <AGXJson/AGXJson.h>

FOUNDATION_EXPORT const long AGXNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char AGXNetworkVersionString[];

#import "AGXNetwork/AGXNetworkTypes.h"

#import "AGXNetwork/AGXNetworkUtils.h"
#import "AGXNetwork/AGXNetworkDelegate.h"
#import "AGXNetwork/AGXCache.h"
#import "AGXNetwork/AGXService.h"
#import "AGXNetwork/AGXRequest.h"
#import "AGXNetwork/AGXCentralManager.h"
#import "AGXNetwork/AGXPeripheral.h"
#import "AGXNetwork/AGXBLEService.h"
#import "AGXNetwork/AGXCharacteristic.h"
#import "AGXNetwork/AGXDescriptor.h"

#import "AGXNetwork/NSHTTPURLResponse+AGXNetwork.h"
#import "AGXNetwork/NSUUID+AGXNetwork.h"

#endif /* AGXNetwork_h */
