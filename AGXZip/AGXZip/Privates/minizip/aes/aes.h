//
//  aes.h
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
Copyright (c) 1998-2013, Brian Gladman, Worcester, UK. All rights reserved.

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

 This file contains the definitions required to use AES in C. See aesopt.h
 for optimisation details.
*/

#ifndef _AGX_AES_H
#define _AGX_AES_H

#include <stdlib.h>

/*  This include is used to find 8 & 32 bit unsigned integer types  */
#include "brg_types.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define AGX_AES_128     /* if a fast 128 bit key scheduler is needed    */
#define AGX_AES_192     /* if a fast 192 bit key scheduler is needed    */
#define AGX_AES_256     /* if a fast 256 bit key scheduler is needed    */
#define AGX_AES_VAR     /* if variable key size scheduler is needed     */
#define AGX_AES_MODES   /* if support is needed for modes               */

/* The following must also be set in assembler files if being used  */

#define AGX_AES_ENCRYPT /* if support for encryption is needed          */
#define AGX_AES_DECRYPT /* if support for decryption is needed          */

#define AGX_AES_BLOCK_SIZE  16  /* the AES block size in bytes          */
#define AGX_N_COLS           4  /* the number of columns in the state   */

/* The key schedule length is 11, 13 or 15 16-byte blocks for 128,  */
/* 192 or 256-bit keys respectively. That is 176, 208 or 240 bytes  */
/* or 44, 52 or 60 32-bit words.                                    */

#if defined( AGX_AES_VAR ) || defined( AGX_AES_256 )
#define AGX_KS_LENGTH       60
#elif defined( AGX_AES_192 )
#define AGX_KS_LENGTH       52
#else
#define AGX_KS_LENGTH       44
#endif

#define AGX_AES_RETURN AGX_INT_RETURN

/* the character array 'inf' in the following structures is used    */
/* to hold AES context information. This AES code uses cx->inf.b[0] */
/* to hold the number of rounds multiplied by 16. The other three   */
/* elements can be used by code that implements additional modes    */

typedef union
{   uint32_t l;
    uint8_t b[4];
} agx_aes_inf;

#ifdef _MSC_VER
#  pragma warning( disable : 4324 )
#endif

#if defined(_MSC_VER) && defined(_WIN64)
#define AGX_ALIGNED_(x) __declspec(align(x))
#elif defined(__GNUC__) && defined(__x86_64__)
#define AGX_ALIGNED_(x) __attribute__ ((aligned(x)))
#else
#define AGX_ALIGNED_(x)
#endif

typedef struct AGX_ALIGNED_(16)
{   uint32_t ks[AGX_KS_LENGTH];
    agx_aes_inf inf;
} agx_aes_encrypt_ctx;

typedef struct AGX_ALIGNED_(16)
{   uint32_t ks[AGX_KS_LENGTH];
    agx_aes_inf inf;
} agx_aes_decrypt_ctx;

#ifdef _MSC_VER
#  pragma warning( default : 4324 )
#endif

/* This routine must be called before first use if non-static       */
/* tables are being used                                            */

AGX_AES_RETURN agx_aes_init(void);

/* Key lengths in the range 16 <= key_len <= 32 are given in bytes, */
/* those in the range 128 <= key_len <= 256 are given in bits       */

#if defined( AGX_AES_ENCRYPT )

#if defined( AGX_AES_128 ) || defined( AGX_AES_VAR)
AGX_AES_RETURN agx_aes_encrypt_key128(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
#endif

#if defined( AGX_AES_192 ) || defined( AGX_AES_VAR)
AGX_AES_RETURN agx_aes_encrypt_key192(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
#endif

#if defined( AGX_AES_256 ) || defined( AGX_AES_VAR)
AGX_AES_RETURN agx_aes_encrypt_key256(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
#endif

#if defined( AGX_AES_VAR )
AGX_AES_RETURN agx_aes_encrypt_key(const unsigned char *key, int key_len, agx_aes_encrypt_ctx cx[1]);
#endif

AGX_AES_RETURN agx_aes_encrypt(const unsigned char *in, unsigned char *out, const agx_aes_encrypt_ctx cx[1]);

#endif

#if defined( AGX_AES_DECRYPT )

#if defined( AGX_AES_128 ) || defined( AGX_AES_VAR)
AGX_AES_RETURN agx_aes_decrypt_key128(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
#endif

#if defined( AGX_AES_192 ) || defined( AGX_AES_VAR)
AGX_AES_RETURN agx_aes_decrypt_key192(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
#endif

#if defined( AGX_AES_256 ) || defined( AGX_AES_VAR)
AGX_AES_RETURN agx_aes_decrypt_key256(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
#endif

#if defined( AGX_AES_VAR )
AGX_AES_RETURN agx_aes_decrypt_key(const unsigned char *key, int key_len, agx_aes_decrypt_ctx cx[1]);
#endif

AGX_AES_RETURN agx_aes_decrypt(const unsigned char *in, unsigned char *out, const agx_aes_decrypt_ctx cx[1]);

#endif

#if defined( AGX_AES_MODES )

/* Multiple calls to the following subroutines for multiple block   */
/* ECB, CBC, CFB, OFB and CTR mode encryption can be used to handle */
/* long messages incrementally provided that the context AND the iv */
/* are preserved between all such calls.  For the ECB and CBC modes */
/* each individual call within a series of incremental calls must   */
/* process only full blocks (i.e. len must be a multiple of 16) but */
/* the CFB, OFB and CTR mode calls can handle multiple incremental  */
/* calls of any length.  Each mode is reset when a new AES key is   */
/* set but ECB needs no reset and CBC can be reset without setting  */
/* a new key by setting a new IV value.  To reset CFB, OFB and CTR  */
/* without setting the key, aes_mode_reset() must be called and the */
/* IV must be set.  NOTE: All these calls update the IV on exit so  */
/* this has to be reset if a new operation with the same IV as the  */
/* previous one is required (or decryption follows encryption with  */
/* the same IV array).                                              */

AGX_AES_RETURN agx_aes_test_alignment_detection(unsigned int n);

AGX_AES_RETURN agx_aes_ecb_encrypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, const agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_ecb_decrypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, const agx_aes_decrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_cbc_encrypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, unsigned char *iv, const agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_cbc_decrypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, unsigned char *iv, const agx_aes_decrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_mode_reset(agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_cfb_encrypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, unsigned char *iv, agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_cfb_decrypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, unsigned char *iv, agx_aes_encrypt_ctx cx[1]);

#define agx_aes_ofb_encrypt agx_aes_ofb_crypt
#define agx_aes_ofb_decrypt agx_aes_ofb_crypt

AGX_AES_RETURN agx_aes_ofb_crypt(const unsigned char *ibuf, unsigned char *obuf,
                    int len, unsigned char *iv, agx_aes_encrypt_ctx cx[1]);

typedef void agx_cbuf_inc(unsigned char *cbuf);

#define agx_aes_ctr_encrypt agx_aes_ctr_crypt
#define agx_aes_ctr_decrypt agx_aes_ctr_crypt

AGX_AES_RETURN agx_aes_ctr_crypt(const unsigned char *ibuf, unsigned char *obuf,
            int len, unsigned char *cbuf, agx_cbuf_inc ctr_inc, agx_aes_encrypt_ctx cx[1]);

#endif

#if 0
#  define AGX_ADD_AESNI_MODE_CALLS
#endif

#if 0 && defined( AGX_ADD_AESNI_MODE_CALLS )
#  define AGX_USE_AES_CONTEXT
#endif

#ifdef AGX_ADD_AESNI_MODE_CALLS
#  ifdef AGX_USE_AES_CONTEXT

AGX_AES_RETURN agx_aes_CBC_encrypt(const unsigned char *in,
    unsigned char *out,
    unsigned char ivec[16],
    unsigned long length,
    const agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_CBC_decrypt(const unsigned char *in,
    unsigned char *out,
    unsigned char ivec[16],
    unsigned long length,
    const agx_aes_decrypt_ctx cx[1]);

AGX_AES_RETURN agx_AES_CTR_encrypt(const unsigned char *in,
    unsigned char *out,
    const unsigned char ivec[8],
    const unsigned char nonce[4],
    unsigned long length,
    const agx_aes_encrypt_ctx cx[1]);

#  else

void agx_aes_CBC_encrypt(const unsigned char *in,
    unsigned char *out,
    unsigned char ivec[16],
    unsigned long length,
    unsigned char *key,
    int number_of_rounds);

void agx_aes_CBC_decrypt(const unsigned char *in,
    unsigned char *out,
    unsigned char ivec[16],
    unsigned long length,
    unsigned char *key,
    int number_of_rounds);

void agx_AES_CTR_encrypt(const unsigned char *in,
    unsigned char *out,
    const unsigned char ivec[8],
    const unsigned char nonce[4],
    unsigned long length,
    const unsigned char *key,
    int number_of_rounds);

#  endif
#endif

#if defined(__cplusplus)
}
#endif

#endif
