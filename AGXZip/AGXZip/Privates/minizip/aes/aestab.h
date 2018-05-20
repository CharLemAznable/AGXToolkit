//
//  aestab.h
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

 This file contains the code for declaring the tables needed to implement
 AES. The file aesopt.h is assumed to be included before this header file.
 If there are no global variables, the definitions here can be used to put
 the AES tables in a structure so that a pointer can then be added to the
 AES context to pass them to the AES routines that need them.   If this
 facility is used, the calling program has to ensure that this pointer is
 managed appropriately.  In particular, the value of the t_dec(in,it) item
 in the table structure must be set to zero in order to ensure that the
 tables are initialised. In practice the three code sequences in aeskey.c
 that control the calls to aes_init() and the aes_init() routine itself will
 have to be changed for a specific implementation. If global variables are
 available it will generally be preferable to use them with the precomputed
 STATIC_TABLES option that uses static global tables.

 The following defines can be used to control the way the tables
 are defined, initialised and used in embedded environments that
 require special features for these purposes

    the 't_dec' construction is used to declare fixed table arrays
    the 't_set' construction is used to set fixed table values
    the 't_use' construction is used to access fixed table values

    256 byte tables:

        t_xxx(s,box)    => forward S box
        t_xxx(i,box)    => inverse S box

    256 32-bit word OR 4 x 256 32-bit word tables:

        t_xxx(f,n)      => forward normal round
        t_xxx(f,l)      => forward last round
        t_xxx(i,n)      => inverse normal round
        t_xxx(i,l)      => inverse last round
        t_xxx(l,s)      => key schedule table
        t_xxx(i,m)      => key schedule table

    Other variables and tables:

        t_xxx(r,c)      => the rcon table
*/

#if !defined( _AESTAB_H )
#define _AESTAB_H

#if defined(__cplusplus)
extern "C" {
#endif

#define t_dec(m,n) t_##m##n
#define t_set(m,n) t_##m##n
#define t_use(m,n) t_##m##n

#if defined(STATIC_TABLES)
#  if !defined( __GNUC__ ) && (defined( __MSDOS__ ) || defined( __WIN16__ ))
/*   make tables far data to avoid using too much DGROUP space (PG) */
#    define CONST const far
#  else
#    define CONST const
#  endif
#else
#  define CONST
#endif

#if defined(DO_TABLES)
#  define EXTERN
#else
#  define EXTERN extern
#endif

#if defined(_MSC_VER) && defined(TABLE_ALIGN)
#define ALIGN __declspec(align(TABLE_ALIGN))
#else
#define ALIGN
#endif

#if defined( __WATCOMC__ ) && ( __WATCOMC__ >= 1100 )
#  define XP_DIR __cdecl
#else
#  define XP_DIR
#endif

#if defined(DO_TABLES) && defined(STATIC_TABLES)
#define d_1(t,n,b,e)       EXTERN ALIGN CONST XP_DIR t n[256]    =   b(e)
#define d_4(t,n,b,e,f,g,h) EXTERN ALIGN CONST XP_DIR t n[4][256] = { b(e), b(f), b(g), b(h) }
EXTERN ALIGN CONST uint32_t t_dec(r,c)[RC_LENGTH] = rc_data(w0);
#else
#define d_1(t,n,b,e)       EXTERN ALIGN CONST XP_DIR t n[256]
#define d_4(t,n,b,e,f,g,h) EXTERN ALIGN CONST XP_DIR t n[4][256]
EXTERN ALIGN CONST uint32_t t_dec(r,c)[RC_LENGTH];
#endif

#if defined( SBX_SET )
    d_1(uint8_t, t_dec(s,box), sb_data, h0);
#endif
#if defined( ISB_SET )
    d_1(uint8_t, t_dec(i,box), isb_data, h0);
#endif

#if defined( FT1_SET )
    d_1(uint32_t, t_dec(f,n), sb_data, u0);
#endif
#if defined( FT4_SET )
    d_4(uint32_t, t_dec(f,n), sb_data, u0, u1, u2, u3);
#endif

#if defined( FL1_SET )
    d_1(uint32_t, t_dec(f,l), sb_data, w0);
#endif
#if defined( FL4_SET )
    d_4(uint32_t, t_dec(f,l), sb_data, w0, w1, w2, w3);
#endif

#if defined( IT1_SET )
    d_1(uint32_t, t_dec(i,n), isb_data, v0);
#endif
#if defined( IT4_SET )
    d_4(uint32_t, t_dec(i,n), isb_data, v0, v1, v2, v3);
#endif

#if defined( IL1_SET )
    d_1(uint32_t, t_dec(i,l), isb_data, w0);
#endif
#if defined( IL4_SET )
    d_4(uint32_t, t_dec(i,l), isb_data, w0, w1, w2, w3);
#endif

#if defined( LS1_SET )
#if defined( FL1_SET )
#undef  LS1_SET
#else
    d_1(uint32_t, t_dec(l,s), sb_data, w0);
#endif
#endif

#if defined( LS4_SET )
#if defined( FL4_SET )
#undef  LS4_SET
#else
    d_4(uint32_t, t_dec(l,s), sb_data, w0, w1, w2, w3);
#endif
#endif

#if defined( IM1_SET )
    d_1(uint32_t, t_dec(i,m), mm_data, v0);
#endif
#if defined( IM4_SET )
    d_4(uint32_t, t_dec(i,m), mm_data, v0, v1, v2, v3);
#endif

#if defined(__cplusplus)
}
#endif

#endif
