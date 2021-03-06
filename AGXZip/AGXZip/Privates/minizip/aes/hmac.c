//
//  hmac.c
//  AGXZip
//
//  Created by Char Aznable on 2018/5/11.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
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

#include "hmac.h"

#if defined(__cplusplus)
extern "C"
{
#endif

/* initialise the HMAC context to zero */
int agx_hmac_sha_begin(enum agx_hmac_hash hash, agx_hmac_ctx cx[1])
{
    memset(cx, 0, sizeof(agx_hmac_ctx));
    switch(hash)
    {
#ifdef AGX_SHA_1
    case AGX_HMAC_SHA1:
        cx->f_begin = (agx_hf_begin *)agx_sha1_begin;
        cx->f_hash  = (agx_hf_hash *)agx_sha1_hash;
        cx->f_end   = (agx_hf_end *)agx_sha1_end;
        cx->input_len = AGX_SHA1_BLOCK_SIZE;
        cx->output_len = AGX_SHA1_DIGEST_SIZE;
        break;
#endif
#ifdef SHA_224
    case AGX_HMAC_SHA224:
        cx->f_begin = (agx_hf_begin *)sha224_begin;
        cx->f_hash  = (agx_hf_hash *)sha224_hash;
        cx->f_end   = (agx_hf_end *)sha224_end;
        cx->input_len = SHA224_BLOCK_SIZE;
        cx->output_len = SHA224_DIGEST_SIZE;
        break;
#endif
#ifdef SHA_256
    case AGX_HMAC_SHA256:
        cx->f_begin = (agx_hf_begin *)sha256_begin;
        cx->f_hash  = (agx_hf_hash *)sha256_hash;
        cx->f_end   = (agx_hf_end *)sha256_end;
        cx->input_len = SHA256_BLOCK_SIZE;
        cx->output_len = SHA256_DIGEST_SIZE;
        break;
#endif
#ifdef SHA_384
    case AGX_HMAC_SHA384:
        cx->f_begin = (agx_hf_begin *)sha384_begin;
        cx->f_hash  = (agx_hf_hash *)sha384_hash;
        cx->f_end   = (agx_hf_end *)sha384_end;
        cx->input_len = SHA384_BLOCK_SIZE;
        cx->output_len = SHA384_DIGEST_SIZE;
        break;
#endif
#ifdef SHA_512
    case AGX_HMAC_SHA512:
        cx->f_begin = (agx_hf_begin *)sha512_begin;
        cx->f_hash  = (agx_hf_hash *)sha512_hash;
        cx->f_end   = (agx_hf_end *)sha512_end;
        cx->input_len = SHA512_BLOCK_SIZE;
        cx->output_len = SHA512_DIGEST_SIZE;
        break;
    case AGX_HMAC_SHA512_256:
        cx->f_begin = (agx_hf_begin *)sha512_256_begin;
        cx->f_hash  = (agx_hf_hash *)sha512_256_hash;
        cx->f_end   = (agx_hf_end *)sha512_256_end;
        cx->input_len = SHA512_256_BLOCK_SIZE;
        cx->output_len = SHA512_256_DIGEST_SIZE;
        break;
    case AGX_HMAC_SHA512_224:
        cx->f_begin = (agx_hf_begin *)sha512_224_begin;
        cx->f_hash  = (agx_hf_hash *)sha512_224_hash;
        cx->f_end   = (agx_hf_end *)sha512_224_end;
        cx->input_len = SHA512_224_BLOCK_SIZE;
        cx->output_len = SHA512_224_DIGEST_SIZE;
        break;
    case AGX_HMAC_SHA512_192:
        cx->f_begin = (agx_hf_begin *)sha512_192_begin;
        cx->f_hash  = (agx_hf_hash *)sha512_192_hash;
        cx->f_end   = (agx_hf_end *)sha512_192_end;
        cx->input_len = SHA512_192_BLOCK_SIZE;
        cx->output_len = SHA512_192_DIGEST_SIZE;
        break;
    case AGX_HMAC_SHA512_128:
        cx->f_begin = (agx_hf_begin *)sha512_128_begin;
        cx->f_hash  = (agx_hf_hash *)sha512_128_hash;
        cx->f_end   = (agx_hf_begin *)sha512_128_end;
        cx->input_len = SHA512_128_BLOCK_SIZE;
        cx->output_len = SHA512_128_DIGEST_SIZE;
        break;
#endif
    }
    return (int)cx->output_len;
}

/* input the HMAC key (can be called multiple times)    */
int agx_hmac_sha_key(const unsigned char key[], unsigned long key_len, agx_hmac_ctx cx[1])
{
    if(cx->klen == AGX_HMAC_IN_DATA)            /* error if further key input   */
        return EXIT_FAILURE;                    /* is attempted in data mode    */

    if(cx->klen + key_len > cx->input_len)      /* if the key has to be hashed  */
    {
        if(cx->klen <= cx->input_len)           /* if the hash has not yet been */
        {                                       /* started, initialise it and   */
            cx->f_begin(cx->sha_ctx);           /* hash stored key characters   */
            cx->f_hash(cx->key, cx->klen, cx->sha_ctx);
        }

        cx->f_hash(key, key_len, cx->sha_ctx);  /* hash long key data into hash */
    }
    else                                        /* otherwise store key data     */
        memcpy(cx->key + cx->klen, key, key_len);

    cx->klen += key_len;                        /* update the key length count  */
    return EXIT_SUCCESS;
}

/* input the HMAC data (can be called multiple times) - */
/* note that this call terminates the key input phase   */
void agx_hmac_sha_data(const unsigned char data[], unsigned long data_len, agx_hmac_ctx cx[1])
{   unsigned int i;

    if(cx->klen != AGX_HMAC_IN_DATA)                /* if not yet in data phase */
    {
        if(cx->klen > cx->input_len)            /* if key is being hashed   */
        {                                       /* complete the hash and    */
            cx->f_end(cx->key, cx->sha_ctx);    /* store the result as the  */
            cx->klen = cx->output_len;          /* key and set new length   */
        }

        /* pad the key if necessary */
        memset(cx->key + cx->klen, 0, cx->input_len - cx->klen);

        /* xor ipad into key value  */
        for(i = 0; i < (cx->input_len >> 2); ++i)
            ((uint32_t*)cx->key)[i] ^= 0x36363636;

        /* and start hash operation */
        cx->f_begin(cx->sha_ctx);
        cx->f_hash(cx->key, cx->input_len, cx->sha_ctx);

        /* mark as now in data mode */
        cx->klen = AGX_HMAC_IN_DATA;
    }

    /* hash the data (if any)       */
    if(data_len)
        cx->f_hash(data, data_len, cx->sha_ctx);
}

/* compute and output the MAC value */
void agx_hmac_sha_end(unsigned char mac[], unsigned long mac_len, agx_hmac_ctx cx[1])
{   unsigned char dig[AGX_HMAC_MAX_OUTPUT_SIZE];
    unsigned int i;

    /* if no data has been entered perform a null data phase        */
    if(cx->klen != AGX_HMAC_IN_DATA)
        agx_hmac_sha_data((const unsigned char*)0, 0, cx);

    cx->f_end(dig, cx->sha_ctx);        /* complete the inner hash       */

    /* set outer key value using opad and removing ipad */
    for(i = 0; i < (cx->input_len >> 2); ++i)
        ((uint32_t*)cx->key)[i] ^= 0x36363636 ^ 0x5c5c5c5c;

    /* perform the outer hash operation */
    cx->f_begin(cx->sha_ctx);
    cx->f_hash(cx->key, cx->input_len, cx->sha_ctx);
    cx->f_hash(dig, cx->output_len, cx->sha_ctx);
    cx->f_end(dig, cx->sha_ctx);

    /* output the hash value            */
    for(i = 0; i < mac_len; ++i)
        mac[i] = dig[i];
}

/* 'do it all in one go' subroutine     */
void agx_hmac_sha(enum agx_hmac_hash hash, const unsigned char key[], unsigned long key_len,
          const unsigned char data[], unsigned long data_len,
          unsigned char mac[], unsigned long mac_len)
{   agx_hmac_ctx    cx[1];

    agx_hmac_sha_begin(hash, cx);
    agx_hmac_sha_key(key, key_len, cx);
    agx_hmac_sha_data(data, data_len, cx);
    agx_hmac_sha_end(mac, mac_len, cx);
}

#if defined(__cplusplus)
}
#endif
