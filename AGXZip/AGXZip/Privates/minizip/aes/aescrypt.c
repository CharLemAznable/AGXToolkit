//
//  aescrypt.c
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

#if defined(__cplusplus)
extern "C"
{
#endif

#define agx_si(y,x,k,c) (agx_s(y,c) = agx_word_in(x, c) ^ (k)[c])
#define agx_so(y,x,c)   agx_word_out(y, c, agx_s(x,c))

#if defined(AGX_ARRAYS)
#define agx_locals(y,x)     x[4],y[4]
#else
#define agx_locals(y,x)     x##0,x##1,x##2,x##3,y##0,y##1,y##2,y##3
#endif

#define agx_l_copy(y, x)    agx_s(y,0) = agx_s(x,0); agx_s(y,1) = agx_s(x,1); \
                            agx_s(y,2) = agx_s(x,2); agx_s(y,3) = agx_s(x,3);
#define agx_state_in(y,x,k) agx_si(y,x,k,0); agx_si(y,x,k,1); agx_si(y,x,k,2); agx_si(y,x,k,3)
#define agx_state_out(y,x)  agx_so(y,x,0); agx_so(y,x,1); agx_so(y,x,2); agx_so(y,x,3)
#define agx_round(rm,y,x,k) rm(y,x,k,0); rm(y,x,k,1); rm(y,x,k,2); rm(y,x,k,3)

#if ( AGX_FUNCS_IN_C & AGX_ENCRYPTION_IN_C )

/* Visual C++ .Net v7.1 provides the fastest encryption code when using
   Pentium optimiation with small code but this is poor for decryption
   so we need to control this with the following VC++ pragmas
*/

#if defined( _MSC_VER ) && !defined( _WIN64 )
#pragma optimize( "s", on )
#endif

/* Given the column (c) of the output state variable, the following
   macros give the input state variables which are needed in its
   computation for each row (r) of the state. All the alternative
   macros give the same end values but expand into different ways
   of calculating these values.  In particular the complex macro
   used for dynamically variable block sizes is designed to expand
   to a compile time constant whenever possible but will expand to
   conditional clauses on some branches (I am grateful to Frank
   Yellin for this construction)
*/

#define agx_fwd_var(x,r,c)\
 ( r == 0 ? ( c == 0 ? agx_s(x,0) : c == 1 ? agx_s(x,1) : c == 2 ? agx_s(x,2) : agx_s(x,3))\
 : r == 1 ? ( c == 0 ? agx_s(x,1) : c == 1 ? agx_s(x,2) : c == 2 ? agx_s(x,3) : agx_s(x,0))\
 : r == 2 ? ( c == 0 ? agx_s(x,2) : c == 1 ? agx_s(x,3) : c == 2 ? agx_s(x,0) : agx_s(x,1))\
 :          ( c == 0 ? agx_s(x,3) : c == 1 ? agx_s(x,0) : c == 2 ? agx_s(x,1) : agx_s(x,2)))

#if defined(AGX_FT4_SET)
#undef  agx_dec_fmvars
#define agx_fwd_rnd(y,x,k,c)    (agx_s(y,c) = (k)[c] ^ agx_four_tables(x,agx_t_use(f,n),agx_fwd_var,agx_rf1,c))
#elif defined(AGX_FT1_SET)
#undef  agx_dec_fmvars
#define agx_fwd_rnd(y,x,k,c)    (agx_s(y,c) = (k)[c] ^ agx_one_table(x,agx_upr,agx_t_use(f,n),agx_fwd_var,agx_rf1,c))
#else
#define agx_fwd_rnd(y,x,k,c)    (agx_s(y,c) = (k)[c] ^ agx_fwd_mcol(agx_no_table(x,agx_t_use(s,box),agx_fwd_var,agx_rf1,c)))
#endif

#if defined(AGX_FL4_SET)
#define agx_fwd_lrnd(y,x,k,c)   (agx_s(y,c) = (k)[c] ^ agx_four_tables(x,agx_t_use(f,l),agx_fwd_var,agx_rf1,c))
#elif defined(AGX_FL1_SET)
#define agx_fwd_lrnd(y,x,k,c)   (agx_s(y,c) = (k)[c] ^ agx_one_table(x,agx_ups,agx_t_use(f,l),agx_fwd_var,agx_rf1,c))
#else
#define agx_fwd_lrnd(y,x,k,c)   (agx_s(y,c) = (k)[c] ^ agx_no_table(x,agx_t_use(s,box),agx_fwd_var,agx_rf1,c))
#endif

AGX_AES_RETURN agx_aes_xi(encrypt)(const unsigned char *in, unsigned char *out, const agx_aes_encrypt_ctx cx[1])
{   uint32_t         agx_locals(b0, b1);
    const uint32_t   *kp;
#if defined( agx_dec_fmvars )
    agx_dec_fmvars; /* declare variables for fwd_mcol() if needed */
#endif

	if(cx->inf.b[0] != 10 * 16 && cx->inf.b[0] != 12 * 16 && cx->inf.b[0] != 14 * 16)
		return EXIT_FAILURE;

	kp = cx->ks;
    agx_state_in(b0, in, kp);

#if (AGX_ENC_UNROLL == AGX_FULL)

    switch(cx->inf.b[0])
    {
    case 14 * 16:
        agx_round(agx_fwd_rnd,  b1, b0, kp + 1 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b0, b1, kp + 2 * AGX_N_COLS);
        kp += 2 * AGX_N_COLS;
    case 12 * 16:
        agx_round(agx_fwd_rnd,  b1, b0, kp + 1 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b0, b1, kp + 2 * AGX_N_COLS);
        kp += 2 * AGX_N_COLS;
    case 10 * 16:
        agx_round(agx_fwd_rnd,  b1, b0, kp + 1 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b0, b1, kp + 2 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b1, b0, kp + 3 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b0, b1, kp + 4 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b1, b0, kp + 5 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b0, b1, kp + 6 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b1, b0, kp + 7 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b0, b1, kp + 8 * AGX_N_COLS);
        agx_round(agx_fwd_rnd,  b1, b0, kp + 9 * AGX_N_COLS);
        agx_round(agx_fwd_lrnd, b0, b1, kp +10 * AGX_N_COLS);
    }

#else

#if (AGX_ENC_UNROLL == AGX_PARTIAL)
    {   uint32_t    rnd;
        for(rnd = 0; rnd < (cx->inf.b[0] >> 5) - 1; ++rnd)
        {
            kp += AGX_N_COLS;
            agx_round(agx_fwd_rnd, b1, b0, kp);
            kp += AGX_N_COLS;
            agx_round(agx_fwd_rnd, b0, b1, kp);
        }
        kp += AGX_N_COLS;
        agx_round(agx_fwd_rnd,  b1, b0, kp);
#else
    {   uint32_t    rnd;
        for(rnd = 0; rnd < (cx->inf.b[0] >> 4) - 1; ++rnd)
        {
            kp += AGX_N_COLS;
            agx_round(agx_fwd_rnd, b1, b0, kp);
            l_copy(b0, b1);
        }
#endif
        kp += AGX_N_COLS;
        agx_round(agx_fwd_lrnd, b0, b1, kp);
    }
#endif

    agx_state_out(out, b0);
    return EXIT_SUCCESS;
}

#endif

#if ( AGX_FUNCS_IN_C & AGX_DECRYPTION_IN_C)

/* Visual C++ .Net v7.1 provides the fastest encryption code when using
   Pentium optimiation with small code but this is poor for decryption
   so we need to control this with the following VC++ pragmas
*/

#if defined( _MSC_VER ) && !defined( _WIN64 )
#pragma optimize( "t", on )
#endif

/* Given the column (c) of the output state variable, the following
   macros give the input state variables which are needed in its
   computation for each row (r) of the state. All the alternative
   macros give the same end values but expand into different ways
   of calculating these values.  In particular the complex macro
   used for dynamically variable block sizes is designed to expand
   to a compile time constant whenever possible but will expand to
   conditional clauses on some branches (I am grateful to Frank
   Yellin for this construction)
*/

#define agx_inv_var(x,r,c)\
 ( r == 0 ? ( c == 0 ? agx_s(x,0) : c == 1 ? agx_s(x,1) : c == 2 ? agx_s(x,2) : agx_s(x,3))\
 : r == 1 ? ( c == 0 ? agx_s(x,3) : c == 1 ? agx_s(x,0) : c == 2 ? agx_s(x,1) : agx_s(x,2))\
 : r == 2 ? ( c == 0 ? agx_s(x,2) : c == 1 ? agx_s(x,3) : c == 2 ? agx_s(x,0) : agx_s(x,1))\
 :          ( c == 0 ? agx_s(x,1) : c == 1 ? agx_s(x,2) : c == 2 ? agx_s(x,3) : agx_s(x,0)))

#if defined(AGX_IT4_SET)
#undef  agx_dec_imvars
#define agx_inv_rnd(y,x,k,c)    (agx_s(y,c) = (k)[c] ^ agx_four_tables(x,agx_t_use(i,n),agx_inv_var,agx_rf1,c))
#elif defined(AGX_IT1_SET)
#undef  agx_dec_imvars
#define agx_inv_rnd(y,x,k,c)    (agx_s(y,c) = (k)[c] ^ agx_one_table(x,agx_upr,agx_t_use(i,n),agx_inv_var,agx_rf1,c))
#else
#define agx_inv_rnd(y,x,k,c)    (agx_s(y,c) = agx_inv_mcol((k)[c] ^ agx_no_table(x,agx_t_use(i,box),agx_inv_var,agx_rf1,c)))
#endif

#if defined(AGX_IL4_SET)
#define agx_inv_lrnd(y,x,k,c)   (agx_s(y,c) = (k)[c] ^ agx_four_tables(x,agx_t_use(i,l),agx_inv_var,agx_rf1,c))
#elif defined(AGX_IL1_SET)
#define agx_inv_lrnd(y,x,k,c)   (agx_s(y,c) = (k)[c] ^ agx_one_table(x,agx_ups,agx_t_use(i,l),agx_inv_var,agx_rf1,c))
#else
#define agx_inv_lrnd(y,x,k,c)   (agx_s(y,c) = (k)[c] ^ agx_no_table(x,agx_t_use(i,box),agx_inv_var,agx_rf1,c))
#endif

/* This code can work with the decryption key schedule in the   */
/* order that is used for encrytpion (where the 1st decryption  */
/* round key is at the high end ot the schedule) or with a key  */
/* schedule that has been reversed to put the 1st decryption    */
/* round key at the low end of the schedule in memory (when     */
/* AES_REV_DKS is defined)                                      */

#ifdef AES_REV_DKS
#define agx_key_ofs     0
#define agx_rnd_key(n)  (kp + n * AGX_N_COLS)
#else
#define agx_key_ofs     1
#define agx_rnd_key(n)  (kp - n * AGX_N_COLS)
#endif

AGX_AES_RETURN agx_aes_xi(decrypt)(const unsigned char *in, unsigned char *out, const agx_aes_decrypt_ctx cx[1])
{   uint32_t        agx_locals(b0, b1);
#if defined( dec_imvars )
    agx_dec_imvars; /* declare variables for inv_mcol() if needed */
#endif
    const uint32_t *kp;

    if(cx->inf.b[0] != 10 * 16 && cx->inf.b[0] != 12 * 16 && cx->inf.b[0] != 14 * 16)
        return EXIT_FAILURE;

    kp = cx->ks + (agx_key_ofs ? (cx->inf.b[0] >> 2) : 0);
    agx_state_in(b0, in, kp);

#if (AGX_DEC_UNROLL == AGX_FULL)

    kp = cx->ks + (agx_key_ofs ? 0 : (cx->inf.b[0] >> 2));
    switch(cx->inf.b[0])
    {
    case 14 * 16:
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-13));
        agx_round(agx_inv_rnd,  b0, b1, agx_rnd_key(-12));
    case 12 * 16:
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-11));
        agx_round(agx_inv_rnd,  b0, b1, agx_rnd_key(-10));
    case 10 * 16:
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-9));
        agx_round(agx_inv_rnd,  b0, b1, agx_rnd_key(-8));
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-7));
        agx_round(agx_inv_rnd,  b0, b1, agx_rnd_key(-6));
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-5));
        agx_round(agx_inv_rnd,  b0, b1, agx_rnd_key(-4));
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-3));
        agx_round(agx_inv_rnd,  b0, b1, agx_rnd_key(-2));
        agx_round(agx_inv_rnd,  b1, b0, agx_rnd_key(-1));
        agx_round(agx_inv_lrnd, b0, b1, agx_rnd_key( 0));
    }

#else

#if (AGX_DEC_UNROLL == AGX_PARTIAL)
    {   uint32_t    rnd;
        for(rnd = 0; rnd < (cx->inf.b[0] >> 5) - 1; ++rnd)
        {
            kp = agx_rnd_key(1);
            agx_round(agx_inv_rnd, b1, b0, kp);
            kp = agx_rnd_key(1);
            agx_round(agx_inv_rnd, b0, b1, kp);
        }
        kp = agx_rnd_key(1);
        agx_round(agx_inv_rnd, b1, b0, kp);
#else
    {   uint32_t    rnd;
        for(rnd = 0; rnd < (cx->inf.b[0] >> 4) - 1; ++rnd)
        {
            kp = agx_rnd_key(1);
            agx_round(agx_inv_rnd, b1, b0, kp);
            l_copy(b0, b1);
        }
#endif
        kp = agx_rnd_key(1);
        agx_round(agx_inv_lrnd, b0, b1, kp);
        }
#endif

    agx_state_out(out, b0);
    return EXIT_SUCCESS;
}

#endif

#if defined(__cplusplus)
}
#endif
