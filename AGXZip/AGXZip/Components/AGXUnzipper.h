//
//  AGXUnzipper.h
//  AGXZip
//
//  Created by Char Aznable on 2018/5/12.
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

#ifndef AGXZip_AGXUnzipper_h
#define AGXZip_AGXUnzipper_h

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXResources.h>
#import "AGXZipCommon.h"

AGX_EXTERN NSString *const AGXUnzipperErrorDomain;

typedef NS_ENUM(NSInteger, AGXUnzipperErrorCode) {
    AGXUnzipperErrorCodeFailedOpenZipFile       = -1,
    AGXUnzipperErrorCodeFailedOpenFileInZip     = -2,
    AGXUnzipperErrorCodeFileInfoNotLoadable     = -3,
    AGXUnzipperErrorCodeFileContentNotReadable  = -4,
    AGXUnzipperErrorCodeFailedToWriteFile       = -5,
    AGXUnzipperErrorCodeInvalidArguments        = -6,
};

@protocol AGXUnzipperDelegate;

@interface AGXUnzipper : NSObject
+ (AGX_INSTANCETYPE)application;
+ (AGX_INSTANCETYPE)document;
+ (AGX_INSTANCETYPE)caches;
+ (AGX_INSTANCETYPE)temporary;

- (AGXUnzipper *(^)(NSString *))unzipArchiveNamed;

- (AGXUnzipper *(^)(BOOL))preserveAttributesAs;
- (AGXUnzipper *(^)(BOOL))overwriteAs;
- (AGXUnzipper *(^)(NSInteger))nestedZipLevelAs;
- (AGXUnzipper *(^)(NSString *))passwordAs;

- (AGXUnzipper *(^)(id<AGXUnzipperDelegate>))delegateTo;
- (AGXUnzipper *(^)(void (^)(NSString *entry, agx_unz_file_info zipInfo, long entryNumber, long total)))progressHandleWith;
- (AGXUnzipper *(^)(void (^)(NSString *path, BOOL succeeded, NSError *error)))completionHandleWith;

- (AGXUnzipper *(^)(AGXResources *))destinationAs;

- (BOOL (^)(void))isPasswordProtected;
- (BOOL (^)(NSString *))isPasswordValid;

- (BOOL (^)(void))unzip;
- (BOOL (^)(AGXResources *))unzipTo;

@property (nonatomic, AGX_STRONG, readonly) NSError *error;
@end

@protocol AGXUnzipperDelegate <NSObject>
@optional
- (void)unzipperWillUnzipArchiveAtPath:(NSString *)path zipInfo:(agx_unz_global_info)zipInfo;
- (void)unzipperDidUnzipArchiveAtPath:(NSString *)path zipInfo:(agx_unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath;

- (BOOL)unzipperShouldUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo;
- (void)unzipperWillUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo;
- (void)unzipperDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo;
- (void)unzipperDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath;

- (void)unzipperProgressEvent:(unsigned long long)loaded total:(unsigned long long)total;
@end

#endif /* AGXZip_AGXUnzipper_h */
