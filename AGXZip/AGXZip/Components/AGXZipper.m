//
//  AGXZipper.m
//  AGXZip
//
//  Created by Char Aznable on 2018/5/16.
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

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXZipper.h"
#import "AGXZipCommon.h"
#import "zip.h"
#import "minishared.h"
#import "NSCalendar+AGXZip.h"

typedef void (^AGXZipperProgressHandler)(NSUInteger entryNumber, NSUInteger total);

#define CHUNK 16384

@interface AGXZipper ()
@property (nonatomic, AGX_STRONG)   AGXResources *destinationRoot;
@property (nonatomic, copy)         NSString *zipArchiveName;

@property (nonatomic, assign)       BOOL keepParentDirectory;
@property (nonatomic, assign)       AGXZipperCompressionLevel compressionLevel;
@property (nonatomic, copy)         NSString *password;
@property (nonatomic, assign)       BOOL aes;

@property (nonatomic, copy)         AGXZipperProgressHandler progressHandler;

@property (nonatomic, AGX_STRONG)   AGXResources *source;
@end

@implementation AGXZipper

- (AGX_INSTANCETYPE)initWithDestinationRoot:(AGXResources *)destinationRoot {
    if AGX_EXPECT_T(self = [super init]) {
        _destinationRoot = AGX_RETAIN(destinationRoot);
        _compressionLevel = AGXZipperCompressionLevelDefaultCompression;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_destinationRoot);
    AGX_RELEASE(_zipArchiveName);
    AGX_RELEASE(_password);
    AGX_BLOCK_RELEASE(_progressHandler);
    AGX_RELEASE(_source);
    AGX_SUPER_DEALLOC;
}

- (void)setProgressHandler:(AGXZipperProgressHandler)progressHandler {
    AGXZipperProgressHandler temp = AGX_BLOCK_COPY(progressHandler);
    AGX_BLOCK_RELEASE(_progressHandler);
    _progressHandler = temp;
}

+ (AGX_INSTANCETYPE)zipperWithDestinationRoot:(AGXResources *)destinationRoot {
    return AGX_AUTORELEASE([[self alloc] initWithDestinationRoot:destinationRoot]);
}

#define AGXZipperInitial(name)              \
+ (AGX_INSTANCETYPE)name {                  \
    return [self zipperWithDestinationRoot: \
            AGXResources.name];             \
}

AGXZipperInitial(document)
AGXZipperInitial(caches)
AGXZipperInitial(temporary)

#undef AGXZipperInitial

#define AGXZipperSetter(type, method, property) \
- (AGXZipper *(^)(type))method {                \
    return AGX_BLOCK_AUTORELEASE                \
    (^AGXZipper *(type property) {              \
        self.property = property;               \
        return self;                            \
    });                                         \
}

AGXZipperSetter(NSString *,                 zipArchiveNamed,        zipArchiveName)
AGXZipperSetter(BOOL,                       keepParentDirectoryAs,  keepParentDirectory)
AGXZipperSetter(AGXZipperCompressionLevel,  compressionLevelAs,     compressionLevel)
AGXZipperSetter(NSString *,                 passwordAs,             password)
AGXZipperSetter(BOOL,                       aesAs,                  aes)
AGXZipperSetter(AGXZipperProgressHandler,   progressHandleWith,     progressHandler)
AGXZipperSetter(AGXResources *,             sourceAs,               source)

#undef AGXZipperSetter

- (BOOL (^)(void))zip {
    return AGX_BLOCK_AUTORELEASE(^BOOL (void) {
        return [self doZip];
    });
}

- (BOOL (^)(AGXResources *))zipFrom {
    return AGX_BLOCK_AUTORELEASE(^BOOL (AGXResources *source) {
        return [self.sourceAs(source) doZip];
    });
}

#pragma mark - private methods

- (NSString *)zipArchiveFilePath {
    return(_destinationRoot && _zipArchiveName ?
           _destinationRoot.pathWithFileNamed(_zipArchiveName) : nil);
}

- (BOOL)doZip {
    NSString *path = [self zipArchiveFilePath];
    // Guard against empty strings
    BOOL isDirectory = NO;
    if (!path.length || !_source.path.length || !_source.isExists(&isDirectory)) return NO;

    _destinationRoot.createPathOfFileNamed(_zipArchiveName);
    agx_zipFile zip = agx_zipOpen(path.fileSystemRepresentation, AGX_APPEND_STATUS_CREATE);
    if (!zip) return NO;

    BOOL success = YES;
    if (!isDirectory) {
        success &= [self write:zip withFileAtPath:_source.path fileName:nil
              compressionLevel:_compressionLevel password:_password AES:_aes];
        !_progressHandler ?: _progressHandler(1, 1);

    } else {
        NSArray<NSString *> *subpaths = _source.subpaths;
        NSUInteger total = subpaths.count, complete = 0;
        if (total > 0) {
            for (NSString *subpath in subpaths) {
                NSString *filePath = _source.pathWithNamed(subpath);
                NSString *fileName = _keepParentDirectory ?
                [_source.path.lastPathComponent stringByAppendingPathComponent:subpath] : subpath;
                if (_source.isExistsDirectoryNamed(subpath)) {
                    if (_source.subpathsInDirectoryNamed(subpath).count == 0) {
                        success &= [self write:zip withFolderAtPath:filePath
                                    folderName:fileName password:_password];
                    }
                } else {
                    success &= [self write:zip withFileAtPath:filePath fileName:fileName
                          compressionLevel:_compressionLevel password:_password AES:_aes];
                }
                complete++;
                !_progressHandler ?: _progressHandler(complete, total);
            }
        }
    }

    NSAssert((zip != NULL), @"[AGXZipper] Attempting to close an archive which was never opened");
    int error = agx_zipClose(zip, NULL);
    return success & (error == AGX_ZIP_OK);
}

- (BOOL)write:(agx_zipFile)zip withFileAtPath:(NSString *)path fileName:(NSString *)fileName compressionLevel:(AGXZipperCompressionLevel)compressionLevel password:(NSString *)password AES:(BOOL)aes {
    NSAssert((zip != NULL), @"Attempting to write to an archive which was never opened");

    FILE *input = fopen(path.fileSystemRepresentation, "r");
    if (!input) return NO;

    if (!fileName) fileName = path.lastPathComponent;
    agx_zip_fileinfo zipInfo = {};
    [self zipInfo:&zipInfo setAttributesOfItemAtPath:path];

    void *buffer = malloc(CHUNK);
    if (!buffer) {
        fclose(input);
        return NO;
    }

    int error = [self zipOpenEntry:zip withName:fileName fileinfo:&zipInfo
                             level:compressionLevel password:password aes:aes];
    while (!feof(input) && !ferror(input)) {
        unsigned int len = (unsigned int)fread(buffer, 1, CHUNK, input);
        agx_zipWriteInFileInZip(zip, buffer, len);
    }

    agx_zipCloseFileInZip(zip);
    free(buffer);
    fclose(input);
    return error == AGX_ZIP_OK;
}

- (BOOL)write:(agx_zipFile)zip withFolderAtPath:(NSString *)path folderName:(NSString *)folderName password:(NSString *)password {
    NSAssert((zip != NULL), @"Attempting to write to an archive which was never opened");

    agx_zip_fileinfo zipInfo = {};
    [self zipInfo:&zipInfo setAttributesOfItemAtPath:path];

    int error = [self zipOpenEntry:zip withName:[folderName stringByAppendingString:@"/"] fileinfo:&zipInfo
                             level:AGXZipperCompressionLevelNoCompression password:password aes:NO];
    const void *buffer = NULL;
    agx_zipWriteInFileInZip(zip, buffer, 0);
    agx_zipCloseFileInZip(zip);
    return error == AGX_ZIP_OK;
}

- (void)zipInfo:(agx_zip_fileinfo *)zipInfo setAttributesOfItemAtPath:(NSString *)path {
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error: nil];
    if (!attr) return;

    NSDate *fileDate = (NSDate *)attr[NSFileModificationDate];
    if (fileDate) [self zipInfo:zipInfo setDate:fileDate];

    // Write permissions into the external attributes, for details on this see here: http://unix.stackexchange.com/a/14727
    // Get the permissions value from the files attributes
    NSNumber *permissionsValue = (NSNumber *)attr[NSFilePosixPermissions];
    if (permissionsValue) {
        // Get the short value for the permissions
        short permissionsShort = permissionsValue.shortValue;

        // Convert this into an octal by adding 010000, 010000 being the flag for a regular file
        NSInteger permissionsOctal = 0100000 + permissionsShort;

        // Convert this into a long value
        uLong permissionsLong = @(permissionsOctal).unsignedLongValue;

        // Store this into the external file attributes once it has been shifted 16 places left to form part of the second from last byte

        // Casted back to an unsigned int to match type of external_fa in minizip
        zipInfo->external_fa = (unsigned int)(permissionsLong << 16L);
    }
}

- (void)zipInfo:(agx_zip_fileinfo *)zipInfo setDate:(NSDate *)date {
    NSCalendarUnit flags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                            NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSDateComponents *components = [NSCalendar.gregorianCalendar components:flags fromDate:date];
    struct tm tmz_date;
    tmz_date.tm_sec = (unsigned int)components.second;
    tmz_date.tm_min = (unsigned int)components.minute;
    tmz_date.tm_hour = (unsigned int)components.hour;
    tmz_date.tm_mday = (unsigned int)components.day;
    // ISO/IEC 9899 struct tm is 0-indexed for January but NSDateComponents for gregorianCalendar is 1-indexed for January
    tmz_date.tm_mon = (unsigned int)components.month - 1;
    // ISO/IEC 9899 struct tm is 0-indexed for AD 1900 but NSDateComponents for gregorianCalendar is 1-indexed for AD 1
    tmz_date.tm_year = (unsigned int)components.year - 1900;
    zipInfo->dos_date = agx_tm_to_dosdate(&tmz_date);
}

- (int)zipOpenEntry:(agx_zipFile)zip withName:(NSString *)name fileinfo:(const agx_zip_fileinfo *)zip_fileinfo level:(AGXZipperCompressionLevel)level password:(NSString *)password aes:(BOOL)aes {
    return agx_zipOpenNewFileInZip5(zip, name.fileSystemRepresentation, zip_fileinfo, NULL, 0, NULL, 0, NULL, 0, 0, Z_DEFLATED, level, 0, -MAX_WBITS, AGX_DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, password.UTF8String, aes, 798);
}

@end
