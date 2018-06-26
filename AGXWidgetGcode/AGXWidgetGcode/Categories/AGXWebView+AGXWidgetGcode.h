//
//  AGXWebView+AGXWidgetGcode.h
//  AGXWidgetGcode
//
//  Created by Char Aznable on 2018/6/22.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidgetGcode_AGXWebView_AGXWidgetGcode_h
#define AGXWidgetGcode_AGXWebView_AGXWidgetGcode_h

#import <AGXWidget/AGXWidget.h>
#import <AGXGcode/AGXGcode.h>

@category_interface(AGXWebView, AGXWidgetGcode)
- (NSString *)recogniseGraphicCode:(NSDictionary *)params; // { "url":string, "formats":[ AGXGcodeFormat values ] }
@end

#endif /* AGXWidgetGcode_AGXWebView_AGXWidgetGcode_h */
