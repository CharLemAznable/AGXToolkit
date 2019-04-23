//
//  AGXWebViewDataBox.m
//  AGXWidget
//
//  Created by Char on 2019/4/23.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXWebViewDataBox.h"

@databox_implementation(AGXWebViewDataBox, shareInstance)

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        self.temporary = NSMutableDictionary.instance;
        self.permanent = [NSMutableDictionary dictionaryWithDictionary:self.permanent];
        self.immortal = [NSMutableDictionary dictionaryWithDictionary:self.immortal];
        [self synchronize];
    }
        return self;
}

@default_share(AGXWebViewDataBox, temporary)
@restrict_share(AGXWebViewDataBox, permanent)
@keychain_share(AGXWebViewDataBox, immortal)
@end
