//
//  brg_types.h
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

 The unsigned integer types defined here are of the form uint_<nn>t where
 <nn> is the length of the type; for example, the unsigned 32-bit type is
 'uint32_t'.  These are NOT the same as the 'C99 integer types' that are
 defined in the inttypes.h and stdint.h headers since attempts to use these
 types have shown that support for them is still highly variable.  However,
 since the latter are of the form uint<nn>_t, a regular expression search
 and replace (in VC++ search on 'uint_{:z}t' and replace with 'uint\1_t')
 can be used to convert the types used here to the C99 standard types.
*/

#ifndef _AGX_BRG_TYPES_H
#define _AGX_BRG_TYPES_H

#if defined(__cplusplus)
extern "C" {
#endif

#include <limits.h>
#include <stdint.h>

#if defined( _MSC_VER ) && ( _MSC_VER >= 1300 )
#  include <stddef.h>
#  define agx_ptrint_t intptr_t
#elif defined( __ECOS__ )
#  define intptr_t unsigned int
#  define agx_ptrint_t intptr_t
#elif defined( __GNUC__ ) && ( __GNUC__ >= 3 )
#  define agx_ptrint_t intptr_t
#else
#  define agx_ptrint_t int
#endif

#ifndef AGX_BRG_UI32
#  define AGX_BRG_UI32
#  if UINT_MAX == 4294967295u
#    define agx_li_32(h) 0x##h##u
#  elif ULONG_MAX == 4294967295u
#    define agx_li_32(h) 0x##h##ul
#  elif defined( _CRAY )
#    error This code needs 32-bit data types, which Cray machines do not provide
#  else
#    error Please define uint32_t as a 32-bit unsigned integer type in brg_types.h
#  endif
#endif

#ifndef AGX_BRG_UI64
#  if defined( __BORLANDC__ ) && !defined( __MSDOS__ )
#    define AGX_BRG_UI64
#    define agx_li_64(h) 0x##h##ui64
#  elif defined( _MSC_VER ) && ( _MSC_VER < 1300 )    /* 1300 == VC++ 7.0 */
#    define AGX_BRG_UI64
#    define agx_li_64(h) 0x##h##ui64
#  elif defined( __sun ) && defined( ULONG_MAX ) && ULONG_MAX == 0xfffffffful
#    define AGX_BRG_UI64
#    define agx_li_64(h) 0x##h##ull
#  elif defined( __MVS__ )
#    define AGX_BRG_UI64
#    define agx_li_64(h) 0x##h##ull
#  elif defined( UINT_MAX ) && UINT_MAX > 4294967295u
#    if UINT_MAX == 18446744073709551615u
#      define AGX_BRG_UI64
#      define agx_li_64(h) 0x##h##u
#    endif
#  elif defined( ULONG_MAX ) && ULONG_MAX > 4294967295u
#    if ULONG_MAX == 18446744073709551615ul
#      define AGX_BRG_UI64
#      define agx_li_64(h) 0x##h##ul
#    endif
#  elif defined( ULLONG_MAX ) && ULLONG_MAX > 4294967295u
#    if ULLONG_MAX == 18446744073709551615ull
#      define AGX_BRG_UI64
#      define agx_li_64(h) 0x##h##ull
#    endif
#  elif defined( ULONG_LONG_MAX ) && ULONG_LONG_MAX > 4294967295u
#    if ULONG_LONG_MAX == 18446744073709551615ull
#      define AGX_BRG_UI64
#      define agx_li_64(h) 0x##h##ull
#    endif
#  endif
#endif

#if !defined( AGX_BRG_UI64 )
#  if defined( NEED_UINT_64T )
#    error Please define uint64_t as an unsigned 64 bit type in brg_types.h
#  endif
#endif

#ifndef AGX_RETURN_VALUES
#  define AGX_RETURN_VALUES
#  if defined( DLL_EXPORT )
#    if defined( _MSC_VER ) || defined ( __INTEL_COMPILER )
#      define AGX_VOID_RETURN    __declspec( dllexport ) void __stdcall
#      define AGX_INT_RETURN     __declspec( dllexport ) int  __stdcall
#    elif defined( __GNUC__ )
#      define AGX_VOID_RETURN    __declspec( __dllexport__ ) void
#      define AGX_INT_RETURN     __declspec( __dllexport__ ) int
#    else
#      error Use of the DLL is only available on the Microsoft, Intel and GCC compilers
#    endif
#  elif defined( DLL_IMPORT )
#    if defined( _MSC_VER ) || defined ( __INTEL_COMPILER )
#      define AGX_VOID_RETURN    __declspec( dllimport ) void __stdcall
#      define AGX_INT_RETURN     __declspec( dllimport ) int  __stdcall
#    elif defined( __GNUC__ )
#      define AGX_VOID_RETURN    __declspec( __dllimport__ ) void
#      define AGX_INT_RETURN     __declspec( __dllimport__ ) int
#    else
#      error Use of the DLL is only available on the Microsoft, Intel and GCC compilers
#    endif
#  elif defined( __WATCOMC__ )
#    define AGX_VOID_RETURN  void __cdecl
#    define AGX_INT_RETURN   int  __cdecl
#  else
#    define AGX_VOID_RETURN  void
#    define AGX_INT_RETURN   int
#  endif
#endif

/*	These defines are used to detect and set the memory alignment of pointers.
    Note that offsets are in bytes.

    ALIGN_OFFSET(x,n)			return the positive or zero offset of 
                                the memory addressed by the pointer 'x' 
                                from an address that is aligned on an 
                                'n' byte boundary ('n' is a power of 2)

    ALIGN_FLOOR(x,n)			return a pointer that points to memory
                                that is aligned on an 'n' byte boundary 
                                and is not higher than the memory address
                                pointed to by 'x' ('n' is a power of 2)

    ALIGN_CEIL(x,n)				return a pointer that points to memory
                                that is aligned on an 'n' byte boundary 
                                and is not lower than the memory address
                                pointed to by 'x' ('n' is a power of 2)
*/

#define AGX_ALIGN_OFFSET(x,n)	(((agx_ptrint_t)(x)) & ((n) - 1))
#define AGX_ALIGN_FLOOR(x,n)	((uint8_t*)(x) - ( ((agx_ptrint_t)(x)) & ((n) - 1)))
#define AGX_ALIGN_CEIL(x,n)		((uint8_t*)(x) + (-((agx_ptrint_t)(x)) & ((n) - 1)))

/*  These defines are used to declare buffers in a way that allows
    faster operations on longer variables to be used.  In all these
    defines 'size' must be a power of 2 and >= 8. NOTE that the 
    buffer size is in bytes but the type length is in bits

    UNIT_TYPEDEF(x,size)        declares a variable 'x' of length 
                                'size' bits

    BUFR_TYPEDEF(x,size,bsize)  declares a buffer 'x' of length 'bsize' 
                                bytes defined as an array of variables
                                each of 'size' bits (bsize must be a 
                                multiple of size / 8)

    UNIT_CAST(x,size)           casts a variable to a type of 
                                length 'size' bits

    UPTR_CAST(x,size)           casts a pointer to a pointer to a 
                                varaiable of length 'size' bits
*/

#define AGX_UI_TYPE(size)               uint##size##_t
#define AGX_UNIT_TYPEDEF(x,size)        typedef AGX_UI_TYPE(size) x
#define AGX_BUFR_TYPEDEF(x,size,bsize)  typedef AGX_UI_TYPE(size) x[bsize / (size >> 3)]
#define AGX_UNIT_CAST(x,size)           ((AGX_UI_TYPE(size) )(x))
#define AGX_UPTR_CAST(x,size)           ((AGX_UI_TYPE(size)*)(x))

#if defined(__cplusplus)
}
#endif

#endif
