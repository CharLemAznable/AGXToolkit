//
//  aeskey.c
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
*/

#include "aesopt.h"
#include "aestab.h"

#if defined( AGX_USE_INTEL_AES_IF_PRESENT )
#  include "aes_ni.h"
#else
/* map names here to provide the external API ('name' -> 'agx_aes_name') */
#  define agx_aes_xi(x) agx_aes_ ## x
#endif

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
#  include "aes_via_ace.h"
#endif

#if defined(__cplusplus)
extern "C"
{
#endif

/* Initialise the key schedule from the user supplied key. The key
   length can be specified in bytes, with legal values of 16, 24
   and 32, or in bits, with legal values of 128, 192 and 256. These
   values correspond with Nk values of 4, 6 and 8 respectively.

   The following macros implement a single cycle in the key
   schedule generation process. The number of cycles needed
   for each cx->n_col and nk value is:

    nk =             4  5  6  7  8
    ------------------------------
    cx->n_col = 4   10  9  8  7  7
    cx->n_col = 5   14 11 10  9  9
    cx->n_col = 6   19 15 12 11 11
    cx->n_col = 7   21 19 16 13 14
    cx->n_col = 8   29 23 19 17 14
*/

#if defined( AGX_REDUCE_CODE_SIZE )
#  define agx_ls_box ls_sub
   uint32_t ls_sub(const uint32_t t, const uint32_t n);
#  define agx_inv_mcol im_sub
   uint32_t im_sub(const uint32_t x);
#  ifdef AGX_ENC_KS_UNROLL
#    undef AGX_ENC_KS_UNROLL
#  endif
#  ifdef AGX_DEC_KS_UNROLL
#    undef AGX_DEC_KS_UNROLL
#  endif
#endif

#if (AGX_FUNCS_IN_C & AGX_ENC_KEYING_IN_C)

#if defined(AGX_AES_128) || defined( AGX_AES_VAR )

#define agx_ke4(k,i) \
{   k[4*(i)+4] = ss[0] ^= agx_ls_box(ss[3],3) ^ agx_t_use(r,c)[i]; \
    k[4*(i)+5] = ss[1] ^= ss[0]; \
    k[4*(i)+6] = ss[2] ^= ss[1]; \
    k[4*(i)+7] = ss[3] ^= ss[2]; \
}

AGX_AES_RETURN agx_aes_xi(encrypt_key128)(const unsigned char *key, agx_aes_encrypt_ctx cx[1])
{   uint32_t    ss[4];

    cx->ks[0] = ss[0] = agx_word_in(key, 0);
    cx->ks[1] = ss[1] = agx_word_in(key, 1);
    cx->ks[2] = ss[2] = agx_word_in(key, 2);
    cx->ks[3] = ss[3] = agx_word_in(key, 3);

#ifdef AGX_ENC_KS_UNROLL
    agx_ke4(cx->ks, 0);  agx_ke4(cx->ks, 1);
    agx_ke4(cx->ks, 2);  agx_ke4(cx->ks, 3);
    agx_ke4(cx->ks, 4);  agx_ke4(cx->ks, 5);
    agx_ke4(cx->ks, 6);  agx_ke4(cx->ks, 7);
    agx_ke4(cx->ks, 8);
#else
    {   uint32_t i;
        for(i = 0; i < 9; ++i)
            agx_ke4(cx->ks, i);
    }
#endif
    agx_ke4(cx->ks, 9);
    cx->inf.l = 0;
    cx->inf.b[0] = 10 * 16;

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
    if(VIA_ACE_AVAILABLE)
        cx->inf.b[1] = 0xff;
#endif
    return EXIT_SUCCESS;
}

#endif

#if defined(AGX_AES_192) || defined( AGX_AES_VAR )

#define agx_kef6(k,i) \
{   k[6*(i)+ 6] = ss[0] ^= agx_ls_box(ss[5],3) ^ agx_t_use(r,c)[i]; \
    k[6*(i)+ 7] = ss[1] ^= ss[0]; \
    k[6*(i)+ 8] = ss[2] ^= ss[1]; \
    k[6*(i)+ 9] = ss[3] ^= ss[2]; \
}

#define agx_ke6(k,i) \
{   agx_kef6(k,i); \
    k[6*(i)+10] = ss[4] ^= ss[3]; \
    k[6*(i)+11] = ss[5] ^= ss[4]; \
}

AGX_AES_RETURN agx_aes_xi(encrypt_key192)(const unsigned char *key, agx_aes_encrypt_ctx cx[1])
{   uint32_t    ss[6];

	cx->ks[0] = ss[0] = agx_word_in(key, 0);
    cx->ks[1] = ss[1] = agx_word_in(key, 1);
    cx->ks[2] = ss[2] = agx_word_in(key, 2);
    cx->ks[3] = ss[3] = agx_word_in(key, 3);
    cx->ks[4] = ss[4] = agx_word_in(key, 4);
    cx->ks[5] = ss[5] = agx_word_in(key, 5);

#ifdef AGX_ENC_KS_UNROLL
    agx_ke6(cx->ks, 0);  agx_ke6(cx->ks, 1);
    agx_ke6(cx->ks, 2);  agx_ke6(cx->ks, 3);
    agx_ke6(cx->ks, 4);  agx_ke6(cx->ks, 5);
    agx_ke6(cx->ks, 6);
#else
    {   uint32_t i;
        for(i = 0; i < 7; ++i)
            agx_ke6(cx->ks, i);
    }
#endif
    agx_kef6(cx->ks, 7);
    cx->inf.l = 0;
    cx->inf.b[0] = 12 * 16;

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
    if(VIA_ACE_AVAILABLE)
        cx->inf.b[1] = 0xff;
#endif
    return EXIT_SUCCESS;
}

#endif

#if defined(AGX_AES_256) || defined( AGX_AES_VAR )

#define agx_kef8(k,i) \
{   k[8*(i)+ 8] = ss[0] ^= agx_ls_box(ss[7],3) ^ agx_t_use(r,c)[i]; \
    k[8*(i)+ 9] = ss[1] ^= ss[0]; \
    k[8*(i)+10] = ss[2] ^= ss[1]; \
    k[8*(i)+11] = ss[3] ^= ss[2]; \
}

#define agx_ke8(k,i) \
{   agx_kef8(k,i); \
    k[8*(i)+12] = ss[4] ^= agx_ls_box(ss[3],0); \
    k[8*(i)+13] = ss[5] ^= ss[4]; \
    k[8*(i)+14] = ss[6] ^= ss[5]; \
    k[8*(i)+15] = ss[7] ^= ss[6]; \
}

AGX_AES_RETURN agx_aes_xi(encrypt_key256)(const unsigned char *key, agx_aes_encrypt_ctx cx[1])
{   uint32_t    ss[8];

    cx->ks[0] = ss[0] = agx_word_in(key, 0);
    cx->ks[1] = ss[1] = agx_word_in(key, 1);
    cx->ks[2] = ss[2] = agx_word_in(key, 2);
    cx->ks[3] = ss[3] = agx_word_in(key, 3);
    cx->ks[4] = ss[4] = agx_word_in(key, 4);
    cx->ks[5] = ss[5] = agx_word_in(key, 5);
    cx->ks[6] = ss[6] = agx_word_in(key, 6);
    cx->ks[7] = ss[7] = agx_word_in(key, 7);

#ifdef AGX_ENC_KS_UNROLL
    agx_ke8(cx->ks, 0); agx_ke8(cx->ks, 1);
    agx_ke8(cx->ks, 2); agx_ke8(cx->ks, 3);
    agx_ke8(cx->ks, 4); agx_ke8(cx->ks, 5);
#else
    {   uint32_t i;
        for(i = 0; i < 6; ++i)
            agx_ke8(cx->ks,  i);
    }
#endif
    agx_kef8(cx->ks, 6);
    cx->inf.l = 0;
    cx->inf.b[0] = 14 * 16;

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
    if(VIA_ACE_AVAILABLE)
        cx->inf.b[1] = 0xff;
#endif
    return EXIT_SUCCESS;
}

#endif

#endif

#if (AGX_FUNCS_IN_C & AGX_DEC_KEYING_IN_C)

/* this is used to store the decryption round keys  */
/* in forward or reverse order                      */

#ifdef AGX_AES_REV_DKS
#define agx_v(n,i)  ((n) - (i) + 2 * ((i) & 3))
#else
#define agx_v(n,i)  (i)
#endif

#if AGX_DEC_ROUND == AGX_NO_TABLES
#define agx_ff(x)   (x)
#else
#define agx_ff(x)   agx_inv_mcol(x)
#if defined( agx_dec_imvars )
#define agx_d_vars  agx_dec_imvars
#endif
#endif

#if defined(AGX_AES_128) || defined( AGX_AES_VAR )

#define agx_k4e(k,i) \
{   k[v(40,(4*(i))+4)] = ss[0] ^= agx_ls_box(ss[3],3) ^ agx_t_use(r,c)[i]; \
    k[v(40,(4*(i))+5)] = ss[1] ^= ss[0]; \
    k[v(40,(4*(i))+6)] = ss[2] ^= ss[1]; \
    k[v(40,(4*(i))+7)] = ss[3] ^= ss[2]; \
}

#if 1

#define agx_kdf4(k,i) \
{   ss[0] = ss[0] ^ ss[2] ^ ss[1] ^ ss[3]; \
    ss[1] = ss[1] ^ ss[3]; \
    ss[2] = ss[2] ^ ss[3]; \
    ss[4] = agx_ls_box(ss[(i+3) % 4], 3) ^ agx_t_use(r,c)[i]; \
    ss[i % 4] ^= ss[4]; \
    ss[4] ^= k[agx_v(40,(4*(i)))];   k[agx_v(40,(4*(i))+4)] = agx_ff(ss[4]); \
    ss[4] ^= k[agx_v(40,(4*(i))+1)]; k[agx_v(40,(4*(i))+5)] = agx_ff(ss[4]); \
    ss[4] ^= k[agx_v(40,(4*(i))+2)]; k[agx_v(40,(4*(i))+6)] = agx_ff(ss[4]); \
    ss[4] ^= k[agx_v(40,(4*(i))+3)]; k[agx_v(40,(4*(i))+7)] = agx_ff(ss[4]); \
}

#define agx_kd4(k,i) \
{   ss[4] = agx_ls_box(ss[(i+3) % 4], 3) ^ agx_t_use(r,c)[i]; \
    ss[i % 4] ^= ss[4]; ss[4] = agx_ff(ss[4]); \
    k[agx_v(40,(4*(i))+4)] = ss[4] ^= k[agx_v(40,(4*(i)))]; \
    k[agx_v(40,(4*(i))+5)] = ss[4] ^= k[agx_v(40,(4*(i))+1)]; \
    k[agx_v(40,(4*(i))+6)] = ss[4] ^= k[agx_v(40,(4*(i))+2)]; \
    k[agx_v(40,(4*(i))+7)] = ss[4] ^= k[agx_v(40,(4*(i))+3)]; \
}

#define agx_kdl4(k,i) \
{   ss[4] = agx_ls_box(ss[(i+3) % 4], 3) ^ agx_t_use(r,c)[i]; ss[i % 4] ^= ss[4]; \
    k[agx_v(40,(4*(i))+4)] = (ss[0] ^= ss[1]) ^ ss[2] ^ ss[3]; \
    k[agx_v(40,(4*(i))+5)] = ss[1] ^ ss[3]; \
    k[agx_v(40,(4*(i))+6)] = ss[0]; \
    k[agx_v(40,(4*(i))+7)] = ss[1]; \
}

#else

#define agx_kdf4(k,i) \
{   ss[0] ^= agx_ls_box(ss[3],3) ^ agx_t_use(r,c)[i]; k[agx_v(40,(4*(i))+ 4)] = agx_ff(ss[0]); \
    ss[1] ^= ss[0]; k[agx_v(40,(4*(i))+ 5)] = agx_ff(ss[1]); \
    ss[2] ^= ss[1]; k[agx_v(40,(4*(i))+ 6)] = agx_ff(ss[2]); \
    ss[3] ^= ss[2]; k[agx_v(40,(4*(i))+ 7)] = agx_ff(ss[3]); \
}

#define agx_kd4(k,i) \
{   ss[4] = agx_ls_box(ss[3],3) ^ agx_t_use(r,c)[i]; \
    ss[0] ^= ss[4]; ss[4] = agx_ff(ss[4]); k[v(40,(4*(i))+ 4)] = ss[4] ^= k[agx_v(40,(4*(i)))]; \
    ss[1] ^= ss[0]; k[agx_v(40,(4*(i))+ 5)] = ss[4] ^= k[agx_v(40,(4*(i))+ 1)]; \
    ss[2] ^= ss[1]; k[agx_v(40,(4*(i))+ 6)] = ss[4] ^= k[agx_v(40,(4*(i))+ 2)]; \
    ss[3] ^= ss[2]; k[agx_v(40,(4*(i))+ 7)] = ss[4] ^= k[agx_v(40,(4*(i))+ 3)]; \
}

#define agx_kdl4(k,i) \
{   ss[0] ^= agx_ls_box(ss[3],3) ^ agx_t_use(r,c)[i]; k[agx_v(40,(4*(i))+ 4)] = ss[0]; \
    ss[1] ^= ss[0]; k[agx_v(40,(4*(i))+ 5)] = ss[1]; \
    ss[2] ^= ss[1]; k[agx_v(40,(4*(i))+ 6)] = ss[2]; \
    ss[3] ^= ss[2]; k[agx_v(40,(4*(i))+ 7)] = ss[3]; \
}

#endif

AGX_AES_RETURN agx_aes_xi(decrypt_key128)(const unsigned char *key, agx_aes_decrypt_ctx cx[1])
{   uint32_t    ss[5];
#if defined( agx_d_vars )
        agx_d_vars;
#endif

	cx->ks[agx_v(40,(0))] = ss[0] = agx_word_in(key, 0);
    cx->ks[agx_v(40,(1))] = ss[1] = agx_word_in(key, 1);
    cx->ks[agx_v(40,(2))] = ss[2] = agx_word_in(key, 2);
    cx->ks[agx_v(40,(3))] = ss[3] = agx_word_in(key, 3);

#ifdef AGX_DEC_KS_UNROLL
     agx_kdf4(cx->ks, 0); agx_kd4(cx->ks, 1);
     agx_kd4(cx->ks, 2);  agx_kd4(cx->ks, 3);
     agx_kd4(cx->ks, 4);  agx_kd4(cx->ks, 5);
     agx_kd4(cx->ks, 6);  agx_kd4(cx->ks, 7);
     agx_kd4(cx->ks, 8);  agx_kdl4(cx->ks, 9);
#else
    {   uint32_t i;
        for(i = 0; i < 10; ++i)
            agx_k4e(cx->ks, i);
#if !(AGX_DEC_ROUND == AGX_NO_TABLES)
        for(i = AGX_N_COLS; i < 10 * AGX_N_COLS; ++i)
            cx->ks[i] = agx_inv_mcol(cx->ks[i]);
#endif
    }
#endif
    cx->inf.l = 0;
    cx->inf.b[0] = 10 * 16;

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
    if(VIA_ACE_AVAILABLE)
        cx->inf.b[1] = 0xff;
#endif
    return EXIT_SUCCESS;
}

#endif

#if defined(AGX_AES_192) || defined( AGX_AES_VAR )

#define agx_k6ef(k,i) \
{   k[v(48,(6*(i))+ 6)] = ss[0] ^= agx_ls_box(ss[5],3) ^ agx_t_use(r,c)[i]; \
    k[v(48,(6*(i))+ 7)] = ss[1] ^= ss[0]; \
    k[v(48,(6*(i))+ 8)] = ss[2] ^= ss[1]; \
    k[v(48,(6*(i))+ 9)] = ss[3] ^= ss[2]; \
}

#define agx_k6e(k,i) \
{   agx_k6ef(k,i); \
    k[v(48,(6*(i))+10)] = ss[4] ^= ss[3]; \
    k[v(48,(6*(i))+11)] = ss[5] ^= ss[4]; \
}

#define agx_kdf6(k,i) \
{   ss[0] ^= agx_ls_box(ss[5],3) ^ agx_t_use(r,c)[i]; k[agx_v(48,(6*(i))+ 6)] = agx_ff(ss[0]); \
    ss[1] ^= ss[0]; k[agx_v(48,(6*(i))+ 7)] = agx_ff(ss[1]); \
    ss[2] ^= ss[1]; k[agx_v(48,(6*(i))+ 8)] = agx_ff(ss[2]); \
    ss[3] ^= ss[2]; k[agx_v(48,(6*(i))+ 9)] = agx_ff(ss[3]); \
    ss[4] ^= ss[3]; k[agx_v(48,(6*(i))+10)] = agx_ff(ss[4]); \
    ss[5] ^= ss[4]; k[agx_v(48,(6*(i))+11)] = agx_ff(ss[5]); \
}

#define agx_kd6(k,i) \
{   ss[6] = agx_ls_box(ss[5],3) ^ agx_t_use(r,c)[i]; \
    ss[0] ^= ss[6]; ss[6] = agx_ff(ss[6]); k[agx_v(48,(6*(i))+ 6)] = ss[6] ^= k[agx_v(48,(6*(i)))]; \
    ss[1] ^= ss[0]; k[agx_v(48,(6*(i))+ 7)] = ss[6] ^= k[agx_v(48,(6*(i))+ 1)]; \
    ss[2] ^= ss[1]; k[agx_v(48,(6*(i))+ 8)] = ss[6] ^= k[agx_v(48,(6*(i))+ 2)]; \
    ss[3] ^= ss[2]; k[agx_v(48,(6*(i))+ 9)] = ss[6] ^= k[agx_v(48,(6*(i))+ 3)]; \
    ss[4] ^= ss[3]; k[agx_v(48,(6*(i))+10)] = ss[6] ^= k[agx_v(48,(6*(i))+ 4)]; \
    ss[5] ^= ss[4]; k[agx_v(48,(6*(i))+11)] = ss[6] ^= k[agx_v(48,(6*(i))+ 5)]; \
}

#define agx_kdl6(k,i) \
{   ss[0] ^= agx_ls_box(ss[5],3) ^ agx_t_use(r,c)[i]; k[agx_v(48,(6*(i))+ 6)] = ss[0]; \
    ss[1] ^= ss[0]; k[agx_v(48,(6*(i))+ 7)] = ss[1]; \
    ss[2] ^= ss[1]; k[agx_v(48,(6*(i))+ 8)] = ss[2]; \
    ss[3] ^= ss[2]; k[agx_v(48,(6*(i))+ 9)] = ss[3]; \
}

AGX_AES_RETURN agx_aes_xi(decrypt_key192)(const unsigned char *key, agx_aes_decrypt_ctx cx[1])
{   uint32_t    ss[7];
#if defined( agx_d_vars )
        agx_d_vars;
#endif

    cx->ks[agx_v(48,(0))] = ss[0] = agx_word_in(key, 0);
    cx->ks[agx_v(48,(1))] = ss[1] = agx_word_in(key, 1);
    cx->ks[agx_v(48,(2))] = ss[2] = agx_word_in(key, 2);
    cx->ks[agx_v(48,(3))] = ss[3] = agx_word_in(key, 3);

#ifdef AGX_DEC_KS_UNROLL
    cx->ks[agx_v(48,(4))] = agx_ff(ss[4] = agx_word_in(key, 4));
    cx->ks[agx_v(48,(5))] = agx_ff(ss[5] = agx_word_in(key, 5));
    agx_kdf6(cx->ks, 0); agx_kd6(cx->ks, 1);
    agx_kd6(cx->ks, 2);  agx_kd6(cx->ks, 3);
    agx_kd6(cx->ks, 4);  agx_kd6(cx->ks, 5);
    agx_kd6(cx->ks, 6);  agx_kdl6(cx->ks, 7);
#else
    cx->ks[agx_v(48,(4))] = ss[4] = agx_word_in(key, 4);
    cx->ks[agx_v(48,(5))] = ss[5] = agx_word_in(key, 5);
    {   uint32_t i;

        for(i = 0; i < 7; ++i)
            agx_k6e(cx->ks, i);
        agx_k6ef(cx->ks, 7);
#if !(AGX_DEC_ROUND == AGX_NO_TABLES)
        for(i = AGX_N_COLS; i < 12 * AGX_N_COLS; ++i)
            cx->ks[i] = agx_inv_mcol(cx->ks[i]);
#endif
    }
#endif
    cx->inf.l = 0;
    cx->inf.b[0] = 12 * 16;

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
    if(VIA_ACE_AVAILABLE)
        cx->inf.b[1] = 0xff;
#endif
    return EXIT_SUCCESS;
}

#endif

#if defined(AGX_AES_256) || defined( AGX_AES_VAR )

#define agx_k8ef(k,i) \
{   k[v(56,(8*(i))+ 8)] = ss[0] ^= agx_ls_box(ss[7],3) ^ agx_t_use(r,c)[i]; \
    k[v(56,(8*(i))+ 9)] = ss[1] ^= ss[0]; \
    k[v(56,(8*(i))+10)] = ss[2] ^= ss[1]; \
    k[v(56,(8*(i))+11)] = ss[3] ^= ss[2]; \
}

#define agx_k8e(k,i) \
{   agx_k8ef(k,i); \
    k[v(56,(8*(i))+12)] = ss[4] ^= agx_ls_box(ss[3],0); \
    k[v(56,(8*(i))+13)] = ss[5] ^= ss[4]; \
    k[v(56,(8*(i))+14)] = ss[6] ^= ss[5]; \
    k[v(56,(8*(i))+15)] = ss[7] ^= ss[6]; \
}

#define agx_kdf8(k,i) \
{   ss[0] ^= agx_ls_box(ss[7],3) ^ agx_t_use(r,c)[i]; k[agx_v(56,(8*(i))+ 8)] = agx_ff(ss[0]); \
    ss[1] ^= ss[0]; k[agx_v(56,(8*(i))+ 9)] = agx_ff(ss[1]); \
    ss[2] ^= ss[1]; k[agx_v(56,(8*(i))+10)] = agx_ff(ss[2]); \
    ss[3] ^= ss[2]; k[agx_v(56,(8*(i))+11)] = agx_ff(ss[3]); \
    ss[4] ^= agx_ls_box(ss[3],0); k[agx_v(56,(8*(i))+12)] = agx_ff(ss[4]); \
    ss[5] ^= ss[4]; k[agx_v(56,(8*(i))+13)] = agx_ff(ss[5]); \
    ss[6] ^= ss[5]; k[agx_v(56,(8*(i))+14)] = agx_ff(ss[6]); \
    ss[7] ^= ss[6]; k[agx_v(56,(8*(i))+15)] = agx_ff(ss[7]); \
}

#define agx_kd8(k,i) \
{   ss[8] = agx_ls_box(ss[7],3) ^ agx_t_use(r,c)[i]; \
    ss[0] ^= ss[8]; ss[8] = agx_ff(ss[8]); k[agx_v(56,(8*(i))+ 8)] = ss[8] ^= k[agx_v(56,(8*(i)))]; \
    ss[1] ^= ss[0]; k[agx_v(56,(8*(i))+ 9)] = ss[8] ^= k[agx_v(56,(8*(i))+ 1)]; \
    ss[2] ^= ss[1]; k[agx_v(56,(8*(i))+10)] = ss[8] ^= k[agx_v(56,(8*(i))+ 2)]; \
    ss[3] ^= ss[2]; k[agx_v(56,(8*(i))+11)] = ss[8] ^= k[agx_v(56,(8*(i))+ 3)]; \
    ss[8] = agx_ls_box(ss[3],0); \
    ss[4] ^= ss[8]; ss[8] = agx_ff(ss[8]); k[agx_v(56,(8*(i))+12)] = ss[8] ^= k[agx_v(56,(8*(i))+ 4)]; \
    ss[5] ^= ss[4]; k[agx_v(56,(8*(i))+13)] = ss[8] ^= k[agx_v(56,(8*(i))+ 5)]; \
    ss[6] ^= ss[5]; k[agx_v(56,(8*(i))+14)] = ss[8] ^= k[agx_v(56,(8*(i))+ 6)]; \
    ss[7] ^= ss[6]; k[agx_v(56,(8*(i))+15)] = ss[8] ^= k[agx_v(56,(8*(i))+ 7)]; \
}

#define agx_kdl8(k,i) \
{   ss[0] ^= agx_ls_box(ss[7],3) ^ agx_t_use(r,c)[i]; k[agx_v(56,(8*(i))+ 8)] = ss[0]; \
    ss[1] ^= ss[0]; k[agx_v(56,(8*(i))+ 9)] = ss[1]; \
    ss[2] ^= ss[1]; k[agx_v(56,(8*(i))+10)] = ss[2]; \
    ss[3] ^= ss[2]; k[agx_v(56,(8*(i))+11)] = ss[3]; \
}

AGX_AES_RETURN agx_aes_xi(decrypt_key256)(const unsigned char *key, agx_aes_decrypt_ctx cx[1])
{   uint32_t    ss[9];
#if defined( agx_d_vars )
        agx_d_vars;
#endif

    cx->ks[agx_v(56,(0))] = ss[0] = agx_word_in(key, 0);
    cx->ks[agx_v(56,(1))] = ss[1] = agx_word_in(key, 1);
    cx->ks[agx_v(56,(2))] = ss[2] = agx_word_in(key, 2);
    cx->ks[agx_v(56,(3))] = ss[3] = agx_word_in(key, 3);

#ifdef AGX_DEC_KS_UNROLL
    cx->ks[agx_v(56,(4))] = agx_ff(ss[4] = agx_word_in(key, 4));
    cx->ks[agx_v(56,(5))] = agx_ff(ss[5] = agx_word_in(key, 5));
    cx->ks[agx_v(56,(6))] = agx_ff(ss[6] = agx_word_in(key, 6));
    cx->ks[agx_v(56,(7))] = agx_ff(ss[7] = agx_word_in(key, 7));
    agx_kdf8(cx->ks, 0); agx_kd8(cx->ks, 1);
    agx_kd8(cx->ks, 2);  agx_kd8(cx->ks, 3);
    agx_kd8(cx->ks, 4);  agx_kd8(cx->ks, 5);
    agx_kdl8(cx->ks, 6);
#else
    cx->ks[agx_v(56,(4))] = ss[4] = agx_word_in(key, 4);
    cx->ks[agx_v(56,(5))] = ss[5] = agx_word_in(key, 5);
    cx->ks[agx_v(56,(6))] = ss[6] = agx_word_in(key, 6);
    cx->ks[agx_v(56,(7))] = ss[7] = agx_word_in(key, 7);
    {   uint32_t i;

        for(i = 0; i < 6; ++i)
            agx_k8e(cx->ks,  i);
        agx_k8ef(cx->ks,  6);
#if !(AGX_DEC_ROUND == AGX_NO_TABLES)
        for(i = AGX_N_COLS; i < 14 * AGX_N_COLS; ++i)
            cx->ks[i] = agx_inv_mcol(cx->ks[i]);
#endif
    }
#endif
    cx->inf.l = 0;
    cx->inf.b[0] = 14 * 16;

#ifdef AGX_USE_VIA_ACE_IF_PRESENT
    if(VIA_ACE_AVAILABLE)
        cx->inf.b[1] = 0xff;
#endif
    return EXIT_SUCCESS;
}

#endif

#endif

#if defined( AGX_AES_VAR )

AGX_AES_RETURN agx_aes_encrypt_key(const unsigned char *key, int key_len, agx_aes_encrypt_ctx cx[1])
{
	switch(key_len)
	{
	case 16: case 128: return agx_aes_encrypt_key128(key, cx);
	case 24: case 192: return agx_aes_encrypt_key192(key, cx);
	case 32: case 256: return agx_aes_encrypt_key256(key, cx);
	default: return EXIT_FAILURE;
	}
}

AGX_AES_RETURN agx_aes_decrypt_key(const unsigned char *key, int key_len, agx_aes_decrypt_ctx cx[1])
{
	switch(key_len)
	{
	case 16: case 128: return agx_aes_decrypt_key128(key, cx);
	case 24: case 192: return agx_aes_decrypt_key192(key, cx);
	case 32: case 256: return agx_aes_decrypt_key256(key, cx);
	default: return EXIT_FAILURE;
	}
}

#endif

#if defined(__cplusplus)
}
#endif
