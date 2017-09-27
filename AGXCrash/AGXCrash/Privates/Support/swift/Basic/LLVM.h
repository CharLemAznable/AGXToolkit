//
//  LLVM.h
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

//===--- LLVM.h - Import various common LLVM datatypes ----------*- C++ -*-===//
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
// This file forward declares and imports various common LLVM datatypes that
// swift wants to use unqualified.
//
//===----------------------------------------------------------------------===//

#ifndef AGXCrash_SWIFT_BASIC_LLVM_h
#define AGXCrash_SWIFT_BASIC_LLVM_h

// Do not proliferate #includes here, require clients to #include their
// dependencies.
// Casting.h has complex templates that cannot be easily forward declared.
#include "Casting.h"
// None.h includes an enumerator that is desired & cannot be forward declared
// without a definition of NoneType.
#include "None.h"

// Forward declarations.
namespace llvm {
    // Containers.
    class StringRef;
    class Twine;
    template <typename T> class SmallPtrSetImpl;
    template <typename T, unsigned N> class SmallPtrSet;
    template <typename T> class SmallVectorImpl;
    template <typename T, unsigned N> class SmallVector;
    template <unsigned N> class SmallString;
    template<typename T> class ArrayRef;
    template<typename T> class MutableArrayRef;
    template<typename T> class TinyPtrVector;
    template<typename T> class Optional;
    template <typename PT1, typename PT2> class PointerUnion;

    // Other common classes.
    class raw_ostream;
    class APInt;
    class APFloat;
} // end namespace llvm


namespace swift {
    // Casting operators.
    using llvm::isa;
    using llvm::cast;
    using llvm::dyn_cast;
    using llvm::dyn_cast_or_null;
    using llvm::cast_or_null;

    // Containers.
    using llvm::None;
    using llvm::Optional;
    using llvm::SmallPtrSetImpl;
    using llvm::SmallPtrSet;
    using llvm::SmallString;
    using llvm::StringRef;
    using llvm::Twine;
    using llvm::SmallVectorImpl;
    using llvm::SmallVector;
    using llvm::ArrayRef;
    using llvm::MutableArrayRef;
    using llvm::TinyPtrVector;
    using llvm::PointerUnion;

    // Other common classes.
    using llvm::raw_ostream;
    using llvm::APInt;
    using llvm::APFloat;
    using llvm::NoneType;
} // end namespace swift

#endif /* AGXCrash_SWIFT_BASIC_LLVM_h */
