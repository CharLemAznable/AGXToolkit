//
//  hmac.h
//  AGXZip
//
//  Created by Char Aznable on 2018/5/11.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  ZipArchive/ZipArchive
//  https://github.com/ZipArchive/ZipArchive
//

//  SSZipArchive MIT license
//
//  Copyright (c) 2010-2015, Sam Soffes, http://soff.es
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Zlib license
//
//  zlib.h -- interface of the 'zlib' general purpose compression library
//  version 1.2.11, January 15th, 2017
//
//  Copyright (C) 1995-2017 Jean-loup Gailly and Mark Adler
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//
//  Jean-loup Gailly        Mark Adler
//  jloup@gzip.org          madler@alumni.caltech.edu

//  minizip LICENSE
//
//  nmoinvaz/minizip
//
//  Condition of use and distribution are the same as zlib:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgement in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.

/*
---------------------------------------------------------------------------
Copyright (c) 1998-2010, Brian Gladman, Worcester, UK. All rights reserved.

The redistribution and use of this software (with or without changes)
is allowed without the payment of fees or royalties provided that:

  source code distributions include the above copyright notice, this
  list of conditions and the following disclaimer;

  binary distributions include the above copyright notice, this list
  of conditions and the following disclaimer in their documentation.

This software is provided 'as is' with no explicit or implied warranties
in respect of its operation, including, but not limited to, correctness
and fitness for purpose.
---------------------------------------------------------------------------
Issue Date: 20/12/2007

This is an implementation of HMAC, the FIPS standard keyed hash function
*/

#ifndef _AGX_HMAC2_H
#define _AGX_HMAC2_H

#include <stdlib.h>
#include <string.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#include "sha1.h"

#if defined(SHA_224) || defined(SHA_256) || defined(SHA_384) || defined(SHA_512)
#define AGX_HMAC_MAX_OUTPUT_SIZE SHA2_MAX_DIGEST_SIZE
#define AGX_HMAC_MAX_BLOCK_SIZE SHA2_MAX_BLOCK_SIZE
#else 
#define AGX_HMAC_MAX_OUTPUT_SIZE AGX_SHA1_DIGEST_SIZE
#define AGX_HMAC_MAX_BLOCK_SIZE AGX_SHA1_BLOCK_SIZE
#endif

#define AGX_HMAC_IN_DATA  0xffffffff

enum agx_hmac_hash
{ 
#ifdef AGX_SHA_1
    AGX_HMAC_SHA1,
#endif
#ifdef SHA_224 
    AGX_HMAC_SHA224,
#endif
#ifdef SHA_256
    AGX_HMAC_SHA256,
#endif
#ifdef SHA_384
    AGX_HMAC_SHA384,
#endif
#ifdef SHA_512
    AGX_HMAC_SHA512,
    AGX_HMAC_SHA512_256,
    AGX_HMAC_SHA512_224,
    AGX_HMAC_SHA512_192,
    AGX_HMAC_SHA512_128
#endif
};

typedef AGX_VOID_RETURN agx_hf_begin(void*);
typedef AGX_VOID_RETURN agx_hf_hash(const void*, unsigned long len, void*);
typedef AGX_VOID_RETURN agx_hf_end(void*, void*);

typedef struct
{   agx_hf_begin    *f_begin;
    agx_hf_hash     *f_hash;
    agx_hf_end      *f_end;
    unsigned char   key[AGX_HMAC_MAX_BLOCK_SIZE];
    union
    {
#ifdef AGX_SHA_1
       agx_sha1_ctx    u_sha1;
#endif
#ifdef SHA_224
        sha224_ctx  u_sha224;
#endif
#ifdef SHA_256
        sha256_ctx  u_sha256;
#endif
#ifdef SHA_384
        sha384_ctx  u_sha384;
#endif
#ifdef SHA_512
        sha512_ctx  u_sha512;
#endif
    } sha_ctx[1];
    unsigned long   input_len;
    unsigned long   output_len;
    unsigned long   klen;
} agx_hmac_ctx;

/* returns the length of hash digest for the hash used  */
/* mac_len must not be greater than this                */
int agx_hmac_sha_begin(enum agx_hmac_hash hash, agx_hmac_ctx cx[1]);

int agx_hmac_sha_key(const unsigned char key[], unsigned long key_len, agx_hmac_ctx cx[1]);

void agx_hmac_sha_data(const unsigned char data[], unsigned long data_len, agx_hmac_ctx cx[1]);

void agx_hmac_sha_end(unsigned char mac[], unsigned long mac_len, agx_hmac_ctx cx[1]);

void agx_hmac_sha(enum agx_hmac_hash hash, const unsigned char key[], unsigned long key_len,
          const unsigned char data[], unsigned long data_len,
          unsigned char mac[], unsigned long mac_len);

#if defined(__cplusplus)
}
#endif

#endif
