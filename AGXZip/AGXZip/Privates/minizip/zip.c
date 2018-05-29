//
//  zip.c
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

/* zip.c -- IO on .zip files using zlib
   Version 1.2.0, September 16th, 2017
   part of the MiniZip project

   Copyright (C) 2010-2017 Nathan Moinvaziri
     Modifications for AES, PKWARE disk spanning
     https://github.com/nmoinvaz/minizip
   Copyright (C) 2009-2010 Mathias Svensson
     Modifications for Zip64 support
     http://result42.com
   Copyright (C) 1998-2010 Gilles Vollant
     http://www.winimage.com/zLibDll/minizip.html

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

#include "zlib.h"
#include "zip.h"

#ifdef AGX_HAVE_AES
#  define AGX_AES_METHOD          (99)
#  define AGX_AES_PWVERIFYSIZE    (2)
#  define AGX_AES_AUTHCODESIZE    (10)
#  define AGX_AES_MAXSALTLENGTH   (16)
#  define AGX_AES_VERSION         (0x0001)
#  define AGX_AES_ENCRYPTIONMODE  (0x03)

#  include "aes/aes.h"
#  include "aes/fileenc.h"
#  include "aes/prng.h"
#endif
#ifdef HAVE_APPLE_COMPRESSION
#  include <compression.h>
#endif

#ifndef NOCRYPT
#  include "crypt.h"
#endif

#define AGX_SIZEDATA_INDATABLOCK        (4096-(4*4))

#define AGX_DISKHEADERMAGIC             (0x08074b50)
#define AGX_LOCALHEADERMAGIC            (0x04034b50)
#define AGX_CENTRALHEADERMAGIC          (0x02014b50)
#define AGX_ENDHEADERMAGIC              (0x06054b50)
#define AGX_ZIP64ENDHEADERMAGIC         (0x06064b50)
#define AGX_ZIP64ENDLOCHEADERMAGIC      (0x07064b50)
#define AGX_DATADESCRIPTORMAGIC         (0x08074b50)

#define AGX_FLAG_LOCALHEADER_OFFSET     (0x06)
#define AGX_CRC_LOCALHEADER_OFFSET      (0x0e)

#define AGX_SIZECENTRALHEADER           (0x2e) /* 46 */
#define AGX_SIZECENTRALHEADERLOCATOR    (0x14) /* 20 */
#define AGX_SIZECENTRALDIRITEM          (0x2e)
#define AGX_SIZEZIPLOCALHEADER          (0x1e)

#ifndef AGX_BUFREADCOMMENT
#  define AGX_BUFREADCOMMENT            (0x400)
#endif
#ifndef AGX_VERSIONMADEBY
#  define AGX_VERSIONMADEBY             (0x0) /* platform dependent */
#endif

#ifndef AGX_Z_BUFSIZE
#  define AGX_Z_BUFSIZE                 (UINT16_MAX)
#endif

#ifndef AGX_ALLOC
#  define AGX_ALLOC(size) (malloc(size))
#endif
#ifndef AGX_TRYFREE
#  define AGX_TRYFREE(p) {if (p) free(p);}
#endif

/* NOT sure that this work on ALL platform */
#define AGX_MAKEULONG64(a, b) ((uint64_t)(((unsigned long)(a)) | ((uint64_t)((unsigned long)(b))) << 32))

#ifndef AGX_DEF_MEM_LEVEL
#  if MAX_MEM_LEVEL >= 8
#    define AGX_DEF_MEM_LEVEL 8
#  else
#    define AGX_DEF_MEM_LEVEL  MAX_MEM_LEVEL
#  endif
#endif

const char agx_zip_copyright[] = " zip 1.01 Copyright 1998-2004 Gilles Vollant - http://www.winimage.com/zLibDll";

typedef struct linkedlist_datablock_internal_s
{
    struct linkedlist_datablock_internal_s *next_datablock;
    uint32_t    avail_in_this_block;
    uint32_t    filled_in_this_block;
    uint32_t    unused; /* for future use and alignment */
    uint8_t     data[AGX_SIZEDATA_INDATABLOCK];
} agx_linkedlist_datablock_internal;

typedef struct linkedlist_data_s
{
    agx_linkedlist_datablock_internal *first_block;
    agx_linkedlist_datablock_internal *last_block;
} agx_linkedlist_data;

typedef struct
{
    z_stream stream;                /* zLib stream structure for inflate */
#ifdef HAVE_BZIP2
    bz_stream bstream;              /* bzLib stream structure for bziped */
#endif
#ifdef HAVE_APPLE_COMPRESSION
    compression_stream astream;     /* libcompression stream structure */
#endif
#ifdef AGX_HAVE_AES
    agx_fcrypt_ctx aes_ctx;
    agx_prng_ctx aes_rng[1];
#endif
    int      stream_initialised;    /* 1 is stream is initialized */
    uint32_t pos_in_buffered_data;  /* last written byte in buffered_data */

    uint64_t pos_local_header;      /* offset of the local header of the file currently writing */
    char    *central_header;        /* central header data for the current file */
    uint16_t size_centralextra;
    uint16_t size_centralheader;    /* size of the central header for cur file */
    uint16_t size_centralextrafree; /* Extra bytes allocated to the central header but that are not used */
    uint16_t size_comment;
    uint16_t flag;                  /* flag of the file currently writing */

    uint16_t method;                /* compression method written to file.*/
    uint16_t compression_method;    /* compression method to use */
    int      raw;                   /* 1 for directly writing raw data */
    uint8_t  buffered_data[AGX_Z_BUFSIZE];  /* buffer contain compressed data to be writ*/
    uint32_t dos_date;
    uint32_t crc32;
    int      zip64;                 /* add ZIP64 extended information in the extra field */
    uint32_t number_disk;           /* number of current disk used for spanning ZIP */
    uint64_t total_compressed;
    uint64_t total_uncompressed;
#ifndef NOCRYPT
    uint32_t keys[3];          /* keys defining the pseudo-random sequence */
    const z_crc_t *pcrc_32_tab;
#endif
} agx_curfile64_info;

typedef struct
{
    agx_zlib_filefunc64_32_def z_filefunc;
    voidpf filestream;              /* io structure of the zipfile */
    voidpf filestream_with_CD;      /* io structure of the zipfile with the central dir */
    agx_linkedlist_data central_dir;    /* datablock with central dir in construction*/
    int in_opened_file_inzip;       /* 1 if a file in the zip is currently writ.*/
    int append;                     /* append mode */
    agx_curfile64_info ci;              /* info on the file currently writing */

    uint64_t add_position_when_writting_offset;
    uint64_t number_entry;
    uint64_t disk_size;             /* size of each disk */
    uint32_t number_disk;           /* number of the current disk, used for spanning ZIP */
    uint32_t number_disk_with_CD;   /* number the the disk with central dir, used for spanning ZIP */
#ifndef NO_ADDFILEINEXISTINGZIP
    char *globalcomment;
#endif
} agx_zip64_internal;

/* Allocate a new data block */
static agx_linkedlist_datablock_internal *agx_allocate_new_datablock(void)
{
    agx_linkedlist_datablock_internal *ldi = NULL;

    ldi = (agx_linkedlist_datablock_internal*)AGX_ALLOC(sizeof(agx_linkedlist_datablock_internal));

    if (ldi != NULL)
    {
        ldi->next_datablock = NULL;
        ldi->filled_in_this_block = 0;
        ldi->avail_in_this_block = AGX_SIZEDATA_INDATABLOCK;
    }
    return ldi;
}

/* Free data block in linked list */
static void agx_free_datablock(agx_linkedlist_datablock_internal *ldi)
{
    while (ldi != NULL)
    {
        agx_linkedlist_datablock_internal *ldinext = ldi->next_datablock;
        AGX_TRYFREE(ldi);
        ldi = ldinext;
    }
}

/* Initialize linked list */
static void agx_init_linkedlist(agx_linkedlist_data *ll)
{
    ll->first_block = ll->last_block = NULL;
}

/* Free entire linked list and all data blocks */
static void agx_free_linkedlist(agx_linkedlist_data *ll)
{
    agx_free_datablock(ll->first_block);
    ll->first_block = ll->last_block = NULL;
}

/* Add data to linked list data block */
static int agx_add_data_in_datablock(agx_linkedlist_data *ll, const void *buf, uint32_t len)
{
    agx_linkedlist_datablock_internal *ldi = NULL;
    const unsigned char *from_copy = NULL;

    if (ll == NULL)
        return AGX_ZIP_INTERNALERROR;

    if (ll->last_block == NULL)
    {
        ll->first_block = ll->last_block = agx_allocate_new_datablock();
        if (ll->first_block == NULL)
            return AGX_ZIP_INTERNALERROR;
    }

    ldi = ll->last_block;
    from_copy = (unsigned char*)buf;

    while (len > 0)
    {
        uint32_t copy_this = 0;
        uint32_t i = 0;
        unsigned char *to_copy = NULL;

        if (ldi->avail_in_this_block == 0)
        {
            ldi->next_datablock = agx_allocate_new_datablock();
            if (ldi->next_datablock == NULL)
                return AGX_ZIP_INTERNALERROR;
            ldi = ldi->next_datablock ;
            ll->last_block = ldi;
        }

        if (ldi->avail_in_this_block < len)
            copy_this = ldi->avail_in_this_block;
        else
            copy_this = len;

        to_copy = &(ldi->data[ldi->filled_in_this_block]);

        for (i = 0; i < copy_this; i++)
            *(to_copy+i) = *(from_copy+i);

        ldi->filled_in_this_block += copy_this;
        ldi->avail_in_this_block -= copy_this;
        from_copy += copy_this;
        len -= copy_this;
    }
    return AGX_ZIP_OK;
}

/* Inputs a long in LSB order to the given file: nbByte == 1, 2, 4 or 8 (byte, short or long, uint64_t) */
static int agx_zipWriteValue(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream,
    uint64_t x, uint32_t len)
{
    unsigned char buf[8];
    uint32_t n = 0;

    for (n = 0; n < len; n++)
    {
        buf[n] = (unsigned char)(x & 0xff);
        x >>= 8;
    }

    if (x != 0)
    {
        /* Data overflow - hack for ZIP64 (X Roche) */
        for (n = 0; n < len; n++)
        {
            buf[n] = 0xff;
        }
    }

    if (AGX_ZWRITE64(*pzlib_filefunc_def, filestream, buf, len) != len)
        return AGX_ZIP_ERRNO;

    return AGX_ZIP_OK;
}

static void agx_zipWriteValueToMemory(void* dest, uint64_t x, uint32_t len)
{
    unsigned char *buf = (unsigned char*)dest;
    uint32_t n = 0;

    for (n = 0; n < len; n++)
    {
        buf[n] = (unsigned char)(x & 0xff);
        x >>= 8;
    }

    if (x != 0)
    {
       /* data overflow - hack for ZIP64 */
       for (n = 0; n < len; n++)
       {
          buf[n] = 0xff;
       }
    }
}

static void agx_zipWriteValueToMemoryAndMove(unsigned char **dest_ptr, uint64_t x, uint32_t len)
{
    agx_zipWriteValueToMemory(*dest_ptr, x, len);
    *dest_ptr += len;
}

static int agx_zipReadUInt8(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream, uint8_t *value)
{
    uint8_t c = 0;
    if (AGX_ZREAD64(*pzlib_filefunc_def, filestream, &c, 1) == 1)
    {
        *value = (uint8_t)c;
        return AGX_ZIP_OK;
    }
    if (AGX_ZERROR64(*pzlib_filefunc_def, filestream))
        return AGX_ZIP_ERRNO;
    return AGX_ZIP_EOF;
}

static int agx_zipReadUInt16(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream, uint16_t *value)
{
    uint16_t x = 0;
    uint8_t c = 0;
    int err = AGX_ZIP_OK;

    err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x = (uint16_t)c;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint16_t)c) << 8;

    if (err == AGX_ZIP_OK)
        *value = x;
    else
        *value = 0;
    return err;
}

static int agx_zipReadUInt32(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream, uint32_t *value)
{
    uint32_t x = 0;
    uint8_t c = 0;
    int err = AGX_ZIP_OK;

    err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x = (uint32_t)c;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint32_t)c) << 8;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint32_t)c) << 16;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint32_t)c) << 24;

    if (err == AGX_ZIP_OK)
        *value = x;
    else
        *value = 0;
    return err;
}

static int agx_zipReadUInt64(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream, uint64_t *value)
{
    uint64_t x = 0;
    uint8_t c = 0;
    int err = AGX_ZIP_OK;

    err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x = (uint64_t)c;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 8;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 16;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 24;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 32;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 40;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 48;
    if (err == AGX_ZIP_OK)
        err = agx_zipReadUInt8(pzlib_filefunc_def, filestream, &c);
    x += ((uint64_t)c) << 56;

    if (err == AGX_ZIP_OK)
        *value = x;
    else
        *value = 0;

    return err;
}

/* Gets the amount of bytes left to write to the current disk for spanning archives */
static void agx_zipGetDiskSizeAvailable(agx_zipFile file, uint64_t *size_available)
{
    agx_zip64_internal *zi = NULL;
    uint64_t current_disk_size = 0;

    zi = (agx_zip64_internal*)file;
    AGX_ZSEEK64(zi->z_filefunc, zi->filestream, 0, AGX_ZLIB_FILEFUNC_SEEK_END);
    current_disk_size = AGX_ZTELL64(zi->z_filefunc, zi->filestream);
    *size_available = zi->disk_size - current_disk_size;
}

/* Goes to a specific disk number for spanning archives */
static int agx_zipGoToSpecificDisk(agx_zipFile file, uint32_t number_disk, int open_existing)
{
    agx_zip64_internal *zi = NULL;
    int err = AGX_ZIP_OK;

    zi = (agx_zip64_internal*)file;
    if (zi->disk_size == 0)
        return err;

    if ((zi->filestream != NULL) && (zi->filestream != zi->filestream_with_CD))
        AGX_ZCLOSE64(zi->z_filefunc, zi->filestream);

    zi->filestream = AGX_ZOPENDISK64(zi->z_filefunc, zi->filestream_with_CD, number_disk, (open_existing == 1) ?
            (AGX_ZLIB_FILEFUNC_MODE_READ | AGX_ZLIB_FILEFUNC_MODE_WRITE | AGX_ZLIB_FILEFUNC_MODE_EXISTING) :
            (AGX_ZLIB_FILEFUNC_MODE_READ | AGX_ZLIB_FILEFUNC_MODE_WRITE | AGX_ZLIB_FILEFUNC_MODE_CREATE));

    if (zi->filestream == NULL)
        err = AGX_ZIP_ERRNO;

    return err;
}

/* Goes to the first disk in a spanned archive */
static int agx_zipGoToFirstDisk(agx_zipFile file)
{
    agx_zip64_internal *zi = NULL;
    uint32_t number_disk_next = 0;
    int err = AGX_ZIP_OK;

    zi = (agx_zip64_internal*)file;

    if (zi->disk_size == 0)
        return err;
    number_disk_next = 0;
    if (zi->number_disk_with_CD > 0)
        number_disk_next = zi->number_disk_with_CD - 1;
    err = agx_zipGoToSpecificDisk(file, number_disk_next, (zi->append == AGX_APPEND_STATUS_ADDINZIP));
    if ((err == AGX_ZIP_ERRNO) && (zi->append == AGX_APPEND_STATUS_ADDINZIP))
        err = agx_zipGoToSpecificDisk(file, number_disk_next, 0);
    if (err == AGX_ZIP_OK)
        zi->number_disk = number_disk_next;
    AGX_ZSEEK64(zi->z_filefunc, zi->filestream, 0, AGX_ZLIB_FILEFUNC_SEEK_END);
    return err;
}

/* Goes to the next disk in a spanned archive */
static int agx_zipGoToNextDisk(agx_zipFile file)
{
    agx_zip64_internal *zi = NULL;
    uint64_t size_available_in_disk = 0;
    uint32_t number_disk_next = 0;
    int err = AGX_ZIP_OK;

    zi = (agx_zip64_internal*)file;
    if (zi->disk_size == 0)
        return err;

    number_disk_next = zi->number_disk + 1;

    do
    {
        err = agx_zipGoToSpecificDisk(file, number_disk_next, (zi->append == AGX_APPEND_STATUS_ADDINZIP));
        if ((err == AGX_ZIP_ERRNO) && (zi->append == AGX_APPEND_STATUS_ADDINZIP))
            err = agx_zipGoToSpecificDisk(file, number_disk_next, 0);
        if (err != AGX_ZIP_OK)
            break;
        agx_zipGetDiskSizeAvailable(file, &size_available_in_disk);
        zi->number_disk = number_disk_next;
        zi->number_disk_with_CD = zi->number_disk + 1;

        number_disk_next += 1;
    }
    while (size_available_in_disk <= 0);

    return err;
}

/* Locate the Central directory of a zipfile (at the end, just before the global comment) */
static uint64_t agx_zipSearchCentralDir(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream)
{
    unsigned char *buf = NULL;
    uint64_t file_size = 0;
    uint64_t back_read = 4;
    uint64_t max_back = UINT16_MAX; /* maximum size of global comment */
    uint64_t pos_found = 0;
    uint32_t read_size = 0;
    uint64_t read_pos = 0;
    uint32_t i = 0;

    buf = (unsigned char*)AGX_ALLOC(AGX_BUFREADCOMMENT+4);
    if (buf == NULL)
        return 0;

    if (AGX_ZSEEK64(*pzlib_filefunc_def, filestream, 0, AGX_ZLIB_FILEFUNC_SEEK_END) != 0)
    {
        AGX_TRYFREE(buf);
        return 0;
    }

    file_size = AGX_ZTELL64(*pzlib_filefunc_def, filestream);

    if (max_back > file_size)
        max_back = file_size;

    while (back_read < max_back)
    {
        if (back_read + AGX_BUFREADCOMMENT > max_back)
            back_read = max_back;
        else
            back_read += AGX_BUFREADCOMMENT;

        read_pos = file_size-back_read;
        read_size = ((AGX_BUFREADCOMMENT+4) < (file_size - read_pos)) ?
                     (AGX_BUFREADCOMMENT+4) : (uint32_t)(file_size - read_pos);

        if (AGX_ZSEEK64(*pzlib_filefunc_def, filestream, read_pos, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
            break;
        if (AGX_ZREAD64(*pzlib_filefunc_def, filestream, buf, read_size) != read_size)
            break;

        for (i = read_size-3; (i--) > 0;)
            if ((*(buf+i)) == (AGX_ENDHEADERMAGIC & 0xff) &&
                (*(buf+i+1)) == (AGX_ENDHEADERMAGIC >> 8 & 0xff) &&
                (*(buf+i+2)) == (AGX_ENDHEADERMAGIC >> 16 & 0xff) &&
                (*(buf+i+3)) == (AGX_ENDHEADERMAGIC >> 24 & 0xff))
            {
                pos_found = read_pos+i;
                break;
            }

        if (pos_found != 0)
            break;
    }
    AGX_TRYFREE(buf);
    return pos_found;
}

/* Locate the Central directory 64 of a zipfile (at the end, just before the global comment) */
static uint64_t agx_zipSearchCentralDir64(const agx_zlib_filefunc64_32_def *pzlib_filefunc_def, voidpf filestream,
    const uint64_t endcentraloffset)
{
    uint64_t offset = 0;
    uint32_t value32 = 0;

    /* Zip64 end of central directory locator */
    if (AGX_ZSEEK64(*pzlib_filefunc_def, filestream, endcentraloffset - AGX_SIZECENTRALHEADERLOCATOR, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
        return 0;

    /* Read locator signature */
    if (agx_zipReadUInt32(pzlib_filefunc_def, filestream, &value32) != AGX_ZIP_OK)
        return 0;
    if (value32 != AGX_ZIP64ENDLOCHEADERMAGIC)
        return 0;
    /* Number of the disk with the start of the zip64 end of  central directory */
    if (agx_zipReadUInt32(pzlib_filefunc_def, filestream, &value32) != AGX_ZIP_OK)
        return 0;
    /* Relative offset of the zip64 end of central directory record */
    if (agx_zipReadUInt64(pzlib_filefunc_def, filestream, &offset) != AGX_ZIP_OK)
        return 0;
    /* Total number of disks */
    if (agx_zipReadUInt32(pzlib_filefunc_def, filestream, &value32) != AGX_ZIP_OK)
        return 0;
    /* Goto end of central directory record */
    if (AGX_ZSEEK64(*pzlib_filefunc_def, filestream, offset, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
        return 0;
    /* The signature */
    if (agx_zipReadUInt32(pzlib_filefunc_def, filestream, &value32) != AGX_ZIP_OK)
        return 0;
    if (value32 != AGX_ZIP64ENDHEADERMAGIC)
        return 0;

    return offset;
}

extern agx_zipFile ZEXPORT agx_zipOpen4(const void *path, int append, uint64_t disk_size, const char **globalcomment,
    agx_zlib_filefunc64_32_def *pzlib_filefunc64_32_def)
{
    agx_zip64_internal ziinit = { 0 };
    agx_zip64_internal *zi = NULL;
#ifndef NO_ADDFILEINEXISTINGZIP
    uint64_t byte_before_the_zipfile = 0;   /* byte before the zipfile, (>0 for sfx)*/
    uint64_t size_central_dir = 0;          /* size of the central directory  */
    uint64_t offset_central_dir = 0;        /* offset of start of central directory */
    uint64_t number_entry_CD = 0;           /* total number of entries in the central dir */
    uint64_t number_entry = 0;
    uint64_t central_pos = 0;
    uint64_t size_central_dir_to_read = 0;
    uint16_t value16 = 0;
    uint32_t value32 = 0;
    uint16_t size_comment = 0;
    size_t buf_size = AGX_SIZEDATA_INDATABLOCK;
    void *buf_read = NULL;
#endif
    int err = AGX_ZIP_OK;
    int mode = 0;

    if (pzlib_filefunc64_32_def == NULL)
        agx_fill_fopen64_filefunc(&ziinit.z_filefunc.zfile_func64);
    else
    {
        assert((pzlib_filefunc64_32_def->zopen32_file || pzlib_filefunc64_32_def->zfile_func64.zopen64_file) &&
               (pzlib_filefunc64_32_def->zopendisk32_file || pzlib_filefunc64_32_def->zfile_func64.zopendisk64_file) &&
               (pzlib_filefunc64_32_def->ztell32_file || pzlib_filefunc64_32_def->zfile_func64.ztell64_file) &&
               (pzlib_filefunc64_32_def->zseek32_file || pzlib_filefunc64_32_def->zfile_func64.zseek64_file));
        ziinit.z_filefunc = *pzlib_filefunc64_32_def;
    }

    if (append == AGX_APPEND_STATUS_CREATE)
        mode = (AGX_ZLIB_FILEFUNC_MODE_READ | AGX_ZLIB_FILEFUNC_MODE_WRITE | AGX_ZLIB_FILEFUNC_MODE_CREATE);
    else
        mode = (AGX_ZLIB_FILEFUNC_MODE_READ | AGX_ZLIB_FILEFUNC_MODE_WRITE | AGX_ZLIB_FILEFUNC_MODE_EXISTING);

    ziinit.filestream = AGX_ZOPEN64(ziinit.z_filefunc, path, mode);
    if (ziinit.filestream == NULL)
        return NULL;

    if (append == AGX_APPEND_STATUS_CREATEAFTER)
    {
        /* Don't support spanning ZIP with APPEND_STATUS_CREATEAFTER */
        if (disk_size > 0)
            return NULL;

        AGX_ZSEEK64(ziinit.z_filefunc, ziinit.filestream, 0, SEEK_END);
    }

    ziinit.filestream_with_CD = ziinit.filestream;
    ziinit.append = append;
    ziinit.disk_size = disk_size;
    agx_init_linkedlist(&(ziinit.central_dir));

    zi = (agx_zip64_internal*)AGX_ALLOC(sizeof(agx_zip64_internal));
    if (zi == NULL)
    {
        AGX_ZCLOSE64(ziinit.z_filefunc, ziinit.filestream);
        return NULL;
    }

#ifndef NO_ADDFILEINEXISTINGZIP
    /* Add file in a zipfile */
    ziinit.globalcomment = NULL;
    if (append == AGX_APPEND_STATUS_ADDINZIP)
    {
        /* Read and Cache Central Directory Records */
        central_pos = agx_zipSearchCentralDir(&ziinit.z_filefunc, ziinit.filestream);
        /* Disable to allow appending to empty ZIP archive (must be standard zip, not zip64)
            if (central_pos == 0)
                err = ZIP_ERRNO;
        */

        if (err == AGX_ZIP_OK)
        {
            /* Read end of central directory info */
            if (AGX_ZSEEK64(ziinit.z_filefunc, ziinit.filestream, central_pos, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
                err = AGX_ZIP_ERRNO;

            /* The signature, already checked */
            if (agx_zipReadUInt32(&ziinit.z_filefunc, ziinit.filestream, &value32) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            /* Number of this disk */
            if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &value16) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            ziinit.number_disk = value16;
            /* Number of the disk with the start of the central directory */
            if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &value16) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            ziinit.number_disk_with_CD = value16;
            /* Total number of entries in the central dir on this disk */
            number_entry = 0;
            if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &value16) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            else
                number_entry = value16;
            /* Total number of entries in the central dir */
            number_entry_CD = 0;
            if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &value16) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            else
                number_entry_CD = value16;
            if (number_entry_CD!=number_entry)
                err = AGX_ZIP_BADZIPFILE;
            /* Size of the central directory */
            size_central_dir = 0;
            if (agx_zipReadUInt32(&ziinit.z_filefunc, ziinit.filestream, &value32) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            else
                size_central_dir = value32;
            /* Offset of start of central directory with respect to the starting disk number */
            offset_central_dir = 0;
            if (agx_zipReadUInt32(&ziinit.z_filefunc, ziinit.filestream, &value32) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
            else
                offset_central_dir = value32;
            /* Zipfile global comment length */
            if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &size_comment) != AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;

            if ((err == AGX_ZIP_OK) && ((number_entry_CD == UINT16_MAX) || (offset_central_dir == UINT32_MAX)))
            {
                /* Format should be Zip64, as the central directory or file size is too large */
                central_pos = agx_zipSearchCentralDir64(&ziinit.z_filefunc, ziinit.filestream, central_pos);

                if (central_pos)
                {
                    uint64_t sizeEndOfCentralDirectory;

                    if (AGX_ZSEEK64(ziinit.z_filefunc, ziinit.filestream, central_pos, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
                        err = AGX_ZIP_ERRNO;

                    /* The signature, already checked */
                    if (agx_zipReadUInt32(&ziinit.z_filefunc, ziinit.filestream, &value32) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Size of zip64 end of central directory record */
                    if (agx_zipReadUInt64(&ziinit.z_filefunc, ziinit.filestream, &sizeEndOfCentralDirectory) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Version made by */
                    if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &value16) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Version needed to extract */
                    if (agx_zipReadUInt16(&ziinit.z_filefunc, ziinit.filestream, &value16) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Number of this disk */
                    if (agx_zipReadUInt32(&ziinit.z_filefunc, ziinit.filestream, &ziinit.number_disk) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Number of the disk with the start of the central directory */
                    if (agx_zipReadUInt32(&ziinit.z_filefunc, ziinit.filestream, &ziinit.number_disk_with_CD) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Total number of entries in the central directory on this disk */
                    if (agx_zipReadUInt64(&ziinit.z_filefunc, ziinit.filestream, &number_entry) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Total number of entries in the central directory */
                    if (agx_zipReadUInt64(&ziinit.z_filefunc, ziinit.filestream, &number_entry_CD) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    if (number_entry_CD!=number_entry)
                        err = AGX_ZIP_BADZIPFILE;
                    /* Size of the central directory */
                    if (agx_zipReadUInt64(&ziinit.z_filefunc, ziinit.filestream, &size_central_dir) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                    /* Offset of start of central directory with respect to the starting disk number */
                    if (agx_zipReadUInt64(&ziinit.z_filefunc, ziinit.filestream, &offset_central_dir) != AGX_ZIP_OK)
                        err = AGX_ZIP_ERRNO;
                }
                else
                    err = AGX_ZIP_BADZIPFILE;
             }
        }

        if ((err == AGX_ZIP_OK) && (central_pos < offset_central_dir + size_central_dir))
            err = AGX_ZIP_BADZIPFILE;

        if ((err == AGX_ZIP_OK) && (size_comment > 0))
        {
            ziinit.globalcomment = (char*)AGX_ALLOC(size_comment+1);
            if (ziinit.globalcomment)
            {
                if (AGX_ZREAD64(ziinit.z_filefunc, ziinit.filestream, ziinit.globalcomment, size_comment) != size_comment)
                    err = AGX_ZIP_ERRNO;
                else
                    ziinit.globalcomment[size_comment] = 0;
            }
        }

        if (err != AGX_ZIP_OK)
        {
            AGX_ZCLOSE64(ziinit.z_filefunc, ziinit.filestream);
            AGX_TRYFREE(ziinit.globalcomment);
            AGX_TRYFREE(zi);
            return NULL;
        }

        byte_before_the_zipfile = central_pos - (offset_central_dir+size_central_dir);
        ziinit.add_position_when_writting_offset = byte_before_the_zipfile;

        /* Store central directory in memory */
        size_central_dir_to_read = size_central_dir;
        buf_size = AGX_SIZEDATA_INDATABLOCK;
        buf_read = (void*)AGX_ALLOC(buf_size);

        if (AGX_ZSEEK64(ziinit.z_filefunc, ziinit.filestream,
                offset_central_dir + byte_before_the_zipfile, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
            err = AGX_ZIP_ERRNO;

        while ((size_central_dir_to_read > 0) && (err == AGX_ZIP_OK))
        {
            uint64_t read_this = AGX_SIZEDATA_INDATABLOCK;
            if (read_this > size_central_dir_to_read)
                read_this = size_central_dir_to_read;

            if (AGX_ZREAD64(ziinit.z_filefunc, ziinit.filestream, buf_read, (uint32_t)read_this) != read_this)
                err = AGX_ZIP_ERRNO;

            if (err == AGX_ZIP_OK)
                err = agx_add_data_in_datablock(&ziinit.central_dir, buf_read, (uint32_t)read_this);

            size_central_dir_to_read -= read_this;
        }
        AGX_TRYFREE(buf_read);

        ziinit.number_entry = number_entry_CD;

        if (AGX_ZSEEK64(ziinit.z_filefunc, ziinit.filestream,
                offset_central_dir+byte_before_the_zipfile, AGX_ZLIB_FILEFUNC_SEEK_SET) != 0)
            err = AGX_ZIP_ERRNO;
    }

    if (globalcomment)
        *globalcomment = ziinit.globalcomment;
#endif

    if (err != AGX_ZIP_OK)
    {
#ifndef NO_ADDFILEINEXISTINGZIP
        AGX_TRYFREE(ziinit.globalcomment);
#endif
        AGX_TRYFREE(zi);
        return NULL;
    }

    *zi = ziinit;
    agx_zipGoToFirstDisk((agx_zipFile)zi);
    return(agx_zipFile)zi;
}

extern agx_zipFile ZEXPORT agx_zipOpen2(const char *path, int append, const char **globalcomment,
    agx_zlib_filefunc_def *pzlib_filefunc32_def)
{
    if (pzlib_filefunc32_def != NULL)
    {
        agx_zlib_filefunc64_32_def zlib_filefunc64_32_def_fill = { 0 };
        agx_fill_zlib_filefunc64_32_def_from_filefunc32(&zlib_filefunc64_32_def_fill, pzlib_filefunc32_def);
        return agx_zipOpen4(path, append, 0, globalcomment, &zlib_filefunc64_32_def_fill);
    }
    return agx_zipOpen4(path, append, 0, globalcomment, NULL);
}

extern agx_zipFile ZEXPORT agx_zipOpen2_64(const void *path, int append, const char **globalcomment,
    agx_zlib_filefunc64_def *pzlib_filefunc_def)
{
    if (pzlib_filefunc_def != NULL)
    {
        agx_zlib_filefunc64_32_def zlib_filefunc64_32_def_fill = { 0 };
        zlib_filefunc64_32_def_fill.zfile_func64 = *pzlib_filefunc_def;
        return agx_zipOpen4(path, append, 0, globalcomment, &zlib_filefunc64_32_def_fill);
    }
    return agx_zipOpen4(path, append, 0, globalcomment, NULL);
}

extern agx_zipFile ZEXPORT agx_zipOpen3(const char *path, int append, uint64_t disk_size, const char **globalcomment,
    agx_zlib_filefunc_def *pzlib_filefunc32_def)
{
    if (pzlib_filefunc32_def != NULL)
    {
        agx_zlib_filefunc64_32_def zlib_filefunc64_32_def_fill = { 0 };
        agx_fill_zlib_filefunc64_32_def_from_filefunc32(&zlib_filefunc64_32_def_fill, pzlib_filefunc32_def);
        return agx_zipOpen4(path, append, disk_size, globalcomment, &zlib_filefunc64_32_def_fill);
    }
    return agx_zipOpen4(path, append, disk_size, globalcomment, NULL);
}

extern agx_zipFile ZEXPORT agx_zipOpen3_64(const void *path, int append, uint64_t disk_size, const char **globalcomment,
    agx_zlib_filefunc64_def *pzlib_filefunc_def)
{
    if (pzlib_filefunc_def != NULL)
    {
        agx_zlib_filefunc64_32_def zlib_filefunc64_32_def_fill = { 0 };
        zlib_filefunc64_32_def_fill.zfile_func64 = *pzlib_filefunc_def;
        return agx_zipOpen4(path, append, disk_size, globalcomment, &zlib_filefunc64_32_def_fill);
    }
    return agx_zipOpen4(path, append, disk_size, globalcomment, NULL);
}

extern agx_zipFile ZEXPORT agx_zipOpen(const char *path, int append)
{
    return agx_zipOpen3((const void*)path, append, 0, NULL, NULL);
}

extern agx_zipFile ZEXPORT agx_zipOpen64(const void *path, int append)
{
    return agx_zipOpen3(path, append, 0, NULL, NULL);
}

extern int ZEXPORT agx_zipOpenNewFileInZip5(
                                        agx_zipFile file,
                                        const char *filename,
                                        const agx_zip_fileinfo *zipfi,
                                        const void *extrafield_local,
                                        uint16_t size_extrafield_local,
                                        const void *extrafield_global,
                                        uint16_t size_extrafield_global,
                                        const char *comment,
                                        uint16_t flag_base,
                                        int zip64,
                                        uint16_t method,
                                        int level,
                                        int raw,
                                        int windowBits,
                                        int memLevel,
                                        int strategy,
                                        const char *password,
                                        int aes,
                                        uint16_t version_madeby)
{
    agx_zip64_internal *zi = NULL;
    uint64_t size_available = 0;
    uint64_t size_needed = 0;
    uint16_t size_filename = 0;
    uint16_t size_comment = 0;
    uint16_t i = 0;
    unsigned char *central_dir = NULL;
    int err = AGX_ZIP_OK;

#ifdef NOCRYPT
    if (password != NULL)
        return AGX_ZIP_PARAMERROR;
#endif

    if (file == NULL)
        return AGX_ZIP_PARAMERROR;

    if ((method != 0) &&
#ifdef HAVE_BZIP2
        (method != AGX_Z_BZIP2ED) &&
#endif
        (method != Z_DEFLATED))
        return AGX_ZIP_PARAMERROR;

    zi = (agx_zip64_internal*)file;

    if (zi->in_opened_file_inzip == 1)
    {
        err = agx_zipCloseFileInZip (file);
        if (err != AGX_ZIP_OK)
            return err;
    }

    if (filename == NULL)
        filename = "-";
    if (comment != NULL)
        size_comment = (uint16_t)strlen(comment);

    size_filename = (uint16_t)strlen(filename);

    if (zipfi == NULL)
        zi->ci.dos_date = 0;
    else
    {
        if (zipfi->dos_date != 0)
            zi->ci.dos_date = zipfi->dos_date;
    }

    zi->ci.method = method;
    zi->ci.compression_method = method;
    zi->ci.raw = raw;
    zi->ci.flag = flag_base | 8;
    if ((level == 8) || (level == 9))
        zi->ci.flag |= 2;
    if (level == 2)
        zi->ci.flag |= 4;
    if (level == 1)
        zi->ci.flag |= 6;

    if (password != NULL)
    {
        zi->ci.flag |= 1;
#ifdef AGX_HAVE_AES
        if (aes)
            zi->ci.method = AGX_AES_METHOD;
#endif
    }
    else
    {
        zi->ci.flag &= ~1;
    }

    if (zi->disk_size > 0)
    {
        if ((zi->number_disk == 0) && (zi->number_entry == 0))
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)AGX_DISKHEADERMAGIC, 4);

        /* Make sure enough space available on current disk for local header */
        agx_zipGetDiskSizeAvailable((agx_zipFile)zi, &size_available);
        size_needed = 30 + size_filename + size_extrafield_local;
#ifdef AGX_HAVE_AES
        if (zi->ci.method == AGX_AES_METHOD)
            size_needed += 11;
#endif
        if (size_available < size_needed)
            agx_zipGoToNextDisk((agx_zipFile)zi);
    }

    zi->ci.zip64 = zip64;

    zi->ci.pos_local_header = AGX_ZTELL64(zi->z_filefunc, zi->filestream);
    if (zi->ci.pos_local_header >= UINT32_MAX)
        zi->ci.zip64 = 1;

    zi->ci.size_comment = size_comment;
    zi->ci.size_centralheader = AGX_SIZECENTRALHEADER + size_filename + size_extrafield_global;
    zi->ci.size_centralextra = size_extrafield_global;
    zi->ci.size_centralextrafree = 32; /* Extra space reserved for ZIP64 extra info */
#ifdef AGX_HAVE_AES
    if (zi->ci.method == AGX_AES_METHOD)
        zi->ci.size_centralextrafree += 11; /* Extra space reserved for AES extra info */
#endif
    zi->ci.central_header = (char*)AGX_ALLOC((uint32_t)zi->ci.size_centralheader + zi->ci.size_centralextrafree + size_comment);
    zi->ci.number_disk = zi->number_disk;

    /* Write central directory header */
    /* https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT */
    central_dir = (unsigned char*)zi->ci.central_header;
    agx_zipWriteValueToMemoryAndMove(&central_dir, (uint32_t)AGX_CENTRALHEADERMAGIC, 4);
    agx_zipWriteValueToMemoryAndMove(&central_dir, version_madeby, 2);
    if (zi->ci.zip64)
        agx_zipWriteValueToMemoryAndMove(&central_dir, (uint16_t)45, 2);
    else
        agx_zipWriteValueToMemoryAndMove(&central_dir, (uint16_t)20, 2);
    agx_zipWriteValueToMemoryAndMove(&central_dir, zi->ci.flag, 2);
    agx_zipWriteValueToMemoryAndMove(&central_dir, zi->ci.method, 2);
    agx_zipWriteValueToMemoryAndMove(&central_dir, zi->ci.dos_date, 4);
    agx_zipWriteValueToMemoryAndMove(&central_dir, (uint32_t)0, 4); /*crc*/
    agx_zipWriteValueToMemoryAndMove(&central_dir, (uint32_t)0, 4); /*compr size*/
    agx_zipWriteValueToMemoryAndMove(&central_dir, (uint32_t)0, 4); /*uncompr size*/
    agx_zipWriteValueToMemoryAndMove(&central_dir, size_filename, 2);
    agx_zipWriteValueToMemoryAndMove(&central_dir, size_extrafield_global, 2);
    agx_zipWriteValueToMemoryAndMove(&central_dir, size_comment, 2);
    agx_zipWriteValueToMemoryAndMove(&central_dir, (uint16_t)zi->ci.number_disk, 2); /*disk nm start*/

    if (zipfi == NULL)
        agx_zipWriteValueToMemoryAndMove(&central_dir, (uint16_t)0, 2);
    else
        agx_zipWriteValueToMemoryAndMove(&central_dir, zipfi->internal_fa, 2);
    if (zipfi == NULL)
        agx_zipWriteValueToMemoryAndMove(&central_dir, (uint32_t)0, 4);
    else
        agx_zipWriteValueToMemoryAndMove(&central_dir, zipfi->external_fa, 4);
    if (zi->ci.pos_local_header >= UINT32_MAX)
        agx_zipWriteValueToMemoryAndMove(&central_dir, UINT32_MAX, 4);
    else
        agx_zipWriteValueToMemoryAndMove(&central_dir,
            (uint32_t)(zi->ci.pos_local_header - zi->add_position_when_writting_offset), 4);

    for (i = 0; i < size_filename; i++)
        zi->ci.central_header[AGX_SIZECENTRALHEADER+i] = filename[i];
    for (i = 0; i < size_extrafield_global; i++)
        zi->ci.central_header[AGX_SIZECENTRALHEADER+size_filename+i] =
            ((const char*)extrafield_global)[i];

    /* Store comment at the end for later repositioning */
    for (i = 0; i < size_comment; i++)
        zi->ci.central_header[zi->ci.size_centralheader+
            zi->ci.size_centralextrafree+i] = comment[i];

    if (zi->ci.central_header == NULL)
        return AGX_ZIP_INTERNALERROR;

    /* Write the local header */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)AGX_LOCALHEADERMAGIC, 4);

    if (err == AGX_ZIP_OK)
    {
        if (zi->ci.zip64)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)45, 2); /* version needed to extract */
        else
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)20, 2); /* version needed to extract */
    }
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->ci.flag, 2);
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->ci.method, 2);
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->ci.dos_date, 4);

    /* CRC & compressed size & uncompressed size is in data descriptor */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)0, 4); /* crc 32, unknown */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)0, 4); /* compressed size, unknown */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)0, 4); /* uncompressed size, unknown */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, size_filename, 2);
    if (err == AGX_ZIP_OK)
    {
        uint64_t size_extrafield = size_extrafield_local;
#ifdef AGX_HAVE_AES
        if (zi->ci.method == AGX_AES_METHOD)
            size_extrafield += 11;
#endif
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)size_extrafield, 2);
    }
    if ((err == AGX_ZIP_OK) && (size_filename > 0))
    {
        if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, filename, size_filename) != size_filename)
            err = AGX_ZIP_ERRNO;
    }
    if ((err == AGX_ZIP_OK) && (size_extrafield_local > 0))
    {
        if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, extrafield_local, size_extrafield_local) != size_extrafield_local)
            err = AGX_ZIP_ERRNO;
    }

#ifdef AGX_HAVE_AES
    /* Write the AES extended info */
    if ((err == AGX_ZIP_OK) && (zi->ci.method == AGX_AES_METHOD))
    {
        int headerid = 0x9901;
        short datasize = 7;

        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, headerid, 2);
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, datasize, 2);
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, AGX_AES_VERSION, 2);
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, 'A', 1);
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, 'E', 1);
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, AGX_AES_ENCRYPTIONMODE, 1);
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->ci.compression_method, 2);
    }
#endif

    zi->ci.crc32 = 0;
    zi->ci.stream_initialised = 0;
    zi->ci.pos_in_buffered_data = 0;
    zi->ci.total_compressed = 0;
    zi->ci.total_uncompressed = 0;

#ifdef HAVE_BZIP2
    zi->ci.bstream.avail_in = (uint16_t)0;
    zi->ci.bstream.avail_out = (uint16_t)AGX_Z_BUFSIZE;
    zi->ci.bstream.next_out = (char*)zi->ci.buffered_data;
    zi->ci.bstream.total_in_hi32 = 0;
    zi->ci.bstream.total_in_lo32 = 0;
    zi->ci.bstream.total_out_hi32 = 0;
    zi->ci.bstream.total_out_lo32 = 0;
#endif

    zi->ci.stream.avail_in = (uint16_t)0;
    zi->ci.stream.avail_out = AGX_Z_BUFSIZE;
    zi->ci.stream.next_out = zi->ci.buffered_data;
    zi->ci.stream.total_in = 0;
    zi->ci.stream.total_out = 0;
    zi->ci.stream.data_type = Z_BINARY;

    if ((err == AGX_ZIP_OK) && (!zi->ci.raw))
    {
        if (method == Z_DEFLATED)
        {
            zi->ci.stream.zalloc = (alloc_func)0;
            zi->ci.stream.zfree = (free_func)0;
            zi->ci.stream.opaque = (voidpf)zi;

            if (windowBits > 0)
                windowBits = -windowBits;

#ifdef HAVE_APPLE_COMPRESSION
            err = compression_stream_init(&zi->ci.astream, COMPRESSION_STREAM_ENCODE, COMPRESSION_ZLIB);
            if (err == COMPRESSION_STATUS_ERROR)
                err = AGX_Z_ERRNO;
            else
                err = AGX_Z_OK;
#else
            err = deflateInit2(&zi->ci.stream, level, Z_DEFLATED, windowBits, memLevel, strategy);
#endif
            if (err == Z_OK)
                zi->ci.stream_initialised = Z_DEFLATED;
        }
        else if (method == AGX_Z_BZIP2ED)
        {
#ifdef HAVE_BZIP2
            zi->ci.bstream.bzalloc = 0;
            zi->ci.bstream.bzfree = 0;
            zi->ci.bstream.opaque = (voidpf)0;

            err = BZ2_bzCompressInit(&zi->ci.bstream, level, 0, 35);
            if (err == BZ_OK)
                zi->ci.stream_initialised = AGX_Z_BZIP2ED;
#endif
        }
    }

#ifndef NOCRYPT
    if ((err == Z_OK) && (password != NULL))
    {
#ifdef AGX_HAVE_AES
        if (zi->ci.method == AGX_AES_METHOD)
        {
            unsigned char passverify[AGX_AES_PWVERIFYSIZE];
            unsigned char saltvalue[AGX_AES_MAXSALTLENGTH];
            uint16_t saltlength = 0;

            if ((AGX_AES_ENCRYPTIONMODE < 1) || (AGX_AES_ENCRYPTIONMODE > 3))
                return Z_ERRNO;

            saltlength = AGX_SALT_LENGTH(AGX_AES_ENCRYPTIONMODE);

            agx_prng_init(agx_cryptrand, zi->ci.aes_rng);
            agx_prng_rand(saltvalue, saltlength, zi->ci.aes_rng);
            agx_prng_end(zi->ci.aes_rng);

            agx_fcrypt_init(AGX_AES_ENCRYPTIONMODE, (uint8_t *)password, (uint32_t)strlen(password), saltvalue, passverify, &zi->ci.aes_ctx);

            if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, saltvalue, saltlength) != saltlength)
                err = AGX_ZIP_ERRNO;
            if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, passverify, AGX_AES_PWVERIFYSIZE) != AGX_AES_PWVERIFYSIZE)
                err = AGX_ZIP_ERRNO;

            zi->ci.total_compressed += saltlength + AGX_AES_PWVERIFYSIZE + AGX_AES_AUTHCODESIZE;
        }
        else
#endif
        {
            unsigned char buf_head[AGX_RAND_HEAD_LEN];
            uint32_t size_head = 0;
            uint8_t verify1 = 0;
            uint8_t verify2 = 0;

            zi->ci.pcrc_32_tab = get_crc_table();

            /*
            Info-ZIP modification to ZipCrypto format:
            If bit 3 of the general purpose bit flag is set, it uses high byte of 16-bit File Time. 
            */
            verify1 = (uint8_t)((zi->ci.dos_date >> 16) & 0xff);
            verify2 = (uint8_t)((zi->ci.dos_date >> 8) & 0xff);

            size_head = agx_crypthead(password, buf_head, AGX_RAND_HEAD_LEN, zi->ci.keys, zi->ci.pcrc_32_tab, verify1, verify2);
            zi->ci.total_compressed += size_head;

            if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, buf_head, size_head) != size_head)
                err = AGX_ZIP_ERRNO;
        }
    }
#endif

    if (err == Z_OK)
        zi->in_opened_file_inzip = 1;
    return err;
}

extern int ZEXPORT agx_zipOpenNewFileInZip4_64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits, int memLevel,
    int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting, uint16_t version_madeby, uint16_t flag_base, int zip64)
{
    uint8_t aes = 0;
#ifdef AGX_HAVE_AES
    aes = 1;
#endif
    return agx_zipOpenNewFileInZip5(file, filename, zipfi, extrafield_local, size_extrafield_local, extrafield_global,
        size_extrafield_global, comment, flag_base, zip64, method, level, raw, windowBits, memLevel, strategy, password, aes,
        version_madeby);
}

extern int ZEXPORT agx_zipOpenNewFileInZip4(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits,
    int memLevel, int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting, uint16_t version_madeby, uint16_t flag_base)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, raw, windowBits, memLevel,
        strategy, password, crc_for_crypting, version_madeby, flag_base, 0);
}

extern int ZEXPORT agx_zipOpenNewFileInZip3(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits,
    int memLevel, int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, raw, windowBits, memLevel,
        strategy, password, crc_for_crypting, AGX_VERSIONMADEBY, 0, 0);
}

extern int ZEXPORT agx_zipOpenNewFileInZip3_64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits,
    int memLevel, int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting, int zip64)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, raw, windowBits, memLevel, strategy,
        password, crc_for_crypting, AGX_VERSIONMADEBY, 0, zip64);
}

extern int ZEXPORT agx_zipOpenNewFileInZip2(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, raw, -MAX_WBITS, AGX_DEF_MEM_LEVEL,
        Z_DEFAULT_STRATEGY, NULL, 0, AGX_VERSIONMADEBY, 0, 0);
}

extern int ZEXPORT agx_zipOpenNewFileInZip2_64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int zip64)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, raw, -MAX_WBITS, AGX_DEF_MEM_LEVEL,
        Z_DEFAULT_STRATEGY, NULL, 0, AGX_VERSIONMADEBY, 0, zip64);
}

extern int ZEXPORT agx_zipOpenNewFileInZip64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int zip64)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, 0, -MAX_WBITS, AGX_DEF_MEM_LEVEL,
        Z_DEFAULT_STRATEGY, NULL, 0, AGX_VERSIONMADEBY, 0, zip64);
}

extern int ZEXPORT agx_zipOpenNewFileInZip(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level)
{
    return agx_zipOpenNewFileInZip4_64(file, filename, zipfi, extrafield_local, size_extrafield_local,
        extrafield_global, size_extrafield_global, comment, method, level, 0, -MAX_WBITS, AGX_DEF_MEM_LEVEL,
        Z_DEFAULT_STRATEGY, NULL, 0, AGX_VERSIONMADEBY, 0, 0);
}

/* Flushes the write buffer to disk */
static int agx_zipFlushWriteBuffer(agx_zip64_internal *zi)
{
    uint64_t size_available = 0;
    uint32_t written = 0;
    uint32_t total_written = 0;
    uint32_t write = 0;
    uint32_t max_write = 0;
    int err = AGX_ZIP_OK;

    if ((zi->ci.flag & 1) != 0)
    {
#ifndef NOCRYPT
#ifdef AGX_HAVE_AES
        if (zi->ci.method == AGX_AES_METHOD)
        {
            agx_fcrypt_encrypt(zi->ci.buffered_data, zi->ci.pos_in_buffered_data, &zi->ci.aes_ctx);
        }
        else
#endif
        {
            uint32_t i = 0;
            uint8_t t = 0;

            for (i = 0; i < zi->ci.pos_in_buffered_data; i++)
                zi->ci.buffered_data[i] = (uint8_t)agx_zencode(zi->ci.keys, zi->ci.pcrc_32_tab, zi->ci.buffered_data[i], t);
        }
#endif
    }

    write = zi->ci.pos_in_buffered_data;

    do
    {
        max_write = write;

        if (zi->disk_size > 0)
        {
            agx_zipGetDiskSizeAvailable((agx_zipFile)zi, &size_available);

            if (size_available == 0)
            {
                err = agx_zipGoToNextDisk((agx_zipFile)zi);
                if (err != AGX_ZIP_OK)
                    return err;
            }

            if (size_available < (uint64_t)max_write)
                max_write = (uint32_t)size_available;
        }

        written = AGX_ZWRITE64(zi->z_filefunc, zi->filestream, zi->ci.buffered_data + total_written, max_write);
        if (written != max_write)
        {
            err = AGX_ZIP_ERRNO;
            break;
        }

        total_written += written;
        write -= written;
    }
    while (write > 0);

    zi->ci.total_compressed += zi->ci.pos_in_buffered_data;

#ifdef HAVE_BZIP2
    if (zi->ci.compression_method == AGX_Z_BZIP2ED)
    {
        zi->ci.total_uncompressed += zi->ci.bstream.total_in_lo32;
        zi->ci.bstream.total_in_lo32 = 0;
        zi->ci.bstream.total_in_hi32 = 0;
    }
    else
#endif
    {
        zi->ci.total_uncompressed += zi->ci.stream.total_in;
        zi->ci.stream.total_in = 0;
    }

    zi->ci.pos_in_buffered_data = 0;

    return err;
}

extern int ZEXPORT agx_zipWriteInFileInZip(agx_zipFile file, const void *buf, uint32_t len)
{
    agx_zip64_internal *zi = NULL;
    int err = AGX_ZIP_OK;

    if (file == NULL)
        return AGX_ZIP_PARAMERROR;
    zi = (agx_zip64_internal*)file;

    if (zi->in_opened_file_inzip == 0)
        return AGX_ZIP_PARAMERROR;

    zi->ci.crc32 = (uint32_t)crc32(zi->ci.crc32, buf, len);

#ifdef HAVE_BZIP2
    if ((zi->ci.compression_method == AGX_Z_BZIP2ED) && (!zi->ci.raw))
    {
        zi->ci.bstream.next_in = (void*)buf;
        zi->ci.bstream.avail_in = len;
        err = BZ_RUN_OK;

        while ((err == BZ_RUN_OK) && (zi->ci.bstream.avail_in > 0))
        {
            if (zi->ci.bstream.avail_out == 0)
            {
                err = zipFlushWriteBuffer(zi);
                
                zi->ci.bstream.avail_out = (uint16_t)AGX_Z_BUFSIZE;
                zi->ci.bstream.next_out = (char*)zi->ci.buffered_data;
            }
            else
            {
                uint32_t total_out_before_lo = zi->ci.bstream.total_out_lo32;
                uint32_t total_out_before_hi = zi->ci.bstream.total_out_hi32;

                err = BZ2_bzCompress(&zi->ci.bstream, BZ_RUN);

                zi->ci.pos_in_buffered_data += (uint16_t)(zi->ci.bstream.total_out_lo32 - total_out_before_lo);
            }
        }

        if (err == BZ_RUN_OK)
            err = ZIP_OK;
    }
    else
#endif
    {
        zi->ci.stream.next_in = (uint8_t*)buf;
        zi->ci.stream.avail_in = len;

        while ((err == AGX_ZIP_OK) && (zi->ci.stream.avail_in > 0))
        {
            if (zi->ci.stream.avail_out == 0)
            {
                err = agx_zipFlushWriteBuffer(zi);
                
                zi->ci.stream.avail_out = AGX_Z_BUFSIZE;
                zi->ci.stream.next_out = zi->ci.buffered_data;
            }

            if (err != AGX_ZIP_OK)
                break;

            if ((zi->ci.compression_method == Z_DEFLATED) && (!zi->ci.raw))
            {
#ifdef HAVE_APPLE_COMPRESSION
                uLong total_out_before = zi->ci.stream.total_out;

                zi->ci.astream.src_ptr = zi->ci.stream.next_in;
                zi->ci.astream.src_size = zi->ci.stream.avail_in;
                zi->ci.astream.dst_ptr = zi->ci.stream.next_out;
                zi->ci.astream.dst_size = zi->ci.stream.avail_out;

                compression_status status = 0;
                compression_stream_flags flags = 0;

                status = compression_stream_process(&zi->ci.astream, flags);

                uLong total_out_after = len - zi->ci.astream.src_size;

                zi->ci.stream.next_in = zi->ci.astream.src_ptr;
                zi->ci.stream.avail_in = zi->ci.astream.src_size;
                zi->ci.stream.next_out = zi->ci.astream.dst_ptr;
                zi->ci.stream.avail_out = zi->ci.astream.dst_size;
                zi->ci.stream.total_in += total_out_after;
                //zi->ci.stream.total_out += copy_this;
                zi->ci.pos_in_buffered_data += total_out_after;

                if (status == COMPRESSION_STATUS_ERROR)
                    err = ZIP_INTERNALERROR;
#else
                uint32_t total_out_before = (uint32_t)zi->ci.stream.total_out;
                err = deflate(&zi->ci.stream, Z_NO_FLUSH);
                zi->ci.pos_in_buffered_data += (uint32_t)(zi->ci.stream.total_out - total_out_before);
#endif
            }
            else
            {
                uint32_t copy_this = 0;
                uint32_t i = 0;
                if (zi->ci.stream.avail_in < zi->ci.stream.avail_out)
                    copy_this = zi->ci.stream.avail_in;
                else
                    copy_this = zi->ci.stream.avail_out;

                for (i = 0; i < copy_this; i++)
                    *(((char*)zi->ci.stream.next_out)+i) =
                        *(((const char*)zi->ci.stream.next_in)+i);

                zi->ci.stream.avail_in -= copy_this;
                zi->ci.stream.avail_out -= copy_this;
                zi->ci.stream.next_in += copy_this;
                zi->ci.stream.next_out += copy_this;
                zi->ci.stream.total_in += copy_this;
                zi->ci.stream.total_out += copy_this;
                zi->ci.pos_in_buffered_data += copy_this;
            }
        }
    }

    return err;
}

extern int ZEXPORT agx_zipCloseFileInZipRaw64(agx_zipFile file, uint64_t uncompressed_size, uint32_t crc32)
{
    agx_zip64_internal *zi = NULL;
    uint16_t extra_data_size = 0;
    uint32_t i = 0;
    unsigned char *extra_info = NULL;
    int err = AGX_ZIP_OK;

    if (file == NULL)
        return AGX_ZIP_PARAMERROR;
    zi = (agx_zip64_internal*)file;

    if (zi->in_opened_file_inzip == 0)
        return AGX_ZIP_PARAMERROR;
    zi->ci.stream.avail_in = 0;

    if (!zi->ci.raw)
    {
        if (zi->ci.compression_method == Z_DEFLATED)
        {
            while (err == AGX_ZIP_OK)
            {
                uint32_t total_out_before = 0;
                
                if (zi->ci.stream.avail_out == 0)
                {
                    err = agx_zipFlushWriteBuffer(zi);

                    zi->ci.stream.avail_out = AGX_Z_BUFSIZE;
                    zi->ci.stream.next_out = zi->ci.buffered_data;
                }
                
                if (err != AGX_ZIP_OK)
                    break;
                
#ifdef HAVE_APPLE_COMPRESSION
                total_out_before = zi->ci.stream.total_out;

                zi->ci.astream.src_ptr = zi->ci.stream.next_in;
                zi->ci.astream.src_size = zi->ci.stream.avail_in;
                zi->ci.astream.dst_ptr = zi->ci.stream.next_out;
                zi->ci.astream.dst_size = zi->ci.stream.avail_out;

                compression_status status = 0;
                status = compression_stream_process(&zi->ci.astream, COMPRESSION_STREAM_FINALIZE);

                uint32_t total_out_after = AGX_Z_BUFSIZE - zi->ci.astream.dst_size;

                zi->ci.stream.next_in = zi->ci.astream.src_ptr;
                zi->ci.stream.avail_in = zi->ci.astream.src_size;
                zi->ci.stream.next_out = zi->ci.astream.dst_ptr;
                zi->ci.stream.avail_out = zi->ci.astream.dst_size;
                //zi->ci.stream.total_in += total_out_after;
                //zi->ci.stream.total_out += copy_this;
                zi->ci.pos_in_buffered_data += total_out_after;

                if (status == COMPRESSION_STATUS_ERROR)
                {
                    err = ZIP_INTERNALERROR;
                }
                else if (status == COMPRESSION_STATUS_END)
                {
                    err = Z_STREAM_END;
                }
#else
                total_out_before = (uint32_t)zi->ci.stream.total_out;
                err = deflate(&zi->ci.stream, Z_FINISH);
                zi->ci.pos_in_buffered_data += (uint16_t)(zi->ci.stream.total_out - total_out_before);
#endif
            }
        }
        else if (zi->ci.compression_method == AGX_Z_BZIP2ED)
        {
#ifdef HAVE_BZIP2
            err = BZ_FINISH_OK;
            while (err == BZ_FINISH_OK)
            {
                uint32_t total_out_before = 0;
                
                if (zi->ci.bstream.avail_out == 0)
                {
                    err = zipFlushWriteBuffer(zi);
                    
                    zi->ci.bstream.avail_out = (uint16_t)AGX_Z_BUFSIZE;
                    zi->ci.bstream.next_out = (char*)zi->ci.buffered_data;
                }
                
                total_out_before = zi->ci.bstream.total_out_lo32;
                err = BZ2_bzCompress(&zi->ci.bstream, BZ_FINISH);
                if (err == BZ_STREAM_END)
                    err = Z_STREAM_END;
                zi->ci.pos_in_buffered_data += (uint16_t)(zi->ci.bstream.total_out_lo32 - total_out_before);
            }

            if (err == BZ_FINISH_OK)
                err = ZIP_OK;
#endif
        }
    }

    if (err == Z_STREAM_END)
        err = AGX_ZIP_OK; /* this is normal */

    if ((zi->ci.pos_in_buffered_data > 0) && (err == AGX_ZIP_OK))
    {
        err = agx_zipFlushWriteBuffer(zi);
    }

#ifdef AGX_HAVE_AES
    if (zi->ci.method == AGX_AES_METHOD)
    {
        unsigned char authcode[AGX_AES_AUTHCODESIZE];

        agx_fcrypt_end(authcode, &zi->ci.aes_ctx);

        if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, authcode, AGX_AES_AUTHCODESIZE) != AGX_AES_AUTHCODESIZE)
            err = AGX_ZIP_ERRNO;
    }
#endif

    if (!zi->ci.raw)
    {
        if (zi->ci.compression_method == Z_DEFLATED)
        {
            int tmp_err = 0;
#ifdef HAVE_APPLE_COMPRESSION
            tmp_err = compression_stream_destroy(&zi->ci.astream);
#else
            tmp_err = deflateEnd(&zi->ci.stream);
#endif
            if (err == AGX_ZIP_OK)
                err = tmp_err;
            zi->ci.stream_initialised = 0;
        }
#ifdef HAVE_BZIP2
        else if (zi->ci.compression_method == AGX_Z_BZIP2ED)
        {
            int tmperr = BZ2_bzCompressEnd(&zi->ci.bstream);
            if (err == AGX_ZIP_OK)
                err = tmperr;
            zi->ci.stream_initialised = 0;
        }
#endif

        crc32 = zi->ci.crc32;
        uncompressed_size = zi->ci.total_uncompressed;
    }

    /* Write data descriptor */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)AGX_DATADESCRIPTORMAGIC, 4);
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, crc32, 4);
    if (err == AGX_ZIP_OK)
    {
        if (zi->ci.zip64)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->ci.total_compressed, 8);
        else
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)zi->ci.total_compressed, 4);
    }
    if (err == AGX_ZIP_OK)
    {
        if (zi->ci.zip64)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, uncompressed_size, 8);
        else
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)uncompressed_size, 4);
    }

    /* Update crc and sizes to central directory */
    agx_zipWriteValueToMemory(zi->ci.central_header + 16, crc32, 4); /* crc */
    if (zi->ci.total_compressed >= UINT32_MAX)
        agx_zipWriteValueToMemory(zi->ci.central_header + 20, UINT32_MAX, 4); /* compr size */
    else
        agx_zipWriteValueToMemory(zi->ci.central_header + 20, zi->ci.total_compressed, 4); /* compr size */
    if (uncompressed_size >= UINT32_MAX)
        agx_zipWriteValueToMemory(zi->ci.central_header + 24, UINT32_MAX, 4); /* uncompr size */
    else
        agx_zipWriteValueToMemory(zi->ci.central_header + 24, uncompressed_size, 4); /* uncompr size */
    if (zi->ci.stream.data_type == Z_ASCII)
        agx_zipWriteValueToMemory(zi->ci.central_header + 36, (uint16_t)Z_ASCII, 2); /* internal file attrib */

    /* Add ZIP64 extra info field for uncompressed size */
    if (uncompressed_size >= UINT32_MAX)
        extra_data_size += 8;
    /* Add ZIP64 extra info field for compressed size */
    if (zi->ci.total_compressed >= UINT32_MAX)
        extra_data_size += 8;
    /* Add ZIP64 extra info field for relative offset to local file header of current file */
    if (zi->ci.pos_local_header >= UINT32_MAX)
        extra_data_size += 8;

    /* Add ZIP64 extra info header to central directory */
    if (extra_data_size > 0)
    {
        if ((uint32_t)(extra_data_size + 4) > zi->ci.size_centralextrafree)
            return AGX_ZIP_BADZIPFILE;

        extra_info = (unsigned char*)zi->ci.central_header + zi->ci.size_centralheader;

        agx_zipWriteValueToMemoryAndMove(&extra_info, 0x0001, 2);
        agx_zipWriteValueToMemoryAndMove(&extra_info, extra_data_size, 2);

        if (uncompressed_size >= UINT32_MAX)
            agx_zipWriteValueToMemoryAndMove(&extra_info, uncompressed_size, 8);
        if (zi->ci.total_compressed >= UINT32_MAX)
            agx_zipWriteValueToMemoryAndMove(&extra_info, zi->ci.total_compressed, 8);
        if (zi->ci.pos_local_header >= UINT32_MAX)
            agx_zipWriteValueToMemoryAndMove(&extra_info, zi->ci.pos_local_header, 8);

        zi->ci.size_centralextrafree -= extra_data_size + 4;
        zi->ci.size_centralheader += extra_data_size + 4;
        zi->ci.size_centralextra += extra_data_size + 4;

        agx_zipWriteValueToMemory(zi->ci.central_header + 30, zi->ci.size_centralextra, 2);
    }

#ifdef AGX_HAVE_AES
    /* Write AES extra info header to central directory */
    if (zi->ci.method == AGX_AES_METHOD)
    {
        extra_info = (unsigned char*)zi->ci.central_header + zi->ci.size_centralheader;
        extra_data_size = 7;

        if ((uint32_t)(extra_data_size + 4) > zi->ci.size_centralextrafree)
            return AGX_ZIP_BADZIPFILE;

        agx_zipWriteValueToMemoryAndMove(&extra_info, 0x9901, 2);
        agx_zipWriteValueToMemoryAndMove(&extra_info, extra_data_size, 2);
        agx_zipWriteValueToMemoryAndMove(&extra_info, AGX_AES_VERSION, 2);
        agx_zipWriteValueToMemoryAndMove(&extra_info, 'A', 1);
        agx_zipWriteValueToMemoryAndMove(&extra_info, 'E', 1);
        agx_zipWriteValueToMemoryAndMove(&extra_info, AGX_AES_ENCRYPTIONMODE, 1);
        agx_zipWriteValueToMemoryAndMove(&extra_info, zi->ci.compression_method, 2);

        zi->ci.size_centralextrafree -= extra_data_size + 4;
        zi->ci.size_centralheader += extra_data_size + 4;
        zi->ci.size_centralextra += extra_data_size + 4;

        agx_zipWriteValueToMemory(zi->ci.central_header + 30, zi->ci.size_centralextra, 2);
    }
#endif
    /* Restore comment to correct position */
    for (i = 0; i < zi->ci.size_comment; i++)
        zi->ci.central_header[zi->ci.size_centralheader+i] =
            zi->ci.central_header[zi->ci.size_centralheader+zi->ci.size_centralextrafree+i];
    zi->ci.size_centralheader += zi->ci.size_comment;

    if (err == AGX_ZIP_OK)
        err = agx_add_data_in_datablock(&zi->central_dir, zi->ci.central_header, zi->ci.size_centralheader);

    free(zi->ci.central_header);

    zi->number_entry++;
    zi->in_opened_file_inzip = 0;

    return err;
}

extern int ZEXPORT agx_zipCloseFileInZipRaw(agx_zipFile file, uint32_t uncompressed_size, uint32_t crc32)
{
    return agx_zipCloseFileInZipRaw64(file, uncompressed_size, crc32);
}

extern int ZEXPORT agx_zipCloseFileInZip(agx_zipFile file)
{
    return agx_zipCloseFileInZipRaw(file, 0, 0);
}

extern int ZEXPORT agx_zipClose(agx_zipFile file, const char *global_comment)
{
    return agx_zipClose_64(file, global_comment);
}

extern int ZEXPORT agx_zipClose_64(agx_zipFile file, const char *global_comment)
{
    return agx_zipClose2_64(file, global_comment, AGX_VERSIONMADEBY);
}

extern int ZEXPORT agx_zipClose2_64(agx_zipFile file, const char *global_comment, uint16_t version_madeby)
{
    agx_zip64_internal *zi = NULL;
    uint32_t size_centraldir = 0;
    uint16_t size_global_comment = 0;
    uint64_t centraldir_pos_inzip = 0;
    uint64_t pos = 0;
    uint64_t cd_pos = 0;
    uint32_t write = 0;
    int err = AGX_ZIP_OK;

    if (file == NULL)
        return AGX_ZIP_PARAMERROR;
    zi = (agx_zip64_internal*)file;

    if (zi->in_opened_file_inzip == 1)
        err = agx_zipCloseFileInZip(file);

#ifndef NO_ADDFILEINEXISTINGZIP
    if (global_comment == NULL)
        global_comment = zi->globalcomment;
#endif

    if (zi->filestream != zi->filestream_with_CD)
    {
        if (AGX_ZCLOSE64(zi->z_filefunc, zi->filestream) != 0)
            if (err == AGX_ZIP_OK)
                err = AGX_ZIP_ERRNO;
        if (zi->disk_size > 0)
            zi->number_disk_with_CD = zi->number_disk + 1;
        zi->filestream = zi->filestream_with_CD;
    }

    centraldir_pos_inzip = AGX_ZTELL64(zi->z_filefunc, zi->filestream);

    if (err == AGX_ZIP_OK)
    {
        agx_linkedlist_datablock_internal *ldi = zi->central_dir.first_block;
        while (ldi != NULL)
        {
            if ((err == AGX_ZIP_OK) && (ldi->filled_in_this_block > 0))
            {
                write = AGX_ZWRITE64(zi->z_filefunc, zi->filestream, ldi->data, ldi->filled_in_this_block);
                if (write != ldi->filled_in_this_block)
                    err = AGX_ZIP_ERRNO;
            }

            size_centraldir += ldi->filled_in_this_block;
            ldi = ldi->next_datablock;
        }
    }

    agx_free_linkedlist(&(zi->central_dir));

    pos = centraldir_pos_inzip - zi->add_position_when_writting_offset;

    /* Write the ZIP64 central directory header */
    if (pos >= UINT32_MAX || zi->number_entry > UINT32_MAX)
    {
        uint64_t zip64_eocd_pos_inzip = AGX_ZTELL64(zi->z_filefunc, zi->filestream);
        uint32_t zip64_datasize = 44;

        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)AGX_ZIP64ENDHEADERMAGIC, 4);

        /* Size of this 'zip64 end of central directory' */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint64_t)zip64_datasize, 8);
        /* Version made by */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, version_madeby, 2);
        /* version needed */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)45, 2);
        /* Number of this disk */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->number_disk_with_CD, 4);
        /* Number of the disk with the start of the central directory */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->number_disk_with_CD, 4);
        /* Total number of entries in the central dir on this disk */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->number_entry, 8);
        /* Total number of entries in the central dir */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->number_entry, 8);
        /* Size of the central directory */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint64_t)size_centraldir, 8);

        if (err == AGX_ZIP_OK)
        {
            /* Offset of start of central directory with respect to the starting disk number */
            cd_pos = centraldir_pos_inzip - zi->add_position_when_writting_offset;
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, cd_pos, 8);
        }
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)AGX_ZIP64ENDLOCHEADERMAGIC, 4);

        /* Number of the disk with the start of the central directory */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->number_disk_with_CD, 4);
        /* Relative offset to the Zip64EndOfCentralDirectory */
        if (err == AGX_ZIP_OK)
        {
            cd_pos = zip64_eocd_pos_inzip - zi->add_position_when_writting_offset;
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, cd_pos, 8);
        }
        /* Number of the disk with the start of the central directory */
        if (err == AGX_ZIP_OK)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, zi->number_disk_with_CD + 1, 4);
    }

    /* Write the central directory header */

    /* Signature */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)AGX_ENDHEADERMAGIC, 4);
    /* Number of this disk */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)zi->number_disk_with_CD, 2);
    /* Number of the disk with the start of the central directory */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)zi->number_disk_with_CD, 2);
    /* Total number of entries in the central dir on this disk */
    if (err == AGX_ZIP_OK)
    {
        if (zi->number_entry >= UINT16_MAX)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, UINT16_MAX, 2); /* use value in ZIP64 record */
        else
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)zi->number_entry, 2);
    }
    /* Total number of entries in the central dir */
    if (err == AGX_ZIP_OK)
    {
        if (zi->number_entry >= UINT16_MAX)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, UINT16_MAX, 2); /* use value in ZIP64 record */
        else
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint16_t)zi->number_entry, 2);
    }
    /* Size of the central directory */
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, size_centraldir, 4);
    /* Offset of start of central directory with respect to the starting disk number */
    if (err == AGX_ZIP_OK)
    {
        cd_pos = centraldir_pos_inzip - zi->add_position_when_writting_offset;
        if (pos >= UINT32_MAX)
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, UINT32_MAX, 4);
        else
            err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, (uint32_t)cd_pos, 4);
    }

    /* Write global comment */

    if (global_comment != NULL)
        size_global_comment = (uint16_t)strlen(global_comment);
    if (err == AGX_ZIP_OK)
        err = agx_zipWriteValue(&zi->z_filefunc, zi->filestream, size_global_comment, 2);
    if (err == AGX_ZIP_OK && size_global_comment > 0)
    {
        if (AGX_ZWRITE64(zi->z_filefunc, zi->filestream, global_comment, size_global_comment) != size_global_comment)
            err = AGX_ZIP_ERRNO;
    }

    if ((AGX_ZCLOSE64(zi->z_filefunc, zi->filestream) != 0) && (err == AGX_ZIP_OK))
        err = AGX_ZIP_ERRNO;

#ifndef NO_ADDFILEINEXISTINGZIP
    AGX_TRYFREE(zi->globalcomment);
#endif
    AGX_TRYFREE(zi);

    return err;
}
