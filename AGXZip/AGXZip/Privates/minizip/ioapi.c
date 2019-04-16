//
//  ioapi.c
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

/* ioapi.c -- IO base function header for compress/uncompress .zip
   part of the MiniZip project

   Copyright (C) 2012-2017 Nathan Moinvaziri
     https://github.com/nmoinvaz/minizip
   Modifications for Zip64 support
     Copyright (C) 2009-2010 Mathias Svensson
     http://result42.com
   Copyright (C) 1998-2010 Gilles Vollant
     http://www.winimage.com/zLibDll/minizip.html

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/

#include <stdlib.h>
#include <string.h>

#if defined unix || defined __APPLE__
#include <sys/types.h>
#include <unistd.h>
#endif

#include "ioapi.h"

#if defined(_WIN32)
#  define agx_snprintf _snprintf
#endif

voidpf agx_call_zopen64(const agx_zlib_filefunc64_32_def *pfilefunc, const void *filename, int mode)
{
    if (pfilefunc->zfile_func64.zopen64_file != NULL)
        return (*(pfilefunc->zfile_func64.zopen64_file)) (pfilefunc->zfile_func64.opaque, filename, mode);
    return (*(pfilefunc->zopen32_file))(pfilefunc->zfile_func64.opaque, (const char*)filename, mode);
}

voidpf agx_call_zopendisk64(const agx_zlib_filefunc64_32_def *pfilefunc, voidpf filestream, uint32_t number_disk, int mode)
{
    if (pfilefunc->zfile_func64.zopendisk64_file != NULL)
        return (*(pfilefunc->zfile_func64.zopendisk64_file)) (pfilefunc->zfile_func64.opaque, filestream, number_disk, mode);
    return (*(pfilefunc->zopendisk32_file))(pfilefunc->zfile_func64.opaque, filestream, number_disk, mode);
}

long agx_call_zseek64(const agx_zlib_filefunc64_32_def *pfilefunc, voidpf filestream, uint64_t offset, int origin)
{
    uint32_t offset_truncated = 0;
    if (pfilefunc->zfile_func64.zseek64_file != NULL)
        return (*(pfilefunc->zfile_func64.zseek64_file)) (pfilefunc->zfile_func64.opaque,filestream,offset,origin);
    offset_truncated = (uint32_t)offset;
    if (offset_truncated != offset)
        return -1;
    return (*(pfilefunc->zseek32_file))(pfilefunc->zfile_func64.opaque,filestream, offset_truncated, origin);
}

uint64_t agx_call_ztell64(const agx_zlib_filefunc64_32_def *pfilefunc, voidpf filestream)
{
    uint64_t position;
    if (pfilefunc->zfile_func64.zseek64_file != NULL)
        return (*(pfilefunc->zfile_func64.ztell64_file)) (pfilefunc->zfile_func64.opaque, filestream);
    position = (*(pfilefunc->ztell32_file))(pfilefunc->zfile_func64.opaque, filestream);
    if ((position) == UINT32_MAX)
        return (uint64_t)-1;
    return position;
}

void agx_fill_zlib_filefunc64_32_def_from_filefunc32(agx_zlib_filefunc64_32_def *p_filefunc64_32, const agx_zlib_filefunc_def *p_filefunc32)
{
    p_filefunc64_32->zfile_func64.zopen64_file = NULL;
    p_filefunc64_32->zfile_func64.zopendisk64_file = NULL;
    p_filefunc64_32->zopen32_file = p_filefunc32->zopen_file;
    p_filefunc64_32->zopendisk32_file = p_filefunc32->zopendisk_file;
    p_filefunc64_32->zfile_func64.zerror_file = p_filefunc32->zerror_file;
    p_filefunc64_32->zfile_func64.zread_file = p_filefunc32->zread_file;
    p_filefunc64_32->zfile_func64.zwrite_file = p_filefunc32->zwrite_file;
    p_filefunc64_32->zfile_func64.ztell64_file = NULL;
    p_filefunc64_32->zfile_func64.zseek64_file = NULL;
    p_filefunc64_32->zfile_func64.zclose_file = p_filefunc32->zclose_file;
    p_filefunc64_32->zfile_func64.zerror_file = p_filefunc32->zerror_file;
    p_filefunc64_32->zfile_func64.opaque = p_filefunc32->opaque;
    p_filefunc64_32->zseek32_file = p_filefunc32->zseek_file;
    p_filefunc64_32->ztell32_file = p_filefunc32->ztell_file;
}

static voidpf   AGX_ZCALLBACK agx_fopen_file_func(AGX_ZIP_UNUSED voidpf opaque, const char *filename, int mode);
static uint32_t AGX_ZCALLBACK agx_fread_file_func(voidpf opaque, voidpf stream, void* buf, uint32_t size);
static uint32_t AGX_ZCALLBACK agx_fwrite_file_func(voidpf opaque, voidpf stream, const void *buf, uint32_t size);
static uint64_t AGX_ZCALLBACK agx_ftell64_file_func(voidpf opaque, voidpf stream);
static long     AGX_ZCALLBACK agx_fseek64_file_func(voidpf opaque, voidpf stream, uint64_t offset, int origin);
static int      AGX_ZCALLBACK agx_fclose_file_func(voidpf opaque, voidpf stream);
static int      AGX_ZCALLBACK agx_ferror_file_func(voidpf opaque, voidpf stream);

typedef struct 
{
    FILE *file;
    int filenameLength;
    void *filename;
} AGX_FILE_IOPOSIX;

static voidpf agx_file_build_ioposix(FILE *file, const char *filename)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    if (file == NULL)
        return NULL;
    ioposix = (AGX_FILE_IOPOSIX*)malloc(sizeof(AGX_FILE_IOPOSIX));
    ioposix->file = file;
    ioposix->filenameLength = (int)strlen(filename) + 1;
    ioposix->filename = (char*)malloc(ioposix->filenameLength * sizeof(char));
    strncpy((char*)ioposix->filename, filename, ioposix->filenameLength);
    return (voidpf)ioposix;
}

static voidpf AGX_ZCALLBACK agx_fopen_file_func(AGX_ZIP_UNUSED voidpf opaque, const char *filename, int mode)
{
    FILE* file = NULL;
    const char *mode_fopen = NULL;
    if ((mode & AGX_ZLIB_FILEFUNC_MODE_READWRITEFILTER) == AGX_ZLIB_FILEFUNC_MODE_READ)
        mode_fopen = "rb";
    else if (mode & AGX_ZLIB_FILEFUNC_MODE_EXISTING)
        mode_fopen = "r+b";
    else if (mode & AGX_ZLIB_FILEFUNC_MODE_CREATE)
        mode_fopen = "wb";

    if ((filename != NULL) && (mode_fopen != NULL))
    {
        file = fopen(filename, mode_fopen);
        return agx_file_build_ioposix(file, filename);
    }
    return file;
}

static voidpf AGX_ZCALLBACK agx_fopen64_file_func(AGX_ZIP_UNUSED voidpf opaque, const void *filename, int mode)
{
    FILE* file = NULL;
    const char *mode_fopen = NULL;
    if ((mode & AGX_ZLIB_FILEFUNC_MODE_READWRITEFILTER) == AGX_ZLIB_FILEFUNC_MODE_READ)
        mode_fopen = "rb";
    else if (mode & AGX_ZLIB_FILEFUNC_MODE_EXISTING)
        mode_fopen = "r+b";
    else if (mode & AGX_ZLIB_FILEFUNC_MODE_CREATE)
        mode_fopen = "wb";

    if ((filename != NULL) && (mode_fopen != NULL))
    {
        file = agx_fopen64((const char*)filename, mode_fopen);
        return agx_file_build_ioposix(file, (const char*)filename);
    }
    return file;
}

static voidpf AGX_ZCALLBACK agx_fopendisk64_file_func(voidpf opaque, voidpf stream, uint32_t number_disk, int mode)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    char *diskFilename = NULL;
    voidpf ret = NULL;
    int i = 0;

    if (stream == NULL)
        return NULL;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    diskFilename = (char*)malloc(ioposix->filenameLength * sizeof(char));
    strncpy(diskFilename, (const char*)ioposix->filename, ioposix->filenameLength);
    for (i = ioposix->filenameLength - 1; i >= 0; i -= 1)
    {
        if (diskFilename[i] != '.')
            continue;
        snprintf(&diskFilename[i], ioposix->filenameLength - i, ".z%02u", number_disk + 1);
        break;
    }
    if (i >= 0)
        ret = agx_fopen64_file_func(opaque, diskFilename, mode);
    free(diskFilename);
    return ret;
}

static voidpf AGX_ZCALLBACK agx_fopendisk_file_func(voidpf opaque, voidpf stream, uint32_t number_disk, int mode)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    char *diskFilename = NULL;
    voidpf ret = NULL;
    int i = 0;

    if (stream == NULL)
        return NULL;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    diskFilename = (char*)malloc(ioposix->filenameLength * sizeof(char));
    strncpy(diskFilename, (const char*)ioposix->filename, ioposix->filenameLength);
    for (i = ioposix->filenameLength - 1; i >= 0; i -= 1)
    {
        if (diskFilename[i] != '.')
            continue;
        snprintf(&diskFilename[i], ioposix->filenameLength - i, ".z%02u", number_disk + 1);
        break;
    }
    if (i >= 0)
        ret = agx_fopen_file_func(opaque, diskFilename, mode);
    free(diskFilename);
    return ret;
}

static uint32_t AGX_ZCALLBACK agx_fread_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, void* buf, uint32_t size)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    uint32_t read = (uint32_t)-1;
    if (stream == NULL)
        return read;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    read = (uint32_t)fread(buf, 1, (size_t)size, ioposix->file);
    return read;
}

static uint32_t AGX_ZCALLBACK agx_fwrite_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, const void *buf, uint32_t size)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    uint32_t written = (uint32_t)-1;
    if (stream == NULL)
        return written;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    written = (uint32_t)fwrite(buf, 1, (size_t)size, ioposix->file);
    return written;
}

static long AGX_ZCALLBACK agx_ftell_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    long ret = -1;
    if (stream == NULL)
        return ret;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    ret = ftell(ioposix->file);
    return ret;
}

static uint64_t AGX_ZCALLBACK agx_ftell64_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    uint64_t ret = (uint64_t)-1;
    if (stream == NULL)
        return ret;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    ret = agx_ftello64(ioposix->file);
    return ret;
}

static long AGX_ZCALLBACK agx_fseek_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, uint32_t offset, int origin)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    int fseek_origin = 0;
    long ret = 0;

    if (stream == NULL)
        return -1;
    ioposix = (AGX_FILE_IOPOSIX*)stream;

    switch (origin)
    {
        case AGX_ZLIB_FILEFUNC_SEEK_CUR:
            fseek_origin = SEEK_CUR;
            break;
        case AGX_ZLIB_FILEFUNC_SEEK_END:
            fseek_origin = SEEK_END;
            break;
        case AGX_ZLIB_FILEFUNC_SEEK_SET:
            fseek_origin = SEEK_SET;
            break;
        default:
            return -1;
    }
    if (fseek(ioposix->file, offset, fseek_origin) != 0)
        ret = -1;
    return ret;
}

static long AGX_ZCALLBACK agx_fseek64_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, uint64_t offset, int origin)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    int fseek_origin = 0;
    long ret = 0;

    if (stream == NULL)
        return -1;
    ioposix = (AGX_FILE_IOPOSIX*)stream;

    switch (origin)
    {
        case AGX_ZLIB_FILEFUNC_SEEK_CUR:
            fseek_origin = SEEK_CUR;
            break;
        case AGX_ZLIB_FILEFUNC_SEEK_END:
            fseek_origin = SEEK_END;
            break;
        case AGX_ZLIB_FILEFUNC_SEEK_SET:
            fseek_origin = SEEK_SET;
            break;
        default:
            return -1;
    }

    if (agx_fseeko64(ioposix->file, offset, fseek_origin) != 0)
        ret = -1;

    return ret;
}

static int AGX_ZCALLBACK agx_fclose_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    int ret = -1;
    if (stream == NULL)
        return ret;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    if (ioposix->filename != NULL)
        free(ioposix->filename);
    ret = fclose(ioposix->file);
    free(ioposix);
    return ret;
}

static int AGX_ZCALLBACK agx_ferror_file_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream)
{
    AGX_FILE_IOPOSIX *ioposix = NULL;
    int ret = -1;
    if (stream == NULL)
        return ret;
    ioposix = (AGX_FILE_IOPOSIX*)stream;
    ret = ferror(ioposix->file);
    return ret;
}

void agx_fill_fopen_filefunc(agx_zlib_filefunc_def *pzlib_filefunc_def)
{
    pzlib_filefunc_def->zopen_file = agx_fopen_file_func;
    pzlib_filefunc_def->zopendisk_file = agx_fopendisk_file_func;
    pzlib_filefunc_def->zread_file = agx_fread_file_func;
    pzlib_filefunc_def->zwrite_file = agx_fwrite_file_func;
    pzlib_filefunc_def->ztell_file = agx_ftell_file_func;
    pzlib_filefunc_def->zseek_file = agx_fseek_file_func;
    pzlib_filefunc_def->zclose_file = agx_fclose_file_func;
    pzlib_filefunc_def->zerror_file = agx_ferror_file_func;
    pzlib_filefunc_def->opaque = NULL;
}

void agx_fill_fopen64_filefunc(agx_zlib_filefunc64_def *pzlib_filefunc_def)
{
    pzlib_filefunc_def->zopen64_file = agx_fopen64_file_func;
    pzlib_filefunc_def->zopendisk64_file = agx_fopendisk64_file_func;
    pzlib_filefunc_def->zread_file = agx_fread_file_func;
    pzlib_filefunc_def->zwrite_file = agx_fwrite_file_func;
    pzlib_filefunc_def->ztell64_file = agx_ftell64_file_func;
    pzlib_filefunc_def->zseek64_file = agx_fseek64_file_func;
    pzlib_filefunc_def->zclose_file = agx_fclose_file_func;
    pzlib_filefunc_def->zerror_file = agx_ferror_file_func;
    pzlib_filefunc_def->opaque = NULL;
}
