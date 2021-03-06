//
//  ioapi_buf.c
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

/* ioapi_buf.c -- IO base function header for compress/uncompress .zip
   files using zlib + zip or unzip API

   This version of ioapi is designed to buffer IO.

   Copyright (C) 2012-2017 Nathan Moinvaziri
      https://github.com/nmoinvaz/minizip

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "zlib.h"
#include "ioapi.h"

#include "ioapi_buf.h"

#ifndef AGX_IOBUF_BUFFERSIZE
#  define AGX_IOBUF_BUFFERSIZE (UINT16_MAX)
#endif

#if defined(_WIN32)
#  include <conio.h>
#  define AGX_PRINTF  _cprintf
#  define AGX_VPRINTF _vcprintf
#else
#  define AGX_PRINTF  printf
#  define AGX_VPRINTF vprintf
#endif

//#define AGX_IOBUF_VERBOSE

#ifdef __GNUC__
#ifndef agx_max
#define agx_max(x,y) ({ \
const __typeof__(x) _x = (x);	\
const __typeof__(y) _y = (y);	\
(void) (&_x == &_y);		\
_x > _y ? _x : _y; })
#endif /* __GNUC__ */

#ifndef agx_min
#define agx_min(x,y) ({ \
const __typeof__(x) _x = (x);	\
const __typeof__(y) _y = (y);	\
(void) (&_x == &_y);		\
_x < _y ? _x : _y; })
#endif
#endif

typedef struct ourstream_s {
  char      readbuf[AGX_IOBUF_BUFFERSIZE];
  uint32_t  readbuf_len;
  uint32_t  readbuf_pos;
  uint32_t  readbuf_hits;
  uint32_t  readbuf_misses;
  char      writebuf[AGX_IOBUF_BUFFERSIZE];
  uint32_t  writebuf_len;
  uint32_t  writebuf_pos;
  uint32_t  writebuf_hits;
  uint32_t  writebuf_misses;
  uint64_t  position;
  voidpf    stream;
} agx_ourstream_t;

#if defined(AGX_IOBUF_VERBOSE)
#  define agx_print_buf(o,s,f,...) print_buf_internal(o,s,f,__VA_ARGS__);
#else
#  define agx_print_buf(o,s,f,...)
#endif

void agx_print_buf_internal(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, char *format, ...)
{
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    va_list arglist;
    AGX_PRINTF("Buf stream %p - ", streamio);
    va_start(arglist, format);
    AGX_VPRINTF(format, arglist);
    va_end(arglist);
}

voidpf agx_fopen_buf_internal_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, AGX_ZIP_UNUSED uint32_t number_disk, AGX_ZIP_UNUSED int mode)
{
    agx_ourstream_t *streamio = NULL;
    if (stream == NULL)
        return NULL;
    streamio = (agx_ourstream_t *)malloc(sizeof(agx_ourstream_t));
    if (streamio == NULL)
        return NULL;
    memset(streamio, 0, sizeof(agx_ourstream_t));
    streamio->stream = stream;
    agx_print_buf(opaque, streamio, "open [num %d mode %d]\n", number_disk, mode);
    return streamio;
}

voidpf AGX_ZCALLBACK agx_fopen_buf_func(voidpf opaque, const char *filename, int mode)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    voidpf stream = bufio->filefunc.zopen_file(bufio->filefunc.opaque, filename, mode);
    return agx_fopen_buf_internal_func(opaque, stream, 0, mode);
}

voidpf AGX_ZCALLBACK agx_fopen64_buf_func(voidpf opaque, const void *filename, int mode)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    voidpf stream = bufio->filefunc64.zopen64_file(bufio->filefunc64.opaque, filename, mode);
    return agx_fopen_buf_internal_func(opaque, stream, 0, mode);
}

voidpf AGX_ZCALLBACK agx_fopendisk_buf_func(voidpf opaque, voidpf stream_cd, uint32_t number_disk, int mode)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream_cd;
    voidpf *stream = bufio->filefunc.zopendisk_file(bufio->filefunc.opaque, streamio->stream, number_disk, mode);
    return agx_fopen_buf_internal_func(opaque, stream, number_disk, mode);
}

voidpf AGX_ZCALLBACK agx_fopendisk64_buf_func(voidpf opaque, voidpf stream_cd, uint32_t number_disk, int mode)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream_cd;
    voidpf stream = bufio->filefunc64.zopendisk64_file(bufio->filefunc64.opaque, streamio->stream, number_disk, mode);
    return agx_fopen_buf_internal_func(opaque, stream, number_disk, mode);
}

long agx_fflush_buf(voidpf opaque, voidpf stream)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    uint32_t total_bytes_to_write = 0;
    uint32_t bytes_to_write = streamio->writebuf_len;
    uint32_t bytes_left_to_write = streamio->writebuf_len;
    long bytes_written = 0;

    while (bytes_left_to_write > 0)
    {
        if (bufio->filefunc64.zwrite_file != NULL)
            bytes_written = bufio->filefunc64.zwrite_file(bufio->filefunc64.opaque, streamio->stream, streamio->writebuf + (bytes_to_write - bytes_left_to_write), bytes_left_to_write);
        else
            bytes_written = bufio->filefunc.zwrite_file(bufio->filefunc.opaque, streamio->stream, streamio->writebuf + (bytes_to_write - bytes_left_to_write), bytes_left_to_write);

        streamio->writebuf_misses += 1;

        agx_print_buf(opaque, stream, "write flush [%d:%d len %d]\n", bytes_to_write, bytes_left_to_write, streamio->writebuf_len);

        if (bytes_written < 0)
            return bytes_written;

        total_bytes_to_write += bytes_written;
        bytes_left_to_write -= bytes_written;
        streamio->position += bytes_written;
    }
    streamio->writebuf_len = 0;
    streamio->writebuf_pos = 0;
    return total_bytes_to_write;
}

uint32_t AGX_ZCALLBACK agx_fread_buf_func(voidpf opaque, voidpf stream, void *buf, uint32_t size)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    uint32_t buf_len = 0;
    uint32_t bytes_to_read = 0;
    uint32_t bytes_to_copy = 0;
    uint32_t bytes_left_to_read = size;
    uint32_t bytes_read = 0;

    agx_print_buf(opaque, stream, "read [size %ld pos %lld]\n", size, streamio->position);

    if (streamio->writebuf_len > 0)
    {
        agx_print_buf(opaque, stream, "switch from write to read, not yet supported [%lld]\n", streamio->position);
    }

    while (bytes_left_to_read > 0)
    {
        if ((streamio->readbuf_len == 0) || (streamio->readbuf_pos == streamio->readbuf_len))
        {
            if (streamio->readbuf_len == AGX_IOBUF_BUFFERSIZE)
            {
                streamio->readbuf_pos = 0;
                streamio->readbuf_len = 0;
            }

            bytes_to_read = AGX_IOBUF_BUFFERSIZE - (streamio->readbuf_len - streamio->readbuf_pos);

            if (bufio->filefunc64.zread_file != NULL)
                bytes_read = bufio->filefunc64.zread_file(bufio->filefunc64.opaque, streamio->stream, streamio->readbuf + streamio->readbuf_pos, bytes_to_read);
            else
                bytes_read = bufio->filefunc.zread_file(bufio->filefunc.opaque, streamio->stream, streamio->readbuf + streamio->readbuf_pos, bytes_to_read);

            streamio->readbuf_misses += 1;
            streamio->readbuf_len += bytes_read;
            streamio->position += bytes_read;

            agx_print_buf(opaque, stream, "filled [read %d/%d buf %d:%d pos %lld]\n", bytes_read, bytes_to_read, streamio->readbuf_pos, streamio->readbuf_len, streamio->position);

            if (bytes_read == 0)
                break;
        }

        if ((streamio->readbuf_len - streamio->readbuf_pos) > 0)
        {
            bytes_to_copy = agx_min(bytes_left_to_read, (uint32_t)(streamio->readbuf_len - streamio->readbuf_pos));
            memcpy((char *)buf + buf_len, streamio->readbuf + streamio->readbuf_pos, bytes_to_copy);

            buf_len += bytes_to_copy;
            bytes_left_to_read -= bytes_to_copy;

            streamio->readbuf_hits += 1;
            streamio->readbuf_pos += bytes_to_copy;

            agx_print_buf(opaque, stream, "emptied [copied %d remaining %d buf %d:%d pos %lld]\n", bytes_to_copy, bytes_left_to_read, streamio->readbuf_pos, streamio->readbuf_len, streamio->position);
        }
    }

    return size - bytes_left_to_read;
}

uint32_t AGX_ZCALLBACK agx_fwrite_buf_func(voidpf opaque, voidpf stream, const void *buf, uint32_t size)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    uint32_t bytes_to_write = size;
    uint32_t bytes_left_to_write = size;
    uint32_t bytes_to_copy = 0;
    int64_t ret = 0;

    agx_print_buf(opaque, stream, "write [size %ld len %d pos %lld]\n", size, streamio->writebuf_len, streamio->position);

    if (streamio->readbuf_len > 0)
    {
        streamio->position -= streamio->readbuf_len;
        streamio->position += streamio->readbuf_pos;

        streamio->readbuf_len = 0;
        streamio->readbuf_pos = 0;

        agx_print_buf(opaque, stream, "switch from read to write [%lld]\n", streamio->position);

        if (bufio->filefunc64.zseek64_file != NULL)
            ret = bufio->filefunc64.zseek64_file(bufio->filefunc64.opaque, streamio->stream, streamio->position, AGX_ZLIB_FILEFUNC_SEEK_SET);
        else
            ret = bufio->filefunc.zseek_file(bufio->filefunc.opaque, streamio->stream, (uint32_t)streamio->position, AGX_ZLIB_FILEFUNC_SEEK_SET);

        if (ret != 0)
            return (uint32_t)-1;
    }

    while (bytes_left_to_write > 0)
    {
        bytes_to_copy = agx_min(bytes_left_to_write, (uint32_t)(AGX_IOBUF_BUFFERSIZE - agx_min(streamio->writebuf_len, streamio->writebuf_pos)));

        if (bytes_to_copy == 0)
        {
            if (agx_fflush_buf(opaque, stream) <= 0)
                return 0;

            continue;
        }

        memcpy(streamio->writebuf + streamio->writebuf_pos, (char *)buf + (bytes_to_write - bytes_left_to_write), bytes_to_copy);

        agx_print_buf(opaque, stream, "write copy [remaining %d write %d:%d len %d]\n", bytes_to_copy, bytes_to_write, bytes_left_to_write, streamio->writebuf_len);

        bytes_left_to_write -= bytes_to_copy;

        streamio->writebuf_pos += bytes_to_copy;
        streamio->writebuf_hits += 1;
        if (streamio->writebuf_pos > streamio->writebuf_len)
            streamio->writebuf_len += streamio->writebuf_pos - streamio->writebuf_len;
    }

    return size - bytes_left_to_write;
}

uint64_t agx_ftell_buf_internal_func(AGX_ZIP_UNUSED voidpf opaque, voidpf stream, uint64_t position)
{
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    streamio->position = position;
    agx_print_buf(opaque, stream, "tell [pos %llu readpos %d writepos %d err %d]\n", streamio->position, streamio->readbuf_pos, streamio->writebuf_pos, errno);
    if (streamio->readbuf_len > 0)
        position -= (streamio->readbuf_len - streamio->readbuf_pos);
    if (streamio->writebuf_len > 0)
        position += streamio->writebuf_pos;
    return position;
}

long AGX_ZCALLBACK agx_ftell_buf_func(voidpf opaque, voidpf stream)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    uint64_t position = bufio->filefunc.ztell_file(bufio->filefunc.opaque, streamio->stream);
    return (long)agx_ftell_buf_internal_func(opaque, stream, position);
}

uint64_t AGX_ZCALLBACK agx_ftell64_buf_func(voidpf opaque, voidpf stream)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    uint64_t position = bufio->filefunc64.ztell64_file(bufio->filefunc64.opaque, streamio->stream);
    return agx_ftell_buf_internal_func(opaque, stream, position);
}

int agx_fseek_buf_internal_func(voidpf opaque, voidpf stream, uint64_t offset, int origin)
{
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;

    agx_print_buf(opaque, stream, "seek [origin %d offset %llu pos %lld]\n", origin, offset, streamio->position);

    switch (origin)
    {
        case AGX_ZLIB_FILEFUNC_SEEK_SET:

            if (streamio->writebuf_len > 0)
            {
                if ((offset >= streamio->position) && (offset <= streamio->position + streamio->writebuf_len))
                {
                    streamio->writebuf_pos = (uint32_t)(offset - streamio->position);
                    return 0;
                }
            }
            if ((streamio->readbuf_len > 0) && (offset < streamio->position) && (offset >= streamio->position - streamio->readbuf_len))
            {
                streamio->readbuf_pos = (uint32_t)(offset - (streamio->position - streamio->readbuf_len));
                return 0;
            }
            if (agx_fflush_buf(opaque, stream) < 0)
                return -1;
            streamio->position = offset;
            break;

        case AGX_ZLIB_FILEFUNC_SEEK_CUR:

            if (streamio->readbuf_len > 0)
            {
                if (offset <= (streamio->readbuf_len - streamio->readbuf_pos))
                {
                    streamio->readbuf_pos += (uint32_t)offset;
                    return 0;
                }
                offset -= (streamio->readbuf_len - streamio->readbuf_pos);
                streamio->position += offset;
            }
            if (streamio->writebuf_len > 0)
            {
                if (offset <= (streamio->writebuf_len - streamio->writebuf_pos))
                {
                    streamio->writebuf_pos += (uint32_t)offset;
                    return 0;
                }
                //offset -= (streamio->writebuf_len - streamio->writebuf_pos);
            }

            if (agx_fflush_buf(opaque, stream) < 0)
                return -1;

            break;

        case AGX_ZLIB_FILEFUNC_SEEK_END:

            if (streamio->writebuf_len > 0)
            {
                streamio->writebuf_pos = streamio->writebuf_len;
                return 0;
            }
            break;
    }

    streamio->readbuf_len = 0;
    streamio->readbuf_pos = 0;
    streamio->writebuf_len = 0;
    streamio->writebuf_pos = 0;
    return 1;
}

long AGX_ZCALLBACK agx_fseek_buf_func(voidpf opaque, voidpf stream, uint32_t offset, int origin)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    long ret = -1;
    if (bufio->filefunc.zseek_file == NULL)
        return ret;
    ret = agx_fseek_buf_internal_func(opaque, stream, offset, origin);
    if (ret == 1)
        ret = bufio->filefunc.zseek_file(bufio->filefunc.opaque, streamio->stream, offset, origin);
    return ret;
}

long AGX_ZCALLBACK agx_fseek64_buf_func(voidpf opaque, voidpf stream, uint64_t offset, int origin)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    long ret = -1;
    if (bufio->filefunc64.zseek64_file == NULL)
        return ret;
    ret = agx_fseek_buf_internal_func(opaque, stream, offset, origin);
    if (ret == 1)
        ret = bufio->filefunc64.zseek64_file(bufio->filefunc64.opaque, streamio->stream, offset, origin);
    return ret;
}

int AGX_ZCALLBACK agx_fclose_buf_func(voidpf opaque, voidpf stream)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    int ret = 0;
    agx_fflush_buf(opaque, stream);
    agx_print_buf(opaque, stream, "close\n");
    if (streamio->readbuf_hits + streamio->readbuf_misses > 0)
        agx_print_buf(opaque, stream, "read efficency %.02f%%\n", (streamio->readbuf_hits / ((float)streamio->readbuf_hits + streamio->readbuf_misses)) * 100);
    if (streamio->writebuf_hits + streamio->writebuf_misses > 0)
        agx_print_buf(opaque, stream, "write efficency %.02f%%\n", (streamio->writebuf_hits / ((float)streamio->writebuf_hits + streamio->writebuf_misses)) * 100);
    if (bufio->filefunc64.zclose_file != NULL)
        ret = bufio->filefunc64.zclose_file(bufio->filefunc64.opaque, streamio->stream);
    else
        ret = bufio->filefunc.zclose_file(bufio->filefunc.opaque, streamio->stream);
    free(streamio);
    return ret;
}

int AGX_ZCALLBACK agx_ferror_buf_func(voidpf opaque, voidpf stream)
{
    agx_ourbuffer_t *bufio = (agx_ourbuffer_t *)opaque;
    agx_ourstream_t *streamio = (agx_ourstream_t *)stream;
    if (bufio->filefunc64.zerror_file != NULL)
        return bufio->filefunc64.zerror_file(bufio->filefunc64.opaque, streamio->stream);
    return bufio->filefunc.zerror_file(bufio->filefunc.opaque, streamio->stream);
}

void agx_fill_buffer_filefunc(agx_zlib_filefunc_def *pzlib_filefunc_def, agx_ourbuffer_t *ourbuf)
{
    pzlib_filefunc_def->zopen_file = agx_fopen_buf_func;
    pzlib_filefunc_def->zopendisk_file = agx_fopendisk_buf_func;
    pzlib_filefunc_def->zread_file = agx_fread_buf_func;
    pzlib_filefunc_def->zwrite_file = agx_fwrite_buf_func;
    pzlib_filefunc_def->ztell_file = agx_ftell_buf_func;
    pzlib_filefunc_def->zseek_file = agx_fseek_buf_func;
    pzlib_filefunc_def->zclose_file = agx_fclose_buf_func;
    pzlib_filefunc_def->zerror_file = agx_ferror_buf_func;
    pzlib_filefunc_def->opaque = ourbuf;
}

void agx_fill_buffer_filefunc64(agx_zlib_filefunc64_def *pzlib_filefunc_def, agx_ourbuffer_t *ourbuf)
{
    pzlib_filefunc_def->zopen64_file = agx_fopen64_buf_func;
    pzlib_filefunc_def->zopendisk64_file = agx_fopendisk64_buf_func;
    pzlib_filefunc_def->zread_file = agx_fread_buf_func;
    pzlib_filefunc_def->zwrite_file = agx_fwrite_buf_func;
    pzlib_filefunc_def->ztell64_file = agx_ftell64_buf_func;
    pzlib_filefunc_def->zseek64_file = agx_fseek64_buf_func;
    pzlib_filefunc_def->zclose_file = agx_fclose_buf_func;
    pzlib_filefunc_def->zerror_file = agx_ferror_buf_func;
    pzlib_filefunc_def->opaque = ourbuf;
}
