//
//  fileenc.c
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
 -------------------------------------------------------------------------
 Issue Date: 24/01/2003

 This file implements password based file encryption and authentication 
 using AES in CTR mode, HMAC-SHA1 authentication and RFC2898 password 
 based key derivation.

*/

#include <string.h>

#include "fileenc.h"

#if defined(__cplusplus)
extern "C"
{
#endif

/* subroutine for data encryption/decryption    */
/* this could be speeded up a lot by aligning   */
/* buffers and using 32 bit operations          */

static void agx_encr_data(unsigned char data[], unsigned long d_len, agx_fcrypt_ctx cx[1])
{
    unsigned int i = 0, pos = cx->encr_pos;

    while (i < d_len)
    {
        if (pos == AGX_AES_BLOCK_SIZE)
        {
            unsigned int j = 0;
            /* increment encryption nonce   */
            while (j < 8 && !++cx->nonce[j])
                ++j;
            /* encrypt the nonce to form next xor buffer    */
            agx_aes_encrypt(cx->nonce, cx->encr_bfr, cx->encr_ctx);
            pos = 0;
        }

        data[i++] ^= cx->encr_bfr[pos++];
    }

    cx->encr_pos = pos;
}

int agx_fcrypt_init(
    int mode,                               /* the mode to be used (input)          */
    const unsigned char pwd[],              /* the user specified password (input)  */
    unsigned int pwd_len,                   /* the length of the password (input)   */
    const unsigned char salt[],             /* the salt (input)                     */
#ifdef AGX_PASSWORD_VERIFIER
    unsigned char pwd_ver[AGX_PWD_VER_LENGTH],  /* 2 byte password verifier (output)    */
#endif
    agx_fcrypt_ctx      cx[1])                  /* the file encryption context (output) */
{   unsigned char kbuf[2 * AGX_MAX_KEY_LENGTH + AGX_PWD_VER_LENGTH];

    if (pwd_len > AGX_MAX_PWD_LENGTH)
        return AGX_PASSWORD_TOO_LONG;

    if (mode < 1 || mode > 3)
        return AGX_BAD_MODE;

    cx->mode = mode;
    cx->pwd_len = pwd_len;

    /* derive the encryption and authentication keys and the password verifier   */
    agx_derive_key(pwd, pwd_len, salt, AGX_SALT_LENGTH(mode), AGX_KEYING_ITERATIONS,
                        kbuf, 2 * AGX_KEY_LENGTH(mode) + AGX_PWD_VER_LENGTH);

    /* initialise the encryption nonce and buffer pos   */
    cx->encr_pos = AGX_AES_BLOCK_SIZE;
    /* if we need a random component in the encryption  */
    /* nonce, this is where it would have to be set     */
    memset(cx->nonce, 0, AGX_AES_BLOCK_SIZE * sizeof(unsigned char));

    /* initialise for encryption using key 1            */
    agx_aes_encrypt_key(kbuf, AGX_KEY_LENGTH(mode), cx->encr_ctx);

    /* initialise for authentication using key 2        */
    agx_hmac_sha_begin(AGX_HMAC_SHA1, cx->auth_ctx);
    agx_hmac_sha_key(kbuf + AGX_KEY_LENGTH(mode), AGX_KEY_LENGTH(mode), cx->auth_ctx);

#ifdef PASSWORD_VERIFIER
    memcpy(pwd_ver, kbuf + 2 * AGX_KEY_LENGTH(mode), AGX_PWD_VER_LENGTH);
#endif

    return AGX_GOOD_RETURN;
}

/* perform 'in place' encryption and authentication */

void agx_fcrypt_encrypt(unsigned char data[], unsigned int data_len, agx_fcrypt_ctx cx[1])
{
    agx_encr_data(data, data_len, cx);
    agx_hmac_sha_data(data, data_len, cx->auth_ctx);
}

/* perform 'in place' authentication and decryption */

void agx_fcrypt_decrypt(unsigned char data[], unsigned int data_len, agx_fcrypt_ctx cx[1])
{
    agx_hmac_sha_data(data, data_len, cx->auth_ctx);
    agx_encr_data(data, data_len, cx);
}

/* close encryption/decryption and return the MAC value */

int agx_fcrypt_end(unsigned char mac[], agx_fcrypt_ctx cx[1])
{
    agx_hmac_sha_end(mac, AGX_MAC_LENGTH(cx->mode), cx->auth_ctx);
    return AGX_MAC_LENGTH(cx->mode);    /* return MAC length in bytes   */
}

#if defined(__cplusplus)
}
#endif
