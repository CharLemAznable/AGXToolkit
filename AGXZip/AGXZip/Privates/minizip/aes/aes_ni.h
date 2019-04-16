//
//  aes_ni.h
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
Issue Date: 13/11/2013
*/

#ifndef AGX_AES_NI_H
#define AGX_AES_NI_H

#define AGX_USE_AES_CONTEXT

#include "aesopt.h"

#if defined( AGX_USE_INTEL_AES_IF_PRESENT )

/* map names in C code to make them internal ('name' -> 'agx_aes_name_i') */
#define agx_aes_xi(x) agx_aes_ ## x ## _i

/* map names here to provide the external API ('name' -> 'agx_aes_name') */
#define agx_aes_ni(x) agx_aes_ ## x

AGX_AES_RETURN agx_aes_ni(encrypt_key128)(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_ni(encrypt_key192)(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_ni(encrypt_key256)(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_ni(decrypt_key128)(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_ni(decrypt_key192)(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_ni(decrypt_key256)(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_ni(encrypt)(const unsigned char *in, unsigned char *out, const agx_aes_encrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_ni(decrypt)(const unsigned char *in, unsigned char *out, const agx_aes_decrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_xi(encrypt_key128)(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_xi(encrypt_key192)(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_xi(encrypt_key256)(const unsigned char *key, agx_aes_encrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_xi(decrypt_key128)(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_xi(decrypt_key192)(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_xi(decrypt_key256)(const unsigned char *key, agx_aes_decrypt_ctx cx[1]);

AGX_AES_RETURN agx_aes_xi(encrypt)(const unsigned char *in, unsigned char *out, const agx_aes_encrypt_ctx cx[1]);
AGX_AES_RETURN agx_aes_xi(decrypt)(const unsigned char *in, unsigned char *out, const agx_aes_decrypt_ctx cx[1]);

#endif

#endif
