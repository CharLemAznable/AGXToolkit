//
//  minishared.h
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

#ifndef _AGX_MINISHARED_H
#define _AGX_MINISHARED_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
#  define AGX_MKDIR(d) _mkdir(d)
#  define AGX_CHDIR(d) _chdir(d)
#else
#  define AGX_MKDIR(d) mkdir(d, 0775)
#  define AGX_CHDIR(d) chdir(d)
#endif

/***************************************************************************/

/* Get a file's date and time in dos format */
uint32_t agx_get_file_date(const char *path, uint32_t *dos_date);

/* Sets a file's date and time in dos format */
void agx_change_file_date(const char *path, uint32_t dos_date);

/* Convert dos date/time format to struct tm */
int agx_dosdate_to_tm(uint64_t dos_date, struct tm *ptm);

/* Convert dos date/time format to time_t */
time_t agx_dosdate_to_time_t(uint64_t dos_date);

/* Convert struct tm to dos date/time format */
uint32_t agx_tm_to_dosdate(const struct tm *ptm);

/* Create a directory and all subdirectories */
int agx_makedir(const char *newdir);

/* Check to see if a file exists */
int agx_check_file_exists(const char *path);

/* Check to see if a file is over 4GB and needs ZIP64 extension */
int agx_is_large_file(const char *path);

/* Print a 64-bit number for compatibility */
void agx_display_zpos64(uint64_t n, int size_char);

/***************************************************************************/

#ifdef __cplusplus
}
#endif

#endif /* _MINISHARED_H */
