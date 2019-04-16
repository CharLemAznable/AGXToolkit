//
//  prng.c
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
 ---------------------------------------------------------------------------
 Issue Date: 24/01/2003

 This file implements a random data pool based on the use of an external
 entropy function.  It is based on the ideas advocated by Peter Gutmann in
 his work on pseudo random sequence generators.  It is not a 'paranoid'
 random sequence generator and no attempt is made to protect the pool
 from prying eyes either by memory locking or by techniques to obscure
 its location in memory.
*/

#include <string.h>
#include "prng.h"

#if defined(__cplusplus)
extern "C"
{
#endif

/* mix a random data pool using the SHA1 compression function (as   */
/* suggested by Peter Gutmann in his paper on random pools)         */

static void agx_prng_mix(unsigned char buf[])
{   unsigned int    i, len;
    agx_sha1_ctx    ctx[1];

    /*lint -e{663}  unusual array to pointer conversion */
    for(i = 0; i < AGX_PRNG_POOL_SIZE; i += AGX_SHA1_DIGEST_SIZE)
    {
        /* copy digest size pool block into SHA1 hash block */
        memcpy(ctx->hash, buf + (i ? i : AGX_PRNG_POOL_SIZE)
                            - AGX_SHA1_DIGEST_SIZE, AGX_SHA1_DIGEST_SIZE);

        /* copy data from pool into the SHA1 data buffer    */
        len = AGX_PRNG_POOL_SIZE - i;
        memcpy(ctx->wbuf, buf + i, (len > AGX_SHA1_BLOCK_SIZE ? AGX_SHA1_BLOCK_SIZE : len));

        if(len < AGX_SHA1_BLOCK_SIZE)
            memcpy(((char*)ctx->wbuf) + len, buf, AGX_SHA1_BLOCK_SIZE - len);

        /* compress using the SHA1 compression function     */
        agx_sha1_compile(ctx);

        /* put digest size block back into the random pool  */
        memcpy(buf + i, ctx->hash, AGX_SHA1_DIGEST_SIZE);
    }
}

/* refresh the output buffer and update the random pool by adding   */
/* entropy and remixing                                             */

static void agx_update_pool(agx_prng_ctx ctx[1])
{   unsigned int    i = 0;

    /* transfer random pool data to the output buffer   */
    memcpy(ctx->obuf, ctx->rbuf, AGX_PRNG_POOL_SIZE);

    /* enter entropy data into the pool */
    while(i < AGX_PRNG_POOL_SIZE)
        i += ctx->entropy(ctx->rbuf + i, AGX_PRNG_POOL_SIZE - i);

    /* invert and xor the original pool data into the pool  */
    for(i = 0; i < AGX_PRNG_POOL_SIZE; ++i)
        ctx->rbuf[i] ^= ~ctx->obuf[i];

    /* mix the pool and the output buffer   */
    agx_prng_mix(ctx->rbuf);
    agx_prng_mix(ctx->obuf);
}

void agx_prng_init(agx_prng_entropy_fn fun, agx_prng_ctx ctx[1])
{   int i;

    /* clear the buffers and the counter in the context     */
    memset(ctx, 0, sizeof(agx_prng_ctx));

    /* set the pointer to the entropy collection function   */
    ctx->entropy = fun;

    /* initialise the random data pool                      */
    agx_update_pool(ctx);

    /* mix the pool a minimum number of times               */
    for(i = 0; i < AGX_PRNG_MIN_MIX; ++i)
        agx_prng_mix(ctx->rbuf);

    /* update the pool to prime the pool output buffer      */
    agx_update_pool(ctx);
}

/* provide random bytes from the random data pool   */

void agx_prng_rand(unsigned char data[], unsigned int data_len, agx_prng_ctx ctx[1])
{   unsigned char   *rp = data;
    unsigned int    len, pos = ctx->pos;

    while(data_len)
    {
        /* transfer 'data_len' bytes (or the number of bytes remaining  */
        /* the pool output buffer if less) into the output              */
        len = (data_len < AGX_PRNG_POOL_SIZE - pos ? data_len : AGX_PRNG_POOL_SIZE - pos);
        memcpy(rp, ctx->obuf + pos, len);
        rp += len;          /* update ouput buffer position pointer     */
        pos += len;         /* update pool output buffer pointer        */
        data_len -= len;    /* update the remaining data count          */

        /* refresh the random pool if necessary */
        if(pos == AGX_PRNG_POOL_SIZE)
        {
            agx_update_pool(ctx); pos = 0;
        }
    }

    ctx->pos = pos;
}

void agx_prng_end(agx_prng_ctx ctx[1])
{
    /* ensure the data in the context is destroyed  */
    memset(ctx, 0, sizeof(agx_prng_ctx));
}

#if defined(__cplusplus)
}
#endif

