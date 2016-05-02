//
//  AGXRequest+Private.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXRequest_Private_h
#define AGXNetwork_AGXRequest_Private_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXNetworkTypes.h"
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
AGX_EXTERN NSString *AGXContentTypeCharsetString();
AGX_EXTERN NSString *AGXContentTypeBoundaryString();

AGX_EXTERN NSData *AGXHTTPBodyData(AGXDataEncoding dataEncoding, NSDictionary *params);

AGX_EXTERN NSString *const agxMultipartBoundary;
AGX_EXTERN NSData *AGXFormDataWithParamsAndFilesAndDatas(NSDictionary *params, NSArray *files, NSArray *datas);

#endif /* AGXNetwork_AGXRequest_Private_h */
