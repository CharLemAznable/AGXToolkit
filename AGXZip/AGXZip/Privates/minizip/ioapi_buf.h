//
//  ioapi_buf.h
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

/* ioapi_buf.h -- IO base function header for compress/uncompress .zip
   files using zlib + zip or unzip API

   This version of ioapi is designed to buffer IO.

   Copyright (C) 2012-2017 Nathan Moinvaziri
      https://github.com/nmoinvaz/minizip

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/

#ifndef _IOAPI_BUF_H
#define _IOAPI_BUF_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zlib.h"
#include "ioapi.h"

#ifdef __cplusplus
extern "C" {
#endif

voidpf   ZCALLBACK fopen_buf_func(voidpf opaque, const char* filename, int mode);
voidpf   ZCALLBACK fopen64_buf_func(voidpf opaque, const void* filename, int mode);
voidpf   ZCALLBACK fopendisk_buf_func(voidpf opaque, voidpf stream_cd, uint32_t number_disk, int mode);
voidpf   ZCALLBACK fopendisk64_buf_func(voidpf opaque, voidpf stream_cd, uint32_t number_disk, int mode);
uint32_t ZCALLBACK fread_buf_func(voidpf opaque, voidpf stream, void* buf, uint32_t size);
uint32_t ZCALLBACK fwrite_buf_func(voidpf opaque, voidpf stream, const void* buf, uint32_t size);
long     ZCALLBACK ftell_buf_func(voidpf opaque, voidpf stream);
uint64_t ZCALLBACK ftell64_buf_func(voidpf opaque, voidpf stream);
long     ZCALLBACK fseek_buf_func(voidpf opaque, voidpf stream, uint32_t offset, int origin);
long     ZCALLBACK fseek64_buf_func(voidpf opaque, voidpf stream, uint64_t offset, int origin);
int      ZCALLBACK fclose_buf_func(voidpf opaque,voidpf stream);
int      ZCALLBACK ferror_buf_func(voidpf opaque,voidpf stream);

typedef struct ourbuffer_s {
  zlib_filefunc_def   filefunc;
  zlib_filefunc64_def filefunc64;
} ourbuffer_t;

void fill_buffer_filefunc(zlib_filefunc_def* pzlib_filefunc_def, ourbuffer_t *ourbuf);
void fill_buffer_filefunc64(zlib_filefunc64_def* pzlib_filefunc_def, ourbuffer_t *ourbuf);

#ifdef __cplusplus
}
#endif

#endif
