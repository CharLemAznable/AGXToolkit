//
//  AGXKeychain.h
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXData_AGXKeychain_h
#define AGXData_AGXKeychain_h

#import <Foundation/Foundation.h>

@interface AGXKeychain : NSObject
+ (NSString *)passwordForUsername:(NSString *)username andService:(NSString *)service error:(NSError **)error;
+ (BOOL)storePassword:(NSString *)password forUsername:(NSString *)username andService:(NSString *)service updateExisting:(BOOL)updateExisting error:(NSError **)error;
+ (BOOL)deletePasswordForUsername:(NSString *)username andService:(NSString *)service error:(NSError **)error;
@end

#endif /* AGXData_AGXKeychain_h */
