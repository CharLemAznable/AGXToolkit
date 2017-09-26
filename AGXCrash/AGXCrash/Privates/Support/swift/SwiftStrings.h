//
//  SwiftStrings.h
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

//===--- Strings.h - Shared string constants across components --*- C++ -*-===//
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

#ifndef AGXCrash_SWIFT_SwiftStrings_h
#define AGXCrash_SWIFT_SwiftStrings_h

namespace swift {
    /// The extension for serialized modules.
    static const char SERIALIZED_MODULE_EXTENSION[] = "swiftmodule";
    /// The extension for serialized documentation comments.
    static const char SERIALIZED_MODULE_DOC_EXTENSION[] = "swiftdoc";
    /// The extension for SIL files.
    static const char SIL_EXTENSION[] = "sil";
    /// The extension for SIB files.
    static const char SIB_EXTENSION[] = "sib";
    /// The extension for LLVM IR files.
    static const char LLVM_BC_EXTENSION[] = "bc";
    static const char LLVM_IR_EXTENSION[] = "ll";
    /// The name of the standard library, which is a reserved module name.
    static const char STDLIB_NAME[] = "Swift";
    /// The name of the Onone support library, which is a reserved module name.
    static const char SWIFT_ONONE_SUPPORT[] = "SwiftOnoneSupport";
    /// The name of the SwiftShims module, which contains private stdlib decls.
    static const char SWIFT_SHIMS_NAME[] = "SwiftShims";
    /// The prefix of module names used by LLDB to capture Swift expressions
    static const char LLDB_EXPRESSIONS_MODULE_NAME_PREFIX[] = "__lldb_expr_";

    /// The name of the fake module used to hold imported Objective-C things.
    static const char MANGLING_MODULE_OBJC[] = "__ObjC";
    /// The name of the fake module used to hold imported C things.
    static const char MANGLING_MODULE_C[] = "__C";
} // end namespace swift

#endif /* AGXCrash_SWIFT_SwiftStrings_h */
