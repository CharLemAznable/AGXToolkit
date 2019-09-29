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

#define AGXYCombinator(NAME, ARG_TYPE, RET_TYPE)            \
typedef RET_TYPE(^NAME##RecFunc)(ARG_TYPE);                 \
NAME##RecFunc NAME(NAME##RecFunc(^f)(NAME##RecFunc)) {      \
    return AGX_BLOCK_AUTORELEASE(^RET_TYPE(ARG_TYPE n) {    \
        return f(NAME(f))(n);                               \
    });                                                     \
}

#endif /* AGXCore_AGXYCombinator_h */
