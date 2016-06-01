//
//  NSURLRequest+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/6/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSURLRequest_AGXCore_h
#define AGXCore_NSURLRequest_AGXCore_h

#import <Foundation/Foundation.h>

@interface NSURLRequest (AGXCore)
- (BOOL)isNewRequestFromURL:(NSURL *)url;
@end

#endif /* AGXCore_NSURLRequest_AGXCore_h */
