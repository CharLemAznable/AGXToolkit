//
//  Fallthrough.h
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

//===--- Fallthrough.h - switch fallthrough annotation macro ----*- C++ -*-===//
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
// This file defines a SWIFT_FALLTHROUGH macro to annotate intentional
// fallthrough between switch cases. For compilers that support the
// "clang::fallthrough" attribute, it expands to an empty statement with the
// attribute applied; otherwise, it expands to just an empty statement.
//
//===----------------------------------------------------------------------===//

#ifndef AGXCrash_SWIFT_BASIC_Fallthrough_h
#define AGXCrash_SWIFT_BASIC_Fallthrough_h

#ifndef __has_attribute
# define __has_attribute(x)     0
#endif

#ifndef __has_cpp_attribute
# define __has_cpp_attribute(x) 0
#endif

#if __has_attribute(fallthrough)
# define SWIFT_FALLTHROUGH      [[clang::fallthrough]]
#elif __has_cpp_attribute(clang::fallthrough)
# define SWIFT_FALLTHROUGH      [[clang::fallthrough]]
#else
# define SWIFT_FALLTHROUGH
#endif

#endif /* AGXCrash_SWIFT_BASIC_Fallthrough_h */
