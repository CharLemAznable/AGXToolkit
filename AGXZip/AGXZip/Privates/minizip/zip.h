//
//  zip.h
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

/* zip.h -- IO on .zip files using zlib
   Version 1.2.0, September 16th, 2017
   part of the MiniZip project

   Copyright (C) 2012-2017 Nathan Moinvaziri
     https://github.com/nmoinvaz/minizip
   Copyright (C) 2009-2010 Mathias Svensson
     Modifications for Zip64 support
     http://result42.com
   Copyright (C) 1998-2010 Gilles Vollant
     http://www.winimage.com/zLibDll/minizip.html

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/

#ifndef _AGX_ZIP_H
#define _AGX_ZIP_H

#define AGX_HAVE_AES

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _ZLIB_H
#  include "zlib.h"
#endif

#ifndef _AGX_ZLIBIOAPI_H
#  include "ioapi.h"
#endif

#ifdef HAVE_BZIP2
#  include "bzlib.h"
#endif

#define AGX_Z_BZIP2ED 12

#if defined(STRICTZIP) || defined(STRICTZIPUNZIP)
/* like the STRICT of WIN32, we define a pointer that cannot be converted
    from (void*) without cast */
typedef struct TagzipFile__ { int unused; } agx_zip_file__;
typedef agx_zip_file__ *agx_zipFile;
#else
typedef voidp agx_zipFile;
#endif

#define AGX_ZIP_OK                          (0)
#define AGX_ZIP_EOF                         (0)
#define AGX_ZIP_ERRNO                       (Z_ERRNO)
#define AGX_ZIP_PARAMERROR                  (-102)
#define AGX_ZIP_BADZIPFILE                  (-103)
#define AGX_ZIP_INTERNALERROR               (-104)

#ifndef AGX_DEF_MEM_LEVEL
#  if MAX_MEM_LEVEL >= 8
#    define AGX_DEF_MEM_LEVEL 8
#  else
#    define AGX_DEF_MEM_LEVEL  MAX_MEM_LEVEL
#  endif
#endif

typedef struct
{
    uint32_t    dos_date;
    uint16_t    internal_fa;        /* internal file attributes        2 bytes */
    uint32_t    external_fa;        /* external file attributes        4 bytes */
} agx_zip_fileinfo;

#define AGX_APPEND_STATUS_CREATE        (0)
#define AGX_APPEND_STATUS_CREATEAFTER   (1)
#define AGX_APPEND_STATUS_ADDINZIP      (2)

/***************************************************************************/
/* Writing a zip file */

extern agx_zipFile ZEXPORT agx_zipOpen(const char *path, int append);
extern agx_zipFile ZEXPORT agx_zipOpen64(const void *path, int append);
/* Create a zipfile.

   path should contain the full path (by example, on a Windows XP computer 
      "c:\\zlib\\zlib113.zip" or on an Unix computer "zlib/zlib113.zip". 

   return NULL if zipfile cannot be opened
   return zipFile handle if no error

   If the file path exist and append == APPEND_STATUS_CREATEAFTER, the zip
   will be created at the end of the file. (useful if the file contain a self extractor code)
   If the file path exist and append == APPEND_STATUS_ADDINZIP, we will add files in existing 
   zip (be sure you don't add file that doesn't exist)

   NOTE: There is no delete function into a zipfile. If you want delete file into a zipfile, 
   you must open a zipfile, and create another. Of course, you can use RAW reading and writing to copy
   the file you did not want delete. */

extern agx_zipFile ZEXPORT agx_zipOpen2(const char *path, int append, const char **globalcomment,
    agx_zlib_filefunc_def *pzlib_filefunc_def);

extern agx_zipFile ZEXPORT agx_zipOpen2_64(const void *path, int append, const char **globalcomment,
    agx_zlib_filefunc64_def *pzlib_filefunc_def);

extern agx_zipFile ZEXPORT agx_zipOpen3(const char *path, int append, uint64_t disk_size,
    const char **globalcomment, agx_zlib_filefunc_def *pzlib_filefunc_def);
/* Same as zipOpen2 but allows specification of spanned zip size */

extern agx_zipFile ZEXPORT agx_zipOpen3_64(const void *path, int append, uint64_t disk_size,
    const char **globalcomment, agx_zlib_filefunc64_def *pzlib_filefunc_def);

extern int ZEXPORT agx_zipOpenNewFileInZip(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global, 
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level);
/* Open a file in the ZIP for writing.

   filename : the filename in zip (if NULL, '-' without quote will be used
   *zipfi contain supplemental information
   extrafield_local buffer to store the local header extra field data, can be NULL
   size_extrafield_local size of extrafield_local buffer
   extrafield_global buffer to store the global header extra field data, can be NULL
   size_extrafield_global size of extrafield_local buffer
   comment buffer for comment string
   method contain the compression method (0 for store, Z_DEFLATED for deflate)
   level contain the level of compression (can be Z_DEFAULT_COMPRESSION)
   zip64 is set to 1 if a zip64 extended information block should be added to the local file header.
   this MUST be '1' if the uncompressed size is >= 0xffffffff. */

extern int ZEXPORT agx_zipOpenNewFileInZip64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int zip64);
/* Same as zipOpenNewFileInZip with zip64 support */

extern int ZEXPORT agx_zipOpenNewFileInZip2(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw);
/* Same as zipOpenNewFileInZip, except if raw=1, we write raw file */

extern int ZEXPORT agx_zipOpenNewFileInZip2_64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int zip64);
/* Same as zipOpenNewFileInZip3 with zip64 support */

extern int ZEXPORT agx_zipOpenNewFileInZip3(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits, int memLevel,
    int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting);
/* Same as zipOpenNewFileInZip2, except
    windowBits, memLevel, strategy : see parameter strategy in deflateInit2
    password : crypting password (NULL for no crypting)
    crc_for_crypting : crc of file to compress (needed for crypting) */

extern int ZEXPORT agx_zipOpenNewFileInZip3_64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits, int memLevel,
    int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting, int zip64);
/* Same as zipOpenNewFileInZip3 with zip64 support */

extern int ZEXPORT agx_zipOpenNewFileInZip4(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits, int memLevel,
    int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting, uint16_t version_madeby, uint16_t flag_base);
/* Same as zipOpenNewFileInZip3 except versionMadeBy & flag fields */

extern int ZEXPORT agx_zipOpenNewFileInZip4_64(agx_zipFile file, const char *filename, const agx_zip_fileinfo *zipfi,
    const void *extrafield_local, uint16_t size_extrafield_local, const void *extrafield_global,
    uint16_t size_extrafield_global, const char *comment, uint16_t method, int level, int raw, int windowBits, int memLevel,
    int strategy, const char *password, AGX_ZIP_UNUSED uint32_t crc_for_crypting, uint16_t version_madeby, uint16_t flag_base, int zip64);
/* Same as zipOpenNewFileInZip4 with zip64 support */

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
                                        uint16_t version_madeby);
/* Allowing optional aes */

extern int ZEXPORT agx_zipWriteInFileInZip(agx_zipFile file, const void *buf, uint32_t len);
/* Write data in the zipfile */

extern int ZEXPORT agx_zipCloseFileInZip(agx_zipFile file);
/* Close the current file in the zipfile */

extern int ZEXPORT agx_zipCloseFileInZipRaw(agx_zipFile file, uint32_t uncompressed_size, uint32_t crc32);
extern int ZEXPORT agx_zipCloseFileInZipRaw64(agx_zipFile file, uint64_t uncompressed_size, uint32_t crc32);
/* Close the current file in the zipfile, for file opened with parameter raw=1 in zipOpenNewFileInZip2
   where raw is compressed data. Parameters uncompressed_size and crc32 are value for the uncompressed data. */

extern int ZEXPORT agx_zipClose(agx_zipFile file, const char *global_comment);
/* Close the zipfile */

extern int ZEXPORT agx_zipClose_64(agx_zipFile file, const char *global_comment);

extern int ZEXPORT agx_zipClose2_64(agx_zipFile file, const char *global_comment, uint16_t version_madeby);
/* Same as zipClose_64 except version_madeby field */

/***************************************************************************/

#ifdef __cplusplus
}
#endif

#endif /* _ZIP_H */
