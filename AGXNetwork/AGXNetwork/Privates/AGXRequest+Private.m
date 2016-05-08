//
//  AGXRequest+Private.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/AGXPlist.h>
#import <AGXJson/AGXJson.h>
#import "AGXRequest+Private.h"

@category_implementation(AGXRequest, Private)

#pragma mark - running count

static NSInteger numberOfRunningOperations;

- (void)increaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations++;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = numberOfRunningOperations > 0;)
}

- (void)decreaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations--;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = numberOfRunningOperations > 0;
     if (numberOfRunningOperations < 0) AGXLog(@"operation's count below zero. State Changes [%@]",
                                               [self valueForKey:@"stateHistory"]);)
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
        case AGXDataEncodingJSON:   return [AGXJson jsonDataFromObject:params];
        case AGXDataEncodingPlist:  return [AGXPlist plistDataFromObject:params];
    }
    NSMutableDictionary *urlEncodedParams = [NSMutableDictionary dictionary];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     { urlEncodedParams[key] = [obj stringByEscapingForURLQuery]; }];
    return UTF8EncodedData(([NSString stringWithDictionary:urlEncodedParams
                                       usingKeysComparator:NULL separator:@"&"
                                         keyValueSeparator:@"=" filterEmpty:YES]));
}

#pragma mark - multipart form

static NSString *const agxSimpleFormDataFormat = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@";
static NSString *const agxBinaryFormDataFormat = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n";

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
    AGXFormDataAppendFileWithData(form, name, mimetype, [filepath lastPathComponent], [NSData dataWithContentsOfFile:filepath]);
}

NSData *AGXFormDataWithParamsAndFilesAndDatas(NSDictionary *params, NSArray *files, NSArray *datas) {
    if (files.count == 0 && datas.count == 0) return nil;
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
