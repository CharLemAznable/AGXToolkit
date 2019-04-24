//
//  unzip.h
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

/* unzip.h -- IO for uncompress .zip files using zlib
   Version 1.2.0, September 16th, 2017
   part of the MiniZip project

   Copyright (C) 2012-2017 Nathan Moinvaziri
     https://github.com/nmoinvaz/minizip
   Copyright (C) 2009-2010 Mathias Svensson
     Modifications for Zip64 support on both zip and unzip
     http://result42.com
   Copyright (C) 2007-2008 Even Rouault
     Modifications of Unzip for Zip64
   Copyright (C) 1998-2010 Gilles Vollant
     http://www.winimage.com/zLibDll/minizip.html

   This program is distributed under the terms of the same license as zlib.
   See the accompanying LICENSE file for the full text of the license.
*/

#ifndef _AGX_UNZ_H
#define _AGX_UNZ_H

#include "AGXZipCommon.h"

#define AGX_HAVE_AES

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _ZLIB_H
#include "zlib.h"
#endif

#ifndef _AGX_ZLIBIOAPI_H
#include "ioapi.h"
#endif

#ifdef HAVE_BZIP2
#include "bzlib.h"
#endif

#define AGX_Z_BZIP2ED 12

#if defined(STRICTUNZIP) || defined(STRICTZIPUNZIP)
/* like the STRICT of WIN32, we define a pointer that cannot be converted
    from (void*) without cast */
typedef struct TagunzFile__ { int unused; } agx_unz_file__;
typedef agx_unz_file__ *agx_unzFile;
#else
typedef voidp agx_unzFile;
#endif

#define AGX_UNZ_OK                          (0)
#define AGX_UNZ_END_OF_LIST_OF_FILE         (-100)
#define AGX_UNZ_ERRNO                       (Z_ERRNO)
#define AGX_UNZ_EOF                         (0)
#define AGX_UNZ_PARAMERROR                  (-102)
#define AGX_UNZ_BADZIPFILE                  (-103)
#define AGX_UNZ_INTERNALERROR               (-104)
#define AGX_UNZ_CRCERROR                    (-105)
#define AGX_UNZ_BADPASSWORD                 (-106)


/***************************************************************************/
/* Opening and close a zip file */

extern agx_unzFile ZEXPORT agx_unzOpen(const char *path);
extern agx_unzFile ZEXPORT agx_unzOpen64(const void *path);
/* Open a Zip file.

   path should contain the full path (by example, on a Windows XP computer 
      "c:\\zlib\\zlib113.zip" or on an Unix computer "zlib/zlib113.zip". 
   return NULL if zipfile cannot be opened or doesn't exist
   return unzFile handle if no error

   NOTE: The "64" function take a const void *pointer, because  the path is just the value passed to the
   open64_file_func callback. Under Windows, if UNICODE is defined, using fill_fopen64_filefunc, the path 
   is a pointer to a wide unicode string  (LPCTSTR is LPCWSTR), so const char *does not describe the reality */

extern agx_unzFile ZEXPORT agx_unzOpen2(const char *path, agx_zlib_filefunc_def *pzlib_filefunc_def);
/* Open a Zip file, like unzOpen, but provide a set of file low level API for read/write operations */
extern agx_unzFile ZEXPORT agx_unzOpen2_64(const void *path, agx_zlib_filefunc64_def *pzlib_filefunc_def);
/* Open a Zip file, like unz64Open, but provide a set of file low level API for read/write 64-bit operations */

extern int ZEXPORT agx_unzClose(agx_unzFile file);
/* Close a ZipFile opened with unzOpen. If there is files inside the .Zip opened with unzOpenCurrentFile,
   these files MUST be closed with unzipCloseCurrentFile before call unzipClose.

   return UNZ_OK if there is no error */

extern int ZEXPORT agx_unzGetGlobalInfo(agx_unzFile file, agx_unz_global_info *pglobal_info);
extern int ZEXPORT agx_unzGetGlobalInfo64(agx_unzFile file, agx_unz_global_info64 *pglobal_info);
/* Write info about the ZipFile in the *pglobal_info structure.

   return UNZ_OK if no error */

extern int ZEXPORT agx_unzGetGlobalComment(agx_unzFile file, char *comment, uint16_t comment_size);
/* Get the global comment string of the ZipFile, in the comment buffer.

   uSizeBuf is the size of the szComment buffer.
   return the number of byte copied or an error code <0 */

extern uint64_t ZEXPORT agx_unzCountEntries(const agx_unzFile file);

/***************************************************************************/
/* Reading the content of the current zipfile, you can open it, read data from it, and close it
   (you can close it before reading all the file) */

extern int ZEXPORT agx_unzOpenCurrentFile(agx_unzFile file);
/* Open for reading data the current file in the zipfile.

   return UNZ_OK if no error */

extern int ZEXPORT agx_unzOpenCurrentFilePassword(agx_unzFile file, const char *password);
/* Open for reading data the current file in the zipfile.
   password is a crypting password

   return UNZ_OK if no error */

extern int ZEXPORT agx_unzOpenCurrentFile2(agx_unzFile file, int *method, int *level, int raw);
/* Same as unzOpenCurrentFile, but open for read raw the file (not uncompress)
   if raw==1 *method will receive method of compression, *level will receive level of compression

   NOTE: you can set level parameter as NULL (if you did not want known level,
         but you CANNOT set method parameter as NULL */

extern int ZEXPORT agx_unzOpenCurrentFile3(agx_unzFile file, int *method, int *level, int raw, const char *password);
/* Same as unzOpenCurrentFile, but takes extra parameter password for encrypted files */

extern int ZEXPORT agx_unzReadCurrentFile(agx_unzFile file, voidp buf, uint32_t len);
/* Read bytes from the current file (opened by unzOpenCurrentFile)
   buf contain buffer where data must be copied
   len the size of buf.

   return the number of byte copied if somes bytes are copied
   return 0 if the end of file was reached
   return <0 with error code if there is an error (UNZ_ERRNO for IO error, or zLib error for uncompress error) */

extern int ZEXPORT agx_unzGetCurrentFileInfo(agx_unzFile file, agx_unz_file_info *pfile_info, char *filename,
    uint16_t filename_size, void *extrafield, uint16_t extrafield_size, char *comment, uint16_t comment_size);
extern int ZEXPORT agx_unzGetCurrentFileInfo64(agx_unzFile file, agx_unz_file_info64 *pfile_info, char *filename,
    uint16_t filename_size, void *extrafield, uint16_t extrafield_size, char *comment, uint16_t comment_size);
/* Get Info about the current file

   pfile_info if != NULL, the *pfile_info structure will contain somes info about the current file
   filename if != NULL, the file name string will be copied in filename 
   filename_size is the size of the filename buffer
   extrafield if != NULL, the extra field information from the central header will be copied in to
   extrafield_size is the size of the extraField buffer 
   comment if != NULL, the comment string of the file will be copied in to
   comment_size is the size of the comment buffer */

extern int ZEXPORT agx_unzGetLocalExtrafield(agx_unzFile file, voidp buf, uint32_t len);
/* Read extra field from the current file (opened by unzOpenCurrentFile)
   This is the local-header version of the extra field (sometimes, there is
   more info in the local-header version than in the central-header)

   if buf == NULL, it return the size of the local extra field
   if buf != NULL, len is the size of the buffer, the extra header is copied in buf.

   return number of bytes copied in buf, or (if <0) the error code */

extern int ZEXPORT agx_unzCloseCurrentFile(agx_unzFile file);
/* Close the file in zip opened with unzOpenCurrentFile

   return UNZ_CRCERROR if all the file was read but the CRC is not good */

/***************************************************************************/
/* Browse the directory of the zipfile */

typedef int (*agx_unzFileNameComparer)(agx_unzFile file, const char *filename1, const char *filename2);
typedef int (*agx_unzIteratorFunction)(agx_unzFile file);
typedef int (*agx_unzIteratorFunction2)(agx_unzFile file, agx_unz_file_info64 *pfile_info, char *filename,
    uint16_t filename_size, void *extrafield, uint16_t extrafield_size, char *comment, uint16_t comment_size);

extern int ZEXPORT agx_unzGoToFirstFile(agx_unzFile file);
/* Set the current file of the zipfile to the first file.

   return UNZ_OK if no error */

extern int ZEXPORT agx_unzGoToFirstFile2(agx_unzFile file, agx_unz_file_info64 *pfile_info, char *filename,
    uint16_t filename_size, void *extrafield, uint16_t extrafield_size, char *comment, uint16_t comment_size);
/* Set the current file of the zipfile to the first file and retrieves the current info on success. 
   Not as seek intensive as unzGoToFirstFile + unzGetCurrentFileInfo.

   return UNZ_OK if no error */

extern int ZEXPORT agx_unzGoToNextFile(agx_unzFile file);
/* Set the current file of the zipfile to the next file.

   return UNZ_OK if no error
   return UNZ_END_OF_LIST_OF_FILE if the actual file was the latest */

extern int ZEXPORT agx_unzGoToNextFile2(agx_unzFile file, agx_unz_file_info64 *pfile_info, char *filename,
    uint16_t filename_size, void *extrafield, uint16_t extrafield_size, char *comment, uint16_t comment_size);
/* Set the current file of the zipfile to the next file and retrieves the current 
   info on success. Does less seeking around than unzGotoNextFile + unzGetCurrentFileInfo.

   return UNZ_OK if no error
   return UNZ_END_OF_LIST_OF_FILE if the actual file was the latest */

extern int ZEXPORT agx_unzLocateFile(agx_unzFile file, const char *filename, agx_unzFileNameComparer filename_compare_func);
/* Try locate the file szFileName in the zipfile. For custom filename comparison pass in comparison function.

   return UNZ_OK if the file is found (it becomes the current file)
   return UNZ_END_OF_LIST_OF_FILE if the file is not found */

/***************************************************************************/
/* Raw access to zip file */

typedef struct unz_file_pos_s
{
    uint32_t pos_in_zip_directory;  /* offset in zip file directory */
    uint32_t num_of_file;           /* # of file */
} agx_unz_file_pos;

extern int ZEXPORT agx_unzGetFilePos(agx_unzFile file, agx_unz_file_pos *file_pos);
extern int ZEXPORT agx_unzGoToFilePos(agx_unzFile file, agx_unz_file_pos *file_pos);

typedef struct unz64_file_pos_s
{
    uint64_t pos_in_zip_directory;   /* offset in zip file directory */
    uint64_t num_of_file;            /* # of file */
} agx_unz64_file_pos;

extern int ZEXPORT agx_unzGetFilePos64(agx_unzFile file, agx_unz64_file_pos *file_pos);
extern int ZEXPORT agx_unzGoToFilePos64(agx_unzFile file, const agx_unz64_file_pos *file_pos);

extern int32_t ZEXPORT agx_unzGetOffset(agx_unzFile file);
extern int64_t ZEXPORT agx_unzGetOffset64(agx_unzFile file);
/* Get the current file offset */

extern int ZEXPORT agx_unzSetOffset(agx_unzFile file, uint32_t pos);
extern int ZEXPORT agx_unzSetOffset64(agx_unzFile file, uint64_t pos);
/* Set the current file offset */

extern int32_t ZEXPORT agx_unzTell(agx_unzFile file);
extern int64_t ZEXPORT agx_unzTell64(agx_unzFile file);
/* return current position in uncompressed data */

extern int ZEXPORT agx_unzSeek(agx_unzFile file, uint32_t offset, int origin);
extern int ZEXPORT agx_unzSeek64(agx_unzFile file, uint64_t offset, int origin);
/* Seek within the uncompressed data if compression method is storage */

extern int ZEXPORT agx_unzEndOfFile(agx_unzFile file);
/* return 1 if the end of file was reached, 0 elsewhere */

/***************************************************************************/

#ifdef __cplusplus
}
#endif

#endif /* _UNZ_H */
