//
//  AGXRequest+Private.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/26.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

//
//  Modify from:
//  MugunthKumar/MKNetworkKit
//

//  MKNetworkKit is licensed under MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef AGXNetwork_AGXRequest_Private_h
#define AGXNetwork_AGXRequest_Private_h

#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXRequest.h"

@interface AGXRequest ()
@property (nonatomic, readwrite) AGXRequestState state;
@property (nonatomic, readwrite) NSHTTPURLResponse *response;
@property (nonatomic, readwrite) NSData *responseData;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) NSURLSessionTask *sessionTask;
@property (nonatomic, readwrite) double progress;

- (void)doBuild;
- (void)doCompletionHandler;
- (void)doUploadProgressHandler;
- (void)doDownloadProgressHandler;
@end

@category_interface(AGXRequest, Private)
- (void)increaseRunningOperations;
- (void)decreaseRunningOperations;
@end

AGX_EXTERN NSString *AGXContentTypeFormatString(AGXDataEncoding dataEncoding);
AGX_EXTERN NSString *AGXContentTypeCharsetString(void);
AGX_EXTERN NSString *AGXContentTypeBoundaryString(void);

AGX_EXTERN NSData *AGXHTTPBodyData(AGXDataEncoding dataEncoding, NSDictionary *params);

AGX_EXTERN NSString *const agxMultipartBoundary;
AGX_EXTERN NSData *AGXFormDataWithParamsAndFilesAndDatas(NSDictionary *params, NSArray *files, NSArray *datas);

#endif /* AGXNetwork_AGXRequest_Private_h */
