//
//  aestab.c
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

#define AGX_DO_TABLES

#include "aes.h"
#include "aesopt.h"

#if defined(AGX_STATIC_TABLES)

#define agx_sb_data(w) {\
    w(0x63), w(0x7c), w(0x77), w(0x7b), w(0xf2), w(0x6b), w(0x6f), w(0xc5),\
    w(0x30), w(0x01), w(0x67), w(0x2b), w(0xfe), w(0xd7), w(0xab), w(0x76),\
    w(0xca), w(0x82), w(0xc9), w(0x7d), w(0xfa), w(0x59), w(0x47), w(0xf0),\
    w(0xad), w(0xd4), w(0xa2), w(0xaf), w(0x9c), w(0xa4), w(0x72), w(0xc0),\
    w(0xb7), w(0xfd), w(0x93), w(0x26), w(0x36), w(0x3f), w(0xf7), w(0xcc),\
    w(0x34), w(0xa5), w(0xe5), w(0xf1), w(0x71), w(0xd8), w(0x31), w(0x15),\
    w(0x04), w(0xc7), w(0x23), w(0xc3), w(0x18), w(0x96), w(0x05), w(0x9a),\
    w(0x07), w(0x12), w(0x80), w(0xe2), w(0xeb), w(0x27), w(0xb2), w(0x75),\
    w(0x09), w(0x83), w(0x2c), w(0x1a), w(0x1b), w(0x6e), w(0x5a), w(0xa0),\
    w(0x52), w(0x3b), w(0xd6), w(0xb3), w(0x29), w(0xe3), w(0x2f), w(0x84),\
    w(0x53), w(0xd1), w(0x00), w(0xed), w(0x20), w(0xfc), w(0xb1), w(0x5b),\
    w(0x6a), w(0xcb), w(0xbe), w(0x39), w(0x4a), w(0x4c), w(0x58), w(0xcf),\
    w(0xd0), w(0xef), w(0xaa), w(0xfb), w(0x43), w(0x4d), w(0x33), w(0x85),\
    w(0x45), w(0xf9), w(0x02), w(0x7f), w(0x50), w(0x3c), w(0x9f), w(0xa8),\
    w(0x51), w(0xa3), w(0x40), w(0x8f), w(0x92), w(0x9d), w(0x38), w(0xf5),\
    w(0xbc), w(0xb6), w(0xda), w(0x21), w(0x10), w(0xff), w(0xf3), w(0xd2),\
    w(0xcd), w(0x0c), w(0x13), w(0xec), w(0x5f), w(0x97), w(0x44), w(0x17),\
    w(0xc4), w(0xa7), w(0x7e), w(0x3d), w(0x64), w(0x5d), w(0x19), w(0x73),\
    w(0x60), w(0x81), w(0x4f), w(0xdc), w(0x22), w(0x2a), w(0x90), w(0x88),\
    w(0x46), w(0xee), w(0xb8), w(0x14), w(0xde), w(0x5e), w(0x0b), w(0xdb),\
    w(0xe0), w(0x32), w(0x3a), w(0x0a), w(0x49), w(0x06), w(0x24), w(0x5c),\
    w(0xc2), w(0xd3), w(0xac), w(0x62), w(0x91), w(0x95), w(0xe4), w(0x79),\
    w(0xe7), w(0xc8), w(0x37), w(0x6d), w(0x8d), w(0xd5), w(0x4e), w(0xa9),\
    w(0x6c), w(0x56), w(0xf4), w(0xea), w(0x65), w(0x7a), w(0xae), w(0x08),\
    w(0xba), w(0x78), w(0x25), w(0x2e), w(0x1c), w(0xa6), w(0xb4), w(0xc6),\
    w(0xe8), w(0xdd), w(0x74), w(0x1f), w(0x4b), w(0xbd), w(0x8b), w(0x8a),\
    w(0x70), w(0x3e), w(0xb5), w(0x66), w(0x48), w(0x03), w(0xf6), w(0x0e),\
    w(0x61), w(0x35), w(0x57), w(0xb9), w(0x86), w(0xc1), w(0x1d), w(0x9e),\
    w(0xe1), w(0xf8), w(0x98), w(0x11), w(0x69), w(0xd9), w(0x8e), w(0x94),\
    w(0x9b), w(0x1e), w(0x87), w(0xe9), w(0xce), w(0x55), w(0x28), w(0xdf),\
    w(0x8c), w(0xa1), w(0x89), w(0x0d), w(0xbf), w(0xe6), w(0x42), w(0x68),\
    w(0x41), w(0x99), w(0x2d), w(0x0f), w(0xb0), w(0x54), w(0xbb), w(0x16) }

#define agx_isb_data(w) {\
    w(0x52), w(0x09), w(0x6a), w(0xd5), w(0x30), w(0x36), w(0xa5), w(0x38),\
    w(0xbf), w(0x40), w(0xa3), w(0x9e), w(0x81), w(0xf3), w(0xd7), w(0xfb),\
    w(0x7c), w(0xe3), w(0x39), w(0x82), w(0x9b), w(0x2f), w(0xff), w(0x87),\
    w(0x34), w(0x8e), w(0x43), w(0x44), w(0xc4), w(0xde), w(0xe9), w(0xcb),\
    w(0x54), w(0x7b), w(0x94), w(0x32), w(0xa6), w(0xc2), w(0x23), w(0x3d),\
    w(0xee), w(0x4c), w(0x95), w(0x0b), w(0x42), w(0xfa), w(0xc3), w(0x4e),\
    w(0x08), w(0x2e), w(0xa1), w(0x66), w(0x28), w(0xd9), w(0x24), w(0xb2),\
    w(0x76), w(0x5b), w(0xa2), w(0x49), w(0x6d), w(0x8b), w(0xd1), w(0x25),\
    w(0x72), w(0xf8), w(0xf6), w(0x64), w(0x86), w(0x68), w(0x98), w(0x16),\
    w(0xd4), w(0xa4), w(0x5c), w(0xcc), w(0x5d), w(0x65), w(0xb6), w(0x92),\
    w(0x6c), w(0x70), w(0x48), w(0x50), w(0xfd), w(0xed), w(0xb9), w(0xda),\
    w(0x5e), w(0x15), w(0x46), w(0x57), w(0xa7), w(0x8d), w(0x9d), w(0x84),\
    w(0x90), w(0xd8), w(0xab), w(0x00), w(0x8c), w(0xbc), w(0xd3), w(0x0a),\
    w(0xf7), w(0xe4), w(0x58), w(0x05), w(0xb8), w(0xb3), w(0x45), w(0x06),\
    w(0xd0), w(0x2c), w(0x1e), w(0x8f), w(0xca), w(0x3f), w(0x0f), w(0x02),\
    w(0xc1), w(0xaf), w(0xbd), w(0x03), w(0x01), w(0x13), w(0x8a), w(0x6b),\
    w(0x3a), w(0x91), w(0x11), w(0x41), w(0x4f), w(0x67), w(0xdc), w(0xea),\
    w(0x97), w(0xf2), w(0xcf), w(0xce), w(0xf0), w(0xb4), w(0xe6), w(0x73),\
    w(0x96), w(0xac), w(0x74), w(0x22), w(0xe7), w(0xad), w(0x35), w(0x85),\
    w(0xe2), w(0xf9), w(0x37), w(0xe8), w(0x1c), w(0x75), w(0xdf), w(0x6e),\
    w(0x47), w(0xf1), w(0x1a), w(0x71), w(0x1d), w(0x29), w(0xc5), w(0x89),\
    w(0x6f), w(0xb7), w(0x62), w(0x0e), w(0xaa), w(0x18), w(0xbe), w(0x1b),\
    w(0xfc), w(0x56), w(0x3e), w(0x4b), w(0xc6), w(0xd2), w(0x79), w(0x20),\
    w(0x9a), w(0xdb), w(0xc0), w(0xfe), w(0x78), w(0xcd), w(0x5a), w(0xf4),\
    w(0x1f), w(0xdd), w(0xa8), w(0x33), w(0x88), w(0x07), w(0xc7), w(0x31),\
    w(0xb1), w(0x12), w(0x10), w(0x59), w(0x27), w(0x80), w(0xec), w(0x5f),\
    w(0x60), w(0x51), w(0x7f), w(0xa9), w(0x19), w(0xb5), w(0x4a), w(0x0d),\
    w(0x2d), w(0xe5), w(0x7a), w(0x9f), w(0x93), w(0xc9), w(0x9c), w(0xef),\
    w(0xa0), w(0xe0), w(0x3b), w(0x4d), w(0xae), w(0x2a), w(0xf5), w(0xb0),\
    w(0xc8), w(0xeb), w(0xbb), w(0x3c), w(0x83), w(0x53), w(0x99), w(0x61),\
    w(0x17), w(0x2b), w(0x04), w(0x7e), w(0xba), w(0x77), w(0xd6), w(0x26),\
    w(0xe1), w(0x69), w(0x14), w(0x63), w(0x55), w(0x21), w(0x0c), w(0x7d) }

#define agx_mm_data(w) {\
    w(0x00), w(0x01), w(0x02), w(0x03), w(0x04), w(0x05), w(0x06), w(0x07),\
    w(0x08), w(0x09), w(0x0a), w(0x0b), w(0x0c), w(0x0d), w(0x0e), w(0x0f),\
    w(0x10), w(0x11), w(0x12), w(0x13), w(0x14), w(0x15), w(0x16), w(0x17),\
    w(0x18), w(0x19), w(0x1a), w(0x1b), w(0x1c), w(0x1d), w(0x1e), w(0x1f),\
    w(0x20), w(0x21), w(0x22), w(0x23), w(0x24), w(0x25), w(0x26), w(0x27),\
    w(0x28), w(0x29), w(0x2a), w(0x2b), w(0x2c), w(0x2d), w(0x2e), w(0x2f),\
    w(0x30), w(0x31), w(0x32), w(0x33), w(0x34), w(0x35), w(0x36), w(0x37),\
    w(0x38), w(0x39), w(0x3a), w(0x3b), w(0x3c), w(0x3d), w(0x3e), w(0x3f),\
    w(0x40), w(0x41), w(0x42), w(0x43), w(0x44), w(0x45), w(0x46), w(0x47),\
    w(0x48), w(0x49), w(0x4a), w(0x4b), w(0x4c), w(0x4d), w(0x4e), w(0x4f),\
    w(0x50), w(0x51), w(0x52), w(0x53), w(0x54), w(0x55), w(0x56), w(0x57),\
    w(0x58), w(0x59), w(0x5a), w(0x5b), w(0x5c), w(0x5d), w(0x5e), w(0x5f),\
    w(0x60), w(0x61), w(0x62), w(0x63), w(0x64), w(0x65), w(0x66), w(0x67),\
    w(0x68), w(0x69), w(0x6a), w(0x6b), w(0x6c), w(0x6d), w(0x6e), w(0x6f),\
    w(0x70), w(0x71), w(0x72), w(0x73), w(0x74), w(0x75), w(0x76), w(0x77),\
    w(0x78), w(0x79), w(0x7a), w(0x7b), w(0x7c), w(0x7d), w(0x7e), w(0x7f),\
    w(0x80), w(0x81), w(0x82), w(0x83), w(0x84), w(0x85), w(0x86), w(0x87),\
    w(0x88), w(0x89), w(0x8a), w(0x8b), w(0x8c), w(0x8d), w(0x8e), w(0x8f),\
    w(0x90), w(0x91), w(0x92), w(0x93), w(0x94), w(0x95), w(0x96), w(0x97),\
    w(0x98), w(0x99), w(0x9a), w(0x9b), w(0x9c), w(0x9d), w(0x9e), w(0x9f),\
    w(0xa0), w(0xa1), w(0xa2), w(0xa3), w(0xa4), w(0xa5), w(0xa6), w(0xa7),\
    w(0xa8), w(0xa9), w(0xaa), w(0xab), w(0xac), w(0xad), w(0xae), w(0xaf),\
    w(0xb0), w(0xb1), w(0xb2), w(0xb3), w(0xb4), w(0xb5), w(0xb6), w(0xb7),\
    w(0xb8), w(0xb9), w(0xba), w(0xbb), w(0xbc), w(0xbd), w(0xbe), w(0xbf),\
    w(0xc0), w(0xc1), w(0xc2), w(0xc3), w(0xc4), w(0xc5), w(0xc6), w(0xc7),\
    w(0xc8), w(0xc9), w(0xca), w(0xcb), w(0xcc), w(0xcd), w(0xce), w(0xcf),\
    w(0xd0), w(0xd1), w(0xd2), w(0xd3), w(0xd4), w(0xd5), w(0xd6), w(0xd7),\
    w(0xd8), w(0xd9), w(0xda), w(0xdb), w(0xdc), w(0xdd), w(0xde), w(0xdf),\
    w(0xe0), w(0xe1), w(0xe2), w(0xe3), w(0xe4), w(0xe5), w(0xe6), w(0xe7),\
    w(0xe8), w(0xe9), w(0xea), w(0xeb), w(0xec), w(0xed), w(0xee), w(0xef),\
    w(0xf0), w(0xf1), w(0xf2), w(0xf3), w(0xf4), w(0xf5), w(0xf6), w(0xf7),\
    w(0xf8), w(0xf9), w(0xfa), w(0xfb), w(0xfc), w(0xfd), w(0xfe), w(0xff) }

#define agx_rc_data(w) {\
    w(0x01), w(0x02), w(0x04), w(0x08), w(0x10),w(0x20), w(0x40), w(0x80),\
    w(0x1b), w(0x36) }

#define agx_h0(x)   (x)

#define agx_w0(p)   agx_bytes2word(p, 0, 0, 0)
#define agx_w1(p)   agx_bytes2word(0, p, 0, 0)
#define agx_w2(p)   agx_bytes2word(0, 0, p, 0)
#define agx_w3(p)   agx_bytes2word(0, 0, 0, p)

#define agx_u0(p)   agx_bytes2word(agx_f2(p), p, p, agx_f3(p))
#define agx_u1(p)   agx_bytes2word(agx_f3(p), agx_f2(p), p, p)
#define agx_u2(p)   agx_bytes2word(p, agx_f3(p), agx_f2(p), p)
#define agx_u3(p)   agx_bytes2word(p, p, agx_f3(p), agx_f2(p))

#define agx_v0(p)   agx_bytes2word(agx_fe(p), agx_f9(p), agx_fd(p), agx_fb(p))
#define agx_v1(p)   agx_bytes2word(agx_fb(p), agx_fe(p), agx_f9(p), agx_fd(p))
#define agx_v2(p)   agx_bytes2word(agx_fd(p), agx_fb(p), agx_fe(p), agx_f9(p))
#define agx_v3(p)   agx_bytes2word(agx_f9(p), agx_fd(p), agx_fb(p), agx_fe(p))

#endif

#if defined(AGX_STATIC_TABLES) || !defined(AGX_FF_TABLES)

#define agx_f2(x)   ((x<<1) ^ (((x>>7) & 1) * AGX_WPOLY))
#define agx_f4(x)   ((x<<2) ^ (((x>>6) & 1) * AGX_WPOLY) ^ (((x>>6) & 2) * AGX_WPOLY))
#define agx_f8(x)   ((x<<3) ^ (((x>>5) & 1) * AGX_WPOLY) ^ (((x>>5) & 2) * AGX_WPOLY) \
                        ^ (((x>>5) & 4) * AGX_WPOLY))
#define agx_f3(x)   (agx_f2(x) ^ x)
#define agx_f9(x)   (agx_f8(x) ^ x)
#define agx_fb(x)   (agx_f8(x) ^ agx_f2(x) ^ x)
#define agx_fd(x)   (agx_f8(x) ^ agx_f4(x) ^ x)
#define agx_fe(x)   (agx_f8(x) ^ agx_f4(x) ^ agx_f2(x))

#else

#define agx_f2(x) ((x) ? pow[log[x] + 0x19] : 0)
#define agx_f3(x) ((x) ? pow[log[x] + 0x01] : 0)
#define agx_f9(x) ((x) ? pow[log[x] + 0xc7] : 0)
#define agx_fb(x) ((x) ? pow[log[x] + 0x68] : 0)
#define agx_fd(x) ((x) ? pow[log[x] + 0xee] : 0)
#define agx_fe(x) ((x) ? pow[log[x] + 0xdf] : 0)

#endif

#include "aestab.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#if defined(AGX_STATIC_TABLES)

/* implemented in case of wrong call for fixed tables */

AGX_AES_RETURN agx_aes_init(void)
{
    return EXIT_SUCCESS;
}

#else   /*  Generate the tables for the dynamic table option */

#if defined(AGX_FF_TABLES)

#define agx_gf_inv(x)   ((x) ? pow[ 255 - log[x]] : 0)

#else

/*  It will generally be sensible to use tables to compute finite
    field multiplies and inverses but where memory is scarse this
    code might sometimes be better. But it only has effect during
    initialisation so its pretty unimportant in overall terms.
*/

/*  return 2 ^ (n - 1) where n is the bit number of the highest bit
    set in x with x in the range 1 < x < 0x00000200.   This form is
    used so that locals within fi can be bytes rather than words
*/

static uint8_t agx_hibit(const uint32_t x)
{   uint8_t r = (uint8_t)((x >> 1) | (x >> 2));

    r |= (r >> 2);
    r |= (r >> 4);
    return (r + 1) >> 1;
}

/* return the inverse of the finite field element x */

static uint8_t agx_gf_inv(const uint8_t x)
{   uint8_t p1 = x, p2 = AGX_BPOLY, n1 = agx_hibit(x), n2 = 0x80, v1 = 1, v2 = 0;

    if(x < 2)
        return x;

    for( ; ; )
    {
        if(n1)
            while(n2 >= n1)             /* divide polynomial p2 by p1    */
            {
                n2 /= n1;               /* shift smaller polynomial left */
                p2 ^= (p1 * n2) & 0xff; /* and remove from larger one    */
                v2 ^= v1 * n2;          /* shift accumulated value and   */
                n2 = agx_hibit(p2);         /* add into result               */
            }
        else
            return v1;

        if(n2)                          /* repeat with values swapped    */
            while(n1 >= n2)
            {
                n1 /= n2;
                p1 ^= p2 * n1;
                v1 ^= v2 * n1;
                n1 = agx_hibit(p1);
            }
        else
            return v2;
    }
}

#endif

/* The forward and inverse affine transformations used in the S-box */
uint8_t agx_fwd_affine(const uint8_t x)
{   uint32_t w = x;
    w ^= (w << 1) ^ (w << 2) ^ (w << 3) ^ (w << 4);
    return 0x63 ^ ((w ^ (w >> 8)) & 0xff);
}

uint8_t agx_inv_affine(const uint8_t x)
{   uint32_t w = x;
    w = (w << 1) ^ (w << 3) ^ (w << 6);
    return 0x05 ^ ((w ^ (w >> 8)) & 0xff);
}

static int init = 0;

AGX_AES_RETURN agx_aes_init(void)
{   uint32_t  i, w;

#if defined(AGX_FF_TABLES)

    uint8_t  pow[512], log[256];

    if(init)
        return EXIT_SUCCESS;
    /*  log and power tables for GF(2^8) finite field with
        WPOLY as modular polynomial - the simplest primitive
        root is 0x03, used here to generate the tables
    */

    i = 0; w = 1;
    do
    {
        pow[i] = (uint8_t)w;
        pow[i + 255] = (uint8_t)w;
        log[w] = (uint8_t)i++;
        w ^=  (w << 1) ^ (w & 0x80 ? AGX_WPOLY : 0);
    }
    while (w != 1);

#else
    if(init)
        return EXIT_SUCCESS;
#endif

    for(i = 0, w = 1; i < AGX_RC_LENGTH; ++i)
    {
        agx_t_set(r,c)[i] = agx_bytes2word(w, 0, 0, 0);
        w = agx_f2(w);
    }

    for(i = 0; i < 256; ++i)
    {   uint8_t    b;

        b = agx_fwd_affine(agx_gf_inv((uint8_t)i));
        w = agx_bytes2word(f2(b), b, b, f3(b));

#if defined( AGX_SBX_SET )
        agx_t_set(s,box)[i] = b;
#endif

#if defined( AGX_FT1_SET )                 /* tables for a normal encryption round */
        agx_t_set(f,n)[i] = w;
#endif
#if defined( AGX_FT4_SET )
        agx_t_set(f,n)[0][i] = w;
        agx_t_set(f,n)[1][i] = agx_upr(w,1);
        agx_t_set(f,n)[2][i] = agx_upr(w,2);
        agx_t_set(f,n)[3][i] = agx_upr(w,3);
#endif
        w = agx_bytes2word(b, 0, 0, 0);

#if defined( AGX_FL1_SET )            /* tables for last encryption round (may also   */
        agx_t_set(f,l)[i] = w;        /* be used in the key schedule)                 */
#endif
#if defined( AGX_FL4_SET )
        agx_t_set(f,l)[0][i] = w;
        agx_t_set(f,l)[1][i] = agx_upr(w,1);
        agx_t_set(f,l)[2][i] = agx_upr(w,2);
        agx_t_set(f,l)[3][i] = agx_upr(w,3);
#endif

#if defined( AGX_LS1_SET )			/* table for key schedule if t_set(f,l) above is*/
        t_set(l,s)[i] = w;      /* not of the required form                     */
#endif
#if defined( AGX_LS4_SET )
        agx_t_set(l,s)[0][i] = w;
        agx_t_set(l,s)[1][i] = agx_upr(w,1);
        agx_t_set(l,s)[2][i] = agx_upr(w,2);
        agx_t_set(l,s)[3][i] = agx_upr(w,3);
#endif

        b = agx_gf_inv(agx_inv_affine((uint8_t)i));
        w = agx_bytes2word(fe(b), f9(b), fd(b), fb(b));

#if defined( AGX_IM1_SET )			/* tables for the inverse mix column operation  */
        agx_t_set(i,m)[b] = w;
#endif
#if defined( AGX_IM4_SET )
        agx_t_set(i,m)[0][b] = w;
        agx_t_set(i,m)[1][b] = agx_upr(w,1);
        agx_t_set(i,m)[2][b] = agx_upr(w,2);
        agx_t_set(i,m)[3][b] = agx_upr(w,3);
#endif

#if defined( AGX_ISB_SET )
        agx_t_set(i,box)[i] = b;
#endif
#if defined( AGX_IT1_SET )			/* tables for a normal decryption round */
        agx_t_set(i,n)[i] = w;
#endif
#if defined( AGX_IT4_SET )
        agx_t_set(i,n)[0][i] = w;
        agx_t_set(i,n)[1][i] = agx_upr(w,1);
        agx_t_set(i,n)[2][i] = agx_upr(w,2);
        agx_t_set(i,n)[3][i] = agx_upr(w,3);
#endif
        w = agx_bytes2word(b, 0, 0, 0);
#if defined( AGX_IL1_SET )			/* tables for last decryption round */
        agx_t_set(i,l)[i] = w;
#endif
#if defined( AGX_IL4_SET )
        agx_t_set(i,l)[0][i] = w;
        agx_t_set(i,l)[1][i] = agx_upr(w,1);
        agx_t_set(i,l)[2][i] = agx_upr(w,2);
        agx_t_set(i,l)[3][i] = agx_upr(w,3);
#endif
    }
    init = 1;
    return EXIT_SUCCESS;
}

/* 
   Automatic code initialisation (suggested by by Henrik S. Gaßmann)
   based on code provided by Joe Lowe and placed in the public domain at:
   http://stackoverflow.com/questions/1113409/attribute-constructor-equivalent-in-vc
*/

#ifdef _MSC_VER

#pragma section(".CRT$XCU", read)

__declspec(allocate(".CRT$XCU")) void (__cdecl *agx_aes_startup)(void) = agx_aes_init;

#elif defined(__GNUC__)

static void agx_aes_startup(void) __attribute__((constructor));

static void agx_aes_startup(void)
{
    agx_aes_init();
}

#else

#pragma message( "dynamic tables must be initialised manually on your system" )

#endif

#endif

#if defined(__cplusplus)
}
#endif

