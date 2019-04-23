//
//  AGXWKWebViewDataBox.h
//  AGXWidget
//
//  Created by Char on 2019/4/23.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewDataBox_h
#define AGXWidget_AGXWKWebViewDataBox_h

#import <AGXData/AGXData/AGXDataBox.h>

@databox_interface(AGXWKWebViewDataBox, NSObject, shareInstance)
@databox_property(AGXWKWebViewDataBox, NSMutableDictionary *, temporary)
@databox_property(AGXWKWebViewDataBox, NSMutableDictionary *, permanent)
@databox_property(AGXWKWebViewDataBox, NSMutableDictionary *, immortal)
@end

#endif /* AGXWidget_AGXWKWebViewDataBox_h */
