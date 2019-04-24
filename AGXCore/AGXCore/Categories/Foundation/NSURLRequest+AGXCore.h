//
//  NSURLRequest+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/6/1.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSURLRequest_AGXCore_h
#define AGXCore_NSURLRequest_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSURLRequest, AGXCore)
- (BOOL)isNewRequestFromURL:(NSURL *)url;
@end

#endif /* AGXCore_NSURLRequest_AGXCore_h */
