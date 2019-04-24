//
//  ioapi_mem.c
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

/* ioapi_mem.c -- IO base function header for compress/uncompress .zip
   files using zlib + zip or unzip API

   This version of ioapi is designed to access memory rather than files.
   We do use a region of memory to put data in to and take it out of. We do
   not have auto-extending buffers and do not inform anyone else that the
   data has been written. It is really intended for accessing a zip archive
   embedded in an application such that I can write an installer with no
   external files. Creation of archives has not been attempted, although
   parts of the framework are present.

   Based on Unzip ioapi.c version 0.22, May 19th, 2003

   Copyright (C) 2012-2017 Nathan Moinvaziri
     https://github.com/nmoinvaz/minizip
   Copyright (C) 2003 Justin Fletcher
   Copyright (C) 1998-2003 Gilles Vollant
     http://www.winimage.com/zLibDll/minizip.html

   This file is under the same license as the Unzip tool it is distributed
   with.
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zlib.h"
#include "ioapi.h"

#include "ioapi_mem.h"

#ifndef AGX_IOMEM_BUFFERSIZE
#  define AGX_IOMEM_BUFFERSIZE (UINT16_MAX)
#endif

voidpf AGX_ZCALLBACK agx_fopen_mem_func(voidpf opaque, AGX_ZIP_UNUSED const char *filename, int mode)
{
    agx_ourmemory_t *mem = (agx_ourmemory_t *)opaque;
    if (mem == NULL)
        return NULL; /* Mem structure passed in was null */

    if (mode & AGX_ZLIB_FILEFUNC_MODE_CREATE)
    {
        if (mem->grow)
        {
            mem->size = AGX_IOMEM_BUFFERSIZE;
            mem->base = (char *)malloc(mem->size);
        }

        mem->limit = 0; /* When writing we start with 0 bytes written */
    }
    else
        mem->limit = mem->size;

    mem->cur_offset = 0;

    return mem;
}

voidpf AGX_ZCALLBACK agx_fopendisk_mem_func(AGX_ZIP_UNUSED voidpf opaque, AGX_ZIP_UNUSED voidpf stream, AGX_ZIP_UNUSED uint32_t number_disk, AGX_ZIP_UNUSED int mode)
{
    /* Not used */
    return NULL;
}

uint32_t AGX_ZCALLBACK agx_fread_mem_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, void *buf, uint32_t size)
{
    agx_ourmemory_t *mem = (agx_ourmemory_t *)stream;

    if (size > mem->size - mem->cur_offset)
        size = mem->size - mem->cur_offset;

    memcpy(buf, mem->base + mem->cur_offset, size);
    mem->cur_offset += size;

    return size;
}

uint32_t AGX_ZCALLBACK agx_fwrite_mem_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, const void *buf, uint32_t size)
{
    agx_ourmemory_t *mem = (agx_ourmemory_t *)stream;
    uint32_t newmemsize = 0;
    char *newbase = NULL;

    if (size > mem->size - mem->cur_offset)
    {
        if (mem->grow)
        {
            newmemsize = mem->size;
            if (size < AGX_IOMEM_BUFFERSIZE)
                newmemsize += AGX_IOMEM_BUFFERSIZE;
            else
                newmemsize += size;
            newbase = (char *)malloc(newmemsize);
            memcpy(newbase, mem->base, mem->size);
            free(mem->base);
            mem->base = newbase;
            mem->size = newmemsize;
        }
        else
            size = mem->size - mem->cur_offset;
    }
    memcpy(mem->base + mem->cur_offset, buf, size);
    mem->cur_offset += size;
    if (mem->cur_offset > mem->limit)
        mem->limit = mem->cur_offset;

    return size;
}

long AGX_ZCALLBACK agx_ftell_mem_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream)
{
    agx_ourmemory_t *mem = (agx_ourmemory_t *)stream;
    return mem->cur_offset;
}

long AGX_ZCALLBACK agx_fseek_mem_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, uint32_t offset, int origin)
{
    agx_ourmemory_t *mem = (agx_ourmemory_t *)stream;
    uint32_t new_pos = 0;
    switch (origin)
    {
        case AGX_ZLIB_FILEFUNC_SEEK_CUR:
            new_pos = mem->cur_offset + offset;
            break;
        case AGX_ZLIB_FILEFUNC_SEEK_END:
            new_pos = mem->limit + offset;
            break;
        case AGX_ZLIB_FILEFUNC_SEEK_SET:
            new_pos = offset;
            break;
        default:
            return -1;
    }

    if (new_pos > mem->size)
        return 1; /* Failed to seek that far */
    mem->cur_offset = new_pos;
    return 0;
}

int AGX_ZCALLBACK agx_fclose_mem_func(AGX_ZIP_UNUSED voidpf opaque, AGX_ZIP_UNUSED voidpf stream)
{
    /* Even with grow = 1, caller must always free() memory */
    return 0;
}

int AGX_ZCALLBACK agx_ferror_mem_func(AGX_ZIP_UNUSED voidpf opaque, AGX_ZIP_UNUSED voidpf stream)
{
    /* We never return errors */
    return 0;
}

void agx_fill_memory_filefunc(agx_zlib_filefunc_def *pzlib_filefunc_def, agx_ourmemory_t *ourmem)
{
    pzlib_filefunc_def->zopen_file = agx_fopen_mem_func;
    pzlib_filefunc_def->zopendisk_file = agx_fopendisk_mem_func;
    pzlib_filefunc_def->zread_file = agx_fread_mem_func;
    pzlib_filefunc_def->zwrite_file = agx_fwrite_mem_func;
    pzlib_filefunc_def->ztell_file = agx_ftell_mem_func;
    pzlib_filefunc_def->zseek_file = agx_fseek_mem_func;
    pzlib_filefunc_def->zclose_file = agx_fclose_mem_func;
    pzlib_filefunc_def->zerror_file = agx_ferror_mem_func;
    pzlib_filefunc_def->opaque = ourmem;
}
