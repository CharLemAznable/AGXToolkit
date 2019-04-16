//
//  AGXEvaluateJavascriptDelegate.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/16.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXEvaluateJavascriptDelegate_h
#define AGXWidget_AGXEvaluateJavascriptDelegate_h

#import <Foundation/Foundation.h>

@protocol AGXEvaluateJavascriptDelegate <NSObject>
- (NSString *)evaluateJavascript:(NSString *)javascript;
@end

#endif /* AGXWidget_AGXEvaluateJavascriptDelegate_h */
