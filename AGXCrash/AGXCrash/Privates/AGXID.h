//
//  AGXID.h
//  AGXCrash
//
//  Created by Char Aznable on 2017/10/9.
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

#ifndef AGXCrash_AGXID_h
#define AGXCrash_AGXID_h

#ifdef __cplusplus
extern "C" {
#endif

/** Generate a new human readabale, null terminated, globally unique ID string.
 *
 * @param destinationBuffer37Bytes Buffer of at least 37 bytes to hold the ID.
 */
void agx_id_generate(char *destinationBuffer37Bytes);

#ifdef __cplusplus
}
#endif

#endif /* AGXCrash_AGXID_h */
