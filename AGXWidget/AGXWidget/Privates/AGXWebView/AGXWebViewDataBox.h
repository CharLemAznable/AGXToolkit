//
//  AGXWebViewDataBox.h
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/23.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewDataBox_h
#define AGXWidget_AGXWebViewDataBox_h

#import <AGXData/AGXData/AGXDataBox.h>

@databox_interface(AGXWebViewDataBox, NSObject, shareInstance)
@databox_property(AGXWebViewDataBox, NSMutableDictionary *, temporary)
@databox_property(AGXWebViewDataBox, NSMutableDictionary *, permanent)
@databox_property(AGXWebViewDataBox, NSMutableDictionary *, immortal)
@end

#endif /* AGXWidget_AGXWebViewDataBox_h */
