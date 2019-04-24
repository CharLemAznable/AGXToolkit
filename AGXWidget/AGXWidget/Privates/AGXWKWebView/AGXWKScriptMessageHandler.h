//
//  AGXWKScriptMessageHandler.h
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKScriptMessageHandler_h
#define AGXWidget_AGXWKScriptMessageHandler_h

#import <Foundation/Foundation.h>
#import <WebKit/WKScriptMessageHandler.h>
#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXWKScriptMessageHandler <NSObject>
- (NSString *)scriptMessageHandlerName;
@end

@interface AGXWKScriptMessageHandler : NSObject <AGXWKScriptMessageHandler, WKScriptMessageHandler>
- (id<WKScriptMessageHandler>)scriptMessageHandlerProxy;
@end

#endif /* AGXWidget_AGXWKScriptMessageHandler_h */
