//
//  AGXRequest+Private.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXJson/AGXJson.h>
#import "AGXRequest+Private.h"

@category_implementation(AGXRequest, Private)

#pragma mark - running count

AGX_STATIC NSInteger numberOfRunningOperations;

- (void)increaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations++;
     UIApplication.sharedApplication.networkActivityIndicatorVisible = numberOfRunningOperations > 0;);
}

- (void)decreaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations--;
     UIApplication.sharedApplication.networkActivityIndicatorVisible = numberOfRunningOperations > 0;
     if (numberOfRunningOperations < 0) AGXLog(@"operation's count below zero. State Changes [%@]",
                                               [self valueForKey:@"stateHistory"]););
}

@end

#define UTF8EncodedData(exp)    [exp dataUsingEncoding:NSUTF8StringEncoding]

#pragma mark - HTTP Headers

NSString *AGXContentTypeFormatString(AGXDataEncoding dataEncoding) {
    switch (dataEncoding) {
        case AGXDataEncodingURL:    return @"application/x-www-form-urlencoded";
        case AGXDataEncodingJSON:   return @"application/json";
        case AGXDataEncodingPlist:  return @"application/x-plist";
    }
}

NSString *AGXContentTypeCharsetString() {
    return [NSString stringWithFormat:@"; charset=%@", (AGX_BRIDGE NSString *)
            CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))];
}

NSString *const agxMultipartBoundary = @"0xKhTmLbOuNdArY";

NSString *AGXContentTypeBoundaryString() {
    return [NSString stringWithFormat:@"; boundary=%@", agxMultipartBoundary];
}

NSData *AGXHTTPBodyData(AGXDataEncoding dataEncoding, NSDictionary *params) {
    switch (dataEncoding) {
        case AGXDataEncodingURL:    break;
        case AGXDataEncodingJSON:   return [params agxJsonData];
        case AGXDataEncodingPlist:  return [params plistData];
    }
    NSMutableDictionary *urlEncodedParams = [NSMutableDictionary dictionary];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     { urlEncodedParams[key] = [[obj description] stringEncodedForURLComponent]; }];
    return UTF8EncodedData(([urlEncodedParams stringJoinedByString:@"&" keyValueJoinedByString:@"="
                                               usingKeysComparator:NULL filterEmpty:NO]));
}

#pragma mark - multipart form

AGX_STATIC NSString *const agxSimpleFormDataFormat = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@";
AGX_STATIC NSString *const agxBinaryFormDataFormat = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n";

void AGXFormDataAppendKeyValue(NSMutableData *form, id key, id value) {
    [form appendData:UTF8EncodedData(([NSString stringWithFormat:agxSimpleFormDataFormat,
                                       agxMultipartBoundary, key, value]))];
    [form appendData:UTF8EncodedData(@"\r\n")];
}

void AGXFormDataAppendFileWithData(NSMutableData *form, NSString *name, NSString *mimetype, NSString *filename, NSData *data) {
    [form appendData:UTF8EncodedData(([NSString stringWithFormat:agxBinaryFormDataFormat,
                                       agxMultipartBoundary, name, filename, mimetype]))];
    [form appendData:data];
    [form appendData:UTF8EncodedData(@"\r\n")];
}

void AGXFormDataAppendFileWithPath(NSMutableData *form, NSString *name, NSString *mimetype, NSString *filepath) {
    AGXFormDataAppendFileWithData(form, name, mimetype, filepath.lastPathComponent, [NSData dataWithContentsOfFile:filepath]);
}

NSData *AGXFormDataWithParamsAndFilesAndDatas(NSDictionary *params, NSArray *files, NSArray *datas) {
    if AGX_EXPECT_F(files.count == 0 && datas.count == 0) return nil;
    NSMutableData *result = [NSMutableData data];

    [params enumerateKeysAndObjectsUsingBlock:
     ^(id key, id value, BOOL *stop)
     { AGXFormDataAppendKeyValue(result, key, value); }];

    [files enumerateObjectsUsingBlock:
     ^(NSDictionary *file, NSUInteger idx, BOOL *stop)
     { AGXFormDataAppendFileWithPath(result, file[@"name"], file[@"mimetype"], file[@"filepath"]); }];

    [datas enumerateObjectsUsingBlock:
     ^(NSDictionary *data, NSUInteger idx, BOOL *stop)
     { AGXFormDataAppendFileWithData(result, data[@"name"], data[@"mimetype"], data[@"filename"], data[@"data"]); }];

    [result appendData:UTF8EncodedData(([NSString stringWithFormat:@"--%@--\r\n", agxMultipartBoundary]))];
    return result;
}

#undef UTF8EncodedData
