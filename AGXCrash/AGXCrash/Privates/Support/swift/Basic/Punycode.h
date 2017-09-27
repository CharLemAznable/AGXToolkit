//
//  Punycode.h
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

//===--- Punycode.h - UTF-8 to Punycode transcoding -------------*- C++ -*-===//
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
// These functions implement a variant of the Punycode algorithm from RFC3492,
// originally designed for encoding international domain names, for the purpose
// of encoding Swift identifiers into mangled symbol names. This version differs
// from RFC3492 in the following respects:
// - '_' is used as the encoding delimiter instead of '-'.
// - Encoding digits are represented using [a-zA-J] instead of [a-z0-9], because
//   symbol names are case-sensitive, and Swift mangled identifiers cannot begin
//   with a digit.
//
//===----------------------------------------------------------------------===//

#ifndef AGXCrash_SWIFT_BASIC_Punycode_h
#define AGXCrash_SWIFT_BASIC_Punycode_h

#include <vector>
#include <cstdint>
#include "LLVM.h"
#include "StringRef.h"

namespace swift {
    namespace Punycode {

        /// Encodes a sequence of code points into Punycode.
        ///
        /// Returns false if input contains surrogate code points.
        bool encodePunycode(const std::vector<uint32_t> &InputCodePoints,
                            std::string &OutPunycode);

        /// Decodes a Punycode string into a sequence of Unicode scalars.
        ///
        /// Returns false if decoding failed.
        bool decodePunycode(StringRef InputPunycode,
                            std::vector<uint32_t> &OutCodePoints);

        bool encodePunycodeUTF8(StringRef InputUTF8, std::string &OutPunycode);

        bool decodePunycodeUTF8(StringRef InputPunycode, std::string &OutUTF8);
        
    } // end namespace Punycode
} // end namespace swift

#endif /* AGXCrash_SWIFT_BASIC_Punycode_h */
