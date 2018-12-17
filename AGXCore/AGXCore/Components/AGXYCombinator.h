//
//  AGXYCombinator.h
//  AGXCore
//
//  Created by Char Aznable on 2016/12/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXYCombinator_h
#define AGXCore_AGXYCombinator_h

#import "AGXArc.h"

typedef id (^AGXRecursiveBlock)(id);
typedef AGXRecursiveBlock (^AGXRecursiveFunction)(id);

#define AGXYCombinator(implement_block)                             \
(AGXRecursiveBlock) ^(AGXRecursiveBlock (^f)(AGXRecursiveBlock)) {  \
    AGXRecursiveFunction r = ^(id y) {                              \
        AGXRecursiveFunction w = y;                                 \
        return f(^(id n) { return w(w)(n); });                      \
    }; return r(r);                                                 \
}(^AGXRecursiveBlock(AGXRecursiveBlock SELF) {                      \
    return AGX_BLOCK_AUTORELEASE(implement_block);                  \
})

#endif /* AGXCore_AGXYCombinator_h */
