//
//  AGXNetworkUtils.m
//  AGXNetwork
//
//  Created by Char Aznable on 17/4/10.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#import "AGXNetworkUtils.h"

NSString *parseIPAddressByHostName(NSString *hostNameString) {
    const char *hostNameChars = hostNameString.UTF8String;
    struct hostent *phot;
    @try { phot = gethostbyname(hostNameChars); }
    @catch (NSException *e) { return nil; }

    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));

    return [NSString stringWithUTF8String:ip];
}
