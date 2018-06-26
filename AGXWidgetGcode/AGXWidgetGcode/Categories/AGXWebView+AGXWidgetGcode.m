//
//  AGXWebView+AGXWidgetGcode.m
//  AGXWidgetGcode
//
//  Created by Char Aznable on 2018/6/22.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <AGXGcode/AGXGcode.h>
#import "AGXWebView+AGXWidgetGcode.h"

@category_implementation(AGXWebView, AGXWidgetGcode)

- (NSString *)recogniseGraphicCode:(NSDictionary *)params {
    NSString *imageURLString = [params itemForKey:@"url"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(imageURLString)) return nil;

    UIImage *image = [UIImage imageWithURLString:imageURLString];
    if AGX_EXPECT_F(!image) return nil;

    NSMutableArray *hintsFormats = NSMutableArray.instance;
    NSArray *formats = [NSArray arrayWithArray:[params itemForKey:@"formats"]];
    [formats enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         NSUInteger formatValue = [obj unsignedIntegerValue];
         if (formatValue >= kGcodeFormatUPCE &&
             formatValue <= kGcodeFormatDataMatrix) {
             [hintsFormats addObject:@(formatValue)];
         }
     }];

    return [AGXGcodeReader.instance decode:image hints:
            [AGXDecodeHints hintsWithFormats:hintsFormats] error:nil].text;
}

- (AGX_INSTANCETYPE)AGXWidgetGcode_AGXWebView_initWithFrame:(CGRect)frame {
    AGXWebView *webView = [self AGXWidgetGcode_AGXWebView_initWithFrame:frame];
    [webView registerHandlerName:@"recogniseGraphicCode" target:webView action:@selector(recogniseGraphicCode:)];
    return webView;
}

+ (void)load {
    agx_once
    ([AGXWebView swizzleInstanceOriSelector:@selector(initWithFrame:)
                            withNewSelector:@selector(AGXWidgetGcode_AGXWebView_initWithFrame:)];);
}

@end
