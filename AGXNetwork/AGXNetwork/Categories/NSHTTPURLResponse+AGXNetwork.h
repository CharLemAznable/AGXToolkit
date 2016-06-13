//
//  NSHTTPURLResponse+AGXNetwork.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_NSHTTPURLResponse_AGXNetwork_h
#define AGXNetwork_NSHTTPURLResponse_AGXNetwork_h

#import <AGXCore/AGXCore/AGXCategory.h>

@category_interface(NSHTTPURLResponse, AGXNetwork)
@property (nonatomic, readonly) NSString *lastModified;
@property (nonatomic, readonly) NSString *eTag;
@property (nonatomic, readonly) NSString *cacheControl;
@property (nonatomic, readonly) NSInteger maxAge;
@property (nonatomic, readonly) BOOL noCache;
@property (nonatomic, readonly) NSTimeInterval expiresTimeSinceNow;
@end

#endif /* AGXNetwork_NSHTTPURLResponse_AGXNetwork_h */
