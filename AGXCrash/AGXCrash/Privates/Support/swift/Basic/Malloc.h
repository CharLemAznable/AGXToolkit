//
//  Malloc.h
//  AGXCrash
//
//  Created by Char Aznable on 17/9/24.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  kstenerud/KSCrash
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

//===--- Malloc.h - Aligned malloc interface --------------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
//  This file provides an implementation of C11 aligned_alloc(3) for platforms
//  that don't have it yet, using posix_memalign(3).
//
//===----------------------------------------------------------------------===//

#ifndef AGXCrash_SWIFT_BASIC_Malloc_h
#define AGXCrash_SWIFT_BASIC_Malloc_h

#include <cassert>
#if defined(_MSC_VER)
# include <malloc.h>
#else
# include <cstdlib>
#endif

namespace swift {

    // FIXME: Use C11 aligned_alloc if available.
    inline void *AlignedAlloc(size_t size, size_t align) {
        // posix_memalign only accepts alignments greater than sizeof(void *).
        //
        if (align < sizeof(void *))
            align = sizeof(void *);

        void *r;
#if defined(_WIN32)
        r = _aligned_malloc(size, align);
        assert(r && "_aligned_malloc failed");
#else
        int res = posix_memalign(&r, align, size);
        assert(res == 0 && "posix_memalign failed");
        (void)res; // Silence the unused variable warning.
#endif
        return r;
    }

    inline void AlignedFree(void *p) {
#if defined(_WIN32)
        _aligned_free(p);
#else
        free(p);
#endif
    }
    
} // end namespace swift

#endif /* AGXCrash_SWIFT_BASIC_Malloc_h */
