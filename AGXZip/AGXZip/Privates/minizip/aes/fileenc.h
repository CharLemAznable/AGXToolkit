//
//  fileenc.h
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
 Copyright (c) 2002, Dr Brian Gladman <                 >, Worcester, UK.
 All rights reserved.

 LICENSE TERMS

 The free distribution and use of this software in both source and binary
 form is allowed (with or without changes) provided that:

   1. distributions of this source code include the above copyright
      notice, this list of conditions and the following disclaimer;

   2. distributions in binary form include the above copyright
      notice, this list of conditions and the following disclaimer
      in the documentation and/or other associated materials;

   3. the copyright holder's name is not used to endorse products
      built using this software without specific written permission.

 ALTERNATIVELY, provided that this notice is retained in full, this product
 may be distributed under the terms of the GNU General Public License (GPL),
 in which case the provisions of the GPL apply INSTEAD OF those given above.

 DISCLAIMER

 This software is provided 'as is' with no explicit or implied warranties
 in respect of its properties, including, but not limited to, correctness
 and/or fitness for purpose.
 ---------------------------------------------------------------------------
 Issue Date: 24/01/2003

 This file contains the header file for fileenc.c, which implements password
 based file encryption and authentication using AES in CTR mode, HMAC-SHA1 
 authentication and RFC2898 password based key derivation.
*/

#ifndef _AGX_FENC_H
#define _AGX_FENC_H

#include "aes.h"
#include "hmac.h"
#include "pwd2key.h"

#define AGX_PASSWORD_VERIFIER

#define AGX_MAX_KEY_LENGTH        32
#define AGX_MAX_PWD_LENGTH       128
#define AGX_MAX_SALT_LENGTH       16
#define AGX_KEYING_ITERATIONS   1000

#ifdef  AGX_PASSWORD_VERIFIER
#define AGX_PWD_VER_LENGTH         2
#else
#define AGX_PWD_VER_LENGTH         0
#endif

#define AGX_GOOD_RETURN            0
#define AGX_PASSWORD_TOO_LONG   -100
#define AGX_BAD_MODE            -101

/*
    Field lengths (in bytes) versus File Encryption Mode (0 < mode < 4)

    Mode Key Salt  MAC Overhead
       1  16    8   10       18
       2  24   12   10       22
       3  32   16   10       26

   The following macros assume that the mode value is correct.
*/

#define AGX_KEY_LENGTH(mode)        (8 * (mode & 3) + 8)
#define AGX_SALT_LENGTH(mode)       (4 * (mode & 3) + 4)
#define AGX_MAC_LENGTH(mode)        (10)

/* the context for file encryption   */

#if defined(__cplusplus)
extern "C"
{
#endif

typedef struct
{   unsigned char       nonce[AGX_AES_BLOCK_SIZE];      /* the CTR nonce          */
    unsigned char       encr_bfr[AGX_AES_BLOCK_SIZE];   /* encrypt buffer         */
    agx_aes_encrypt_ctx encr_ctx[1];                    /* encryption context     */
    agx_hmac_ctx        auth_ctx[1];                    /* authentication context */
    unsigned int        encr_pos;                       /* block position (enc)   */
    unsigned int        pwd_len;                        /* password length        */
    unsigned int        mode;                           /* File encryption mode   */
} agx_fcrypt_ctx;

/* initialise file encryption or decryption */

int agx_fcrypt_init(
    int mode,                               /* the mode to be used (input)          */
    const unsigned char pwd[],              /* the user specified password (input)  */
    unsigned int pwd_len,                   /* the length of the password (input)   */
    const unsigned char salt[],             /* the salt (input)                     */
#ifdef AGX_PASSWORD_VERIFIER
    unsigned char pwd_ver[AGX_PWD_VER_LENGTH],  /* 2 byte password verifier (output)    */
#endif
    agx_fcrypt_ctx      cx[1]);                 /* the file encryption context (output) */

/* perform 'in place' encryption or decryption and authentication               */

void agx_fcrypt_encrypt(unsigned char data[], unsigned int data_len, agx_fcrypt_ctx cx[1]);
void agx_fcrypt_decrypt(unsigned char data[], unsigned int data_len, agx_fcrypt_ctx cx[1]);

/* close encryption/decryption and return the MAC value */
/* the return value is the length of the MAC            */

int agx_fcrypt_end(unsigned char mac[],     /* the MAC value (output)   */
                   agx_fcrypt_ctx cx[1]);   /* the context (input)      */

#if defined(__cplusplus)
}
#endif

#endif
