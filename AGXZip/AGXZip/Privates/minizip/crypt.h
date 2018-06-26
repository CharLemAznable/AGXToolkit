//
//  crypt.h
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

/* crypt.h -- base code for traditional PKWARE encryption
   Version 1.2.0, September 16th, 2017

   Copyright (C) 2012-2017 Nathan Moinvaziri
     https://github.com/nmoinvaz/minizip
   Copyright (C) 1998-2005 Gilles Vollant
     Modifications for Info-ZIP crypting
     http://www.winimage.com/zLibDll/minizip.html
   Copyright (C) 2003 Terry Thorsen

   This code is a modified version of crypting code in Info-ZIP distribution

   Copyright (C) 1990-2000 Info-ZIP.  All rights reserved.

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/

#ifndef _AGX_MINICRYPT_H
#define _AGX_MINICRYPT_H

#if ZLIB_VERNUM < 0x1270
typedef unsigned long z_crc_t;
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define AGX_RAND_HEAD_LEN  12

/***************************************************************************/

#define agx_zdecode(pkeys,pcrc_32_tab,c) \
    (agx_update_keys(pkeys,pcrc_32_tab, c ^= agx_decrypt_byte(pkeys)))

#define agx_zencode(pkeys,pcrc_32_tab,c,t) \
    (t = agx_decrypt_byte(pkeys), agx_update_keys(pkeys,pcrc_32_tab,c), t^(c))

/***************************************************************************/

/* Return the next byte in the pseudo-random sequence */
uint8_t agx_decrypt_byte(uint32_t *pkeys);

/* Update the encryption keys with the next byte of plain text */
uint8_t agx_update_keys(uint32_t *pkeys, const z_crc_t *pcrc_32_tab, int32_t c);

/* Initialize the encryption keys and the random header according to the given password. */
void agx_init_keys(const char *passwd, uint32_t *pkeys, const z_crc_t *pcrc_32_tab);

/* Generate cryptographically secure random numbers */
int agx_cryptrand(unsigned char *buf, unsigned int len);

/* Create encryption header */
int agx_crypthead(const char *passwd, uint8_t *buf, int buf_size, uint32_t *pkeys,
    const z_crc_t *pcrc_32_tab, uint8_t verify1, uint8_t verify2);

/***************************************************************************/

#ifdef __cplusplus
}
#endif

#endif
