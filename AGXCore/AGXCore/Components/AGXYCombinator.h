//
//  AGXYCombinator.h
//  AGXCore
//
//  Created by Char Aznable on 2016/12/18.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_AGXYCombinator_h
#define AGXCore_AGXYCombinator_h

#import "AGXArc.h"

#define AGXYCombinator(ARG_TYPE, RET_TYPE, REC_NAME, IMP_BLOCK)                 \
^RET_TYPE (^(RET_TYPE (^(^b)(RET_TYPE (^)(ARG_TYPE)))(ARG_TYPE)))(ARG_TYPE) {   \
    RET_TYPE (^(^r)(id))(ARG_TYPE) = ^(id p) {                                  \
        RET_TYPE (^(^w)(id))(ARG_TYPE) = p;                                     \
        return b(^RET_TYPE (ARG_TYPE param) {                                   \
            return w(w)(param);                                                 \
        });                                                                     \
    };                                                                          \
    return r(r);                                                                \
}(^RET_TYPE (^(RET_TYPE (^REC_NAME)(ARG_TYPE)))(ARG_TYPE) {                     \
    return AGX_BLOCK_AUTORELEASE(IMP_BLOCK);                                    \
})

#endif /* AGXCore_AGXYCombinator_h */
