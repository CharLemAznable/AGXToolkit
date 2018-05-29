//
//  AGXUnzipper.m
//  AGXZip
//
//  Created by Char Aznable on 2018/5/12.
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

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXUnzipper.h"
#import "unzip.h"
#import "zip.h"
#import "NSData+AGXZip.h"
#import "NSCalendar+AGXZip.h"

NSString *const AGXUnzipperErrorDomain = @"AGXUnzipperErrorDomain";

typedef void (^AGXUnzipperProgressHandler)(NSString *entry, agx_unz_file_info zipInfo, long entryNumber, long total);
typedef void (^AGXUnzipperCompletionHandler)(NSString *path, BOOL succeeded, NSError *error);

@interface AGXUnzipper ()
@property (nonatomic, AGX_STRONG)   AGXResources *sourceRoot;
@property (nonatomic, copy)         NSString *unzipArchiveName;

@property (nonatomic, assign)       BOOL preserveAttributes;
@property (nonatomic, assign)       BOOL overwrite;
@property (nonatomic, assign)       NSInteger nestedZipLevel;
@property (nonatomic, copy)         NSString *password;

@property (nonatomic, AGX_WEAK)     id<AGXUnzipperDelegate> delegate;
@property (nonatomic, copy)         AGXUnzipperProgressHandler progressHandler;
@property (nonatomic, copy)         AGXUnzipperCompletionHandler completionHandler;

@property (nonatomic, AGX_STRONG)   AGXResources *destination;
@property (nonatomic, AGX_STRONG)   NSError *error;
@end

@implementation AGXUnzipper

- (AGX_INSTANCETYPE)initWithSourceRoot:(AGXResources *)sourceRoot {
    if AGX_EXPECT_T(self = [super init]) {
        _sourceRoot = AGX_RETAIN(sourceRoot);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_sourceRoot);
    AGX_RELEASE(_unzipArchiveName);
    AGX_RELEASE(_password);
    _delegate = nil;
    AGX_BLOCK_RELEASE(_progressHandler);
    AGX_BLOCK_RELEASE(_completionHandler);
    AGX_RELEASE(_destination);
    AGX_RELEASE(_error);
    AGX_SUPER_DEALLOC;
}

- (void)setProgressHandler:(AGXUnzipperProgressHandler)progressHandler {
    AGXUnzipperProgressHandler temp = AGX_BLOCK_COPY(progressHandler);
    AGX_BLOCK_RELEASE(_progressHandler);
    _progressHandler = temp;
}

- (void)setCompletionHandler:(AGXUnzipperCompletionHandler)completionHandler {
    AGXUnzipperCompletionHandler temp = AGX_BLOCK_COPY(completionHandler);
    AGX_BLOCK_RELEASE(_completionHandler);
    _completionHandler = temp;
}

+ (AGX_INSTANCETYPE)unzipperWithSourceRoot:(AGXResources *)sourceRoot {
    return AGX_AUTORELEASE([[self alloc] initWithSourceRoot:sourceRoot]);
}

#define AGXUnzipperInitial(name)        \
+ (AGX_INSTANCETYPE)name {              \
    return [self unzipperWithSourceRoot:\
            AGXResources.name];         \
}

AGXUnzipperInitial(application)
AGXUnzipperInitial(document)
AGXUnzipperInitial(caches)
AGXUnzipperInitial(temporary)

#undef AGXUnzipperInitial

#define AGXUnzipperSetter(type, method, property)   \
- (AGXUnzipper *(^)(type))method {                  \
    return AGX_BLOCK_AUTORELEASE                    \
    (^AGXUnzipper *(type property) {                \
        self.property = property;                   \
        return self;                                \
    });                                             \
}

AGXUnzipperSetter(NSString *,                   unzipArchiveNamed,      unzipArchiveName)
AGXUnzipperSetter(BOOL,                         preserveAttributesAs,   preserveAttributes)
AGXUnzipperSetter(BOOL,                         overwriteAs,            overwrite)
AGXUnzipperSetter(NSInteger,                    nestedZipLevelAs,       nestedZipLevel)
AGXUnzipperSetter(NSString *,                   passwordAs,             password)
AGXUnzipperSetter(id<AGXUnzipperDelegate>,      delegateTo,             delegate)
AGXUnzipperSetter(AGXUnzipperProgressHandler,   progressHandleWith,     progressHandler)
AGXUnzipperSetter(AGXUnzipperCompletionHandler, completionHandleWith,   completionHandler)
AGXUnzipperSetter(AGXResources *,               destinationAs,          destination)

#undef AGXUnzipperSetter

- (BOOL (^)(void))isPasswordProtected {
    return AGX_BLOCK_AUTORELEASE(^BOOL (void) {
        return [self indicatePassword];
    });
}

- (BOOL (^)(NSString *))isPasswordValid {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *password) {
        return [self.passwordAs(password) validatePassword];
    });
}

- (BOOL (^)(void))unzip {
    return AGX_BLOCK_AUTORELEASE(^BOOL (void) {
        return [self doUnzip];
    });
}

- (BOOL (^)(AGXResources *))unzipTo {
    return AGX_BLOCK_AUTORELEASE(^BOOL (AGXResources *destination) {
        return [self.destinationAs(destination) doUnzip];
    });
}

#pragma mark - private methods

- (NSString *)unzipArchiveFilePath {
    return(_sourceRoot && _unzipArchiveName ?
           _sourceRoot.pathWithFileNamed(_unzipArchiveName) : nil);
}

- (BOOL)indicatePassword {
    NSString *path = [self unzipArchiveFilePath];
    // Guard against empty strings
    if (!path.length) return NO;

    // Begin opening
    agx_zipFile zip = agx_unzOpen(path.fileSystemRepresentation);
    if (!zip) return NO;

    int ret = agx_unzGoToFirstFile(zip);
    if (ret == AGX_UNZ_OK) {
        do {
            ret = agx_unzOpenCurrentFile(zip);
            if (ret != AGX_UNZ_OK) {
                // attempting with an arbitrary password to
                //  workaround `unzOpenCurrentFile` limitation on AES encrypted files
                ret = agx_unzOpenCurrentFilePassword(zip, "");
                agx_unzCloseCurrentFile(zip);
                if (ret == AGX_UNZ_OK || ret == AGX_UNZ_BADPASSWORD) {
                    return YES;
                }
                return NO;
            }
            agx_unz_file_info fileInfo = {};
            ret = agx_unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            agx_unzCloseCurrentFile(zip);
            if (ret != AGX_UNZ_OK) {
                return NO;
            } else if ((fileInfo.flag & 1) == 1) {
                return YES;
            }

            ret = agx_unzGoToNextFile(zip);
        } while (ret == AGX_UNZ_OK);
    }
    return NO;
}

- (BOOL)validatePassword {
    NSString *path = [self unzipArchiveFilePath];
    // Guard against empty strings
    if (!path.length) {
        self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                      AGXUnzipperErrorCodeInvalidArguments userInfo:
                      @{NSLocalizedDescriptionKey: @"received invalid argument(s)"}];
        return NO;
    }

    // Begin opening
    agx_zipFile zip = agx_unzOpen(path.fileSystemRepresentation);
    if (!zip) {
        self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                      AGXUnzipperErrorCodeFailedOpenZipFile userInfo:
                      @{NSLocalizedDescriptionKey: @"failed to open zip file"}];
        return NO;
    }

    int ret = agx_unzGoToFirstFile(zip);
    if (ret == AGX_UNZ_OK) {
        do {
            ret = (!_password ? agx_unzOpenCurrentFile(zip) :
                   agx_unzOpenCurrentFilePassword(zip, _password.UTF8String));//[_password cStringUsingEncoding:NSUTF8StringEncoding]
            if (ret != AGX_UNZ_OK) {
                if (ret != AGX_UNZ_BADPASSWORD) {
                    self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                                  AGXUnzipperErrorCodeFailedOpenFileInZip userInfo:
                                  @{NSLocalizedDescriptionKey: @"failed to open first file in zip file"}];
                }
                return NO;
            }
            agx_unz_file_info fileInfo = {};
            ret = agx_unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if (ret != AGX_UNZ_OK) {
                self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                              AGXUnzipperErrorCodeFileInfoNotLoadable userInfo:
                              @{NSLocalizedDescriptionKey: @"failed to retrieve info for file"}];
                return NO;

            } else if ((fileInfo.flag & 1) == 1) {
                unsigned char buffer[10] = {0};
                int readBytes = agx_unzReadCurrentFile(zip, buffer, (unsigned)MIN(10UL,fileInfo.uncompressed_size));
                if (readBytes < 0) {
                    // Let's assume error Z_DATA_ERROR is caused by an invalid password
                    // Let's assume other errors are caused by Content Not Readable
                    if (readBytes != Z_DATA_ERROR) {
                        self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                                      AGXUnzipperErrorCodeFileContentNotReadable userInfo:
                                      @{NSLocalizedDescriptionKey: @"failed to read contents of file entry"}];
                    }
                    return NO;
                }
                return YES;
            }

            agx_unzCloseCurrentFile(zip);
            ret = agx_unzGoToNextFile(zip);
        } while (ret == AGX_UNZ_OK);
    }

    // No password required
    return YES;
}

- (BOOL)doUnzip {
    NSString *path = [self unzipArchiveFilePath];
    // Guard against empty strings
    if (!path.length || !_destination.path.length) {
        self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                      AGXUnzipperErrorCodeInvalidArguments userInfo:
                      @{NSLocalizedDescriptionKey: @"received invalid argument(s)"}];
        !_completionHandler ?: _completionHandler(nil, NO, _error);
        return NO;
    }

    // Begin opening
    agx_zipFile zip = agx_unzOpen(path.fileSystemRepresentation);
    if (!zip) {
        self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                      AGXUnzipperErrorCodeFailedOpenZipFile userInfo:
                      @{NSLocalizedDescriptionKey: @"failed to open zip file"}];
        !_completionHandler ?: _completionHandler(nil, NO, _error);
        return NO;
    }

    NSDictionary *fileAttributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:nil];
    unsigned long long fileSize = [fileAttributes[NSFileSize] unsignedLongLongValue];
    unsigned long long currentPosition = 0;
    agx_unz_global_info globalInfo = {};
    agx_unzGetGlobalInfo(zip, &globalInfo);

    // Begin unzipping
    int ret = 0;
    ret = agx_unzGoToFirstFile(zip);
    if (ret != AGX_UNZ_OK && ret != AGX_UNZ_END_OF_LIST_OF_FILE) {
        self.error = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                      AGXUnzipperErrorCodeFailedOpenFileInZip userInfo:
                      @{NSLocalizedDescriptionKey: @"failed to open first file in zip file"}];
        !_completionHandler ?: _completionHandler(nil, NO, _error);
        return NO;
    }

    BOOL success = YES;
    BOOL canceled = NO;
    int crc_ret = 0;
    unsigned char buffer[4096] = {0};
    NSMutableArray<NSDictionary *> *directoriesModificationDates = NSMutableArray.instance;

    // Message delegate
    if ([_delegate respondsToSelector:@selector(unzipperWillUnzipArchiveAtPath:zipInfo:)]) {
        [_delegate unzipperWillUnzipArchiveAtPath:path zipInfo:globalInfo];
    }
    if ([_delegate respondsToSelector:@selector(unzipperProgressEvent:total:)]) {
        [_delegate unzipperProgressEvent:currentPosition total:fileSize];
    }

    NSInteger currentFileNumber = -1;
    NSError *unzippingError = nil;
    do {
        currentFileNumber++;
        if (ret == AGX_UNZ_END_OF_LIST_OF_FILE) break;

        @autoreleasepool {
            ret = (!_password ? agx_unzOpenCurrentFile(zip) :
                   agx_unzOpenCurrentFilePassword(zip, _password.UTF8String));
            if (ret != AGX_UNZ_OK) {
                unzippingError = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                                  AGXUnzipperErrorCodeFailedOpenFileInZip userInfo:
                                  @{NSLocalizedDescriptionKey: @"failed to open file in zip file"}];
                success = NO;
                break;
            }

            // Reading data and write to file
            agx_unz_file_info fileInfo;
            memset(&fileInfo, 0, sizeof(agx_unz_file_info));
            ret = agx_unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if (ret != AGX_UNZ_OK) {
                unzippingError = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                                  AGXUnzipperErrorCodeFileInfoNotLoadable userInfo:
                                  @{NSLocalizedDescriptionKey: @"failed to retrieve info for file"}];
                success = NO;
                agx_unzCloseCurrentFile(zip);
                break;
            }

            currentPosition += fileInfo.compressed_size;

            // Message delegate
            if ([_delegate respondsToSelector:@selector(unzipperShouldUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
                BOOL should = [_delegate unzipperShouldUnzipFileAtIndex:currentFileNumber totalFiles:
                               (NSInteger)globalInfo.number_entry archivePath:path fileInfo:fileInfo];
                if (!should) { success = NO; canceled = YES; break; }
            }
            if ([_delegate respondsToSelector:@selector(unzipperWillUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
                [_delegate unzipperWillUnzipFileAtIndex:currentFileNumber totalFiles:
                 (NSInteger)globalInfo.number_entry archivePath:path fileInfo:fileInfo];
            }
            if ([_delegate respondsToSelector:@selector(unzipperProgressEvent:total:)]) {
                [_delegate unzipperProgressEvent:(NSInteger)currentPosition total:(NSInteger)fileSize];
            }

            char *filename = (char *)malloc(fileInfo.size_filename + 1);
            if (!filename) { success = NO; break; }

            agx_unzGetCurrentFileInfo(zip, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
            filename[fileInfo.size_filename] = '\0';

            BOOL fileIsSymbolicLink = [self isSymbolicLinkFile:&fileInfo];
            NSString *strPath = [self filenameStringWithCString:filename version_made_by:fileInfo.version
                                           general_purpose_flag:fileInfo.flag size:fileInfo.size_filename];
            if ([strPath hasPrefix:@"__MACOSX/"]) {
                // ignoring resource forks: https://superuser.com/questions/104500/what-is-macosx-folder
                agx_unzCloseCurrentFile(zip);
                ret = agx_unzGoToNextFile(zip);
                free(filename);
                continue;
            }
            if (!strPath.length) {
                // if filename data is unsalvageable, we default to currentFileNumber
                strPath = @(currentFileNumber).stringValue;
            }

            // Check if it contains directory
            BOOL isDirectory = NO;
            if (filename[fileInfo.size_filename-1] == '/' || filename[fileInfo.size_filename-1] == '\\') {
                isDirectory = YES;
            }
            free(filename);

            // Contains a path
            if ([strPath containsCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]]) {
                strPath = [strPath stringByReplacingString:@"\\" withString:@"/"];
            }

            NSString *fullPath = _destination.pathWithFileNamed(strPath);
            NSError *err = nil;
            NSDictionary *directoryAttr = nil;
            if (_preserveAttributes) {
                NSDate *modDate = [self dateWithMSDOSFormat:(UInt32)fileInfo.dos_date];
                directoryAttr = @{NSFileCreationDate: modDate, NSFileModificationDate: modDate};
                [directoriesModificationDates addObject: @{@"path": strPath, @"modDate": modDate}];
            }
            if (isDirectory) {
                _destination.createExtDirectoryNamed(strPath, directoryAttr, &err);
            } else {
                _destination.createExtPathOfFileNamed(strPath, directoryAttr, &err);
            }
            if (err) {
                if ([err.domain isEqualToString:NSCocoaErrorDomain] && err.code == 640) {
                    unzippingError = err;
                    agx_unzCloseCurrentFile(zip);
                    success = NO;
                    break;
                }
                AGXLog(@"[AGXUnzipper] Error: %@", err.localizedDescription);
            }

            if (_destination.isExistsNamed(strPath, nil) && !isDirectory && !_overwrite) {
                //FIXME: couldBe CRC Check?
                agx_unzCloseCurrentFile(zip);
                ret = agx_unzGoToNextFile(zip);
                continue;
            }

            if (!fileIsSymbolicLink) {
                // ensure we are not creating stale file entries
                int readBytes = agx_unzReadCurrentFile(zip, buffer, 4096);
                if (readBytes >= 0) {
                    FILE *fp = fopen(fullPath.fileSystemRepresentation, "wb");
                    while (fp) {
                        if (readBytes > 0) {
                            if (0 == fwrite(buffer, readBytes, 1, fp)) {
                                if (ferror(fp)) {
                                    NSString *message = @"Failed to write file (check your free space)";
                                    AGXLog(@"[AGXUnzipper] %@", message);
                                    success = NO;
                                    unzippingError = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                                                      AGXUnzipperErrorCodeFailedToWriteFile userInfo:
                                                      @{NSLocalizedDescriptionKey: message}];
                                    break;
                                }
                            }
                        } else {
                            break;
                        }
                        readBytes = agx_unzReadCurrentFile(zip, buffer, 4096);
                        if (readBytes < 0) {
                            // Let's assume error Z_DATA_ERROR is caused by an invalid password
                            // Let's assume other errors are caused by Content Not Readable
                            success = NO;
                        }
                    }

                    if (fp) {
                        fclose(fp);

                        if (_nestedZipLevel && [strPath.pathExtension.lowercaseString isEqualToString:@"zip"] &&
                            [AGXUnzipper unzipperWithSourceRoot:_destination].unzipArchiveNamed(strPath)
                            .preserveAttributesAs(_preserveAttributes).overwriteAs(_overwrite)
                            .nestedZipLevelAs(_nestedZipLevel-1).passwordAs(_password)
                            .unzipTo(_destination.subpathAppend(strPath.stringByDeletingLastPathComponent))) {
                            [directoriesModificationDates removeLastObject];
                            _destination.removeFileNamed(strPath);

                        } else if (_preserveAttributes) {
                            // Set the original datetime property
                            if (fileInfo.dos_date != 0) {
                                if (!_destination.setAttributesWithNamed
                                    (strPath, @{NSFileModificationDate: [self dateWithMSDOSFormat:(UInt32)fileInfo.dos_date]})) {
                                    // Can't set attributes
                                    AGXLog(@"[AGXUnzipper] Failed to set attributes - whilst setting modification date");
                                }
                            }

                            // Set the original permissions on the file (+read/write to solve #293)
                            uLong permissions = fileInfo.external_fa >> 16 | 0b110000000;
                            if (permissions != 0) {
                                // Retrieve any existing attributes
                                NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:
                                                              _destination.attributesWithNamed(strPath)];

                                // Set the value in the attributes dict
                                attrs[NSFilePosixPermissions] = @(permissions);

                                // Update attributes
                                if (!_destination.setAttributesWithNamed(strPath, attrs)) {
                                    // Unable to set the permissions attribute
                                    AGXLog(@"[AGXUnzipper] Failed to set attributes - whilst setting permissions");
                                }
                            }
                        }
                    } else {
                        // if we couldn't open file descriptor we can validate global errno to see the reason
                        if (errno == ENOSPC) {
                            unzippingError = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
                            agx_unzCloseCurrentFile(zip);
                            success = NO;
                            break;
                        }
                    }
                } else {
                    // Let's assume error Z_DATA_ERROR is caused by an invalid password
                    // Let's assume other errors are caused by Content Not Readable
                    success = NO;
                    break;
                }
            } else {
                // Assemble the path for the symbolic link
                NSMutableString *destinationPath = [NSMutableString string];
                int bytesRead = 0;
                while ((bytesRead = agx_unzReadCurrentFile(zip, buffer, 4096)) > 0) {
                    buffer[bytesRead] = 0;
                    [destinationPath appendString:@((const char *)buffer)];
                }
                if (bytesRead < 0) {
                    // Let's assume error Z_DATA_ERROR is caused by an invalid password
                    // Let's assume other errors are caused by Content Not Readable
                    success = NO;
                    break;
                }

                // Check if the symlink exists and delete it if we're overwriting
                if (_overwrite) {
                    if (_destination.isExistsNamed(strPath, nil)) {
                        NSError *error = nil;
                        BOOL removeSuccess = _destination.removeExtNamed(strPath, &error);
                        if (!removeSuccess) {
                            NSString *message = [NSString stringWithFormat:
                                                 @"Failed to delete existing symbolic link at \"%@\"",
                                                 error.localizedDescription];
                            AGXLog(@"[AGXUnzipper] %@", message);
                            success = NO;
                            unzippingError = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                                              error.code userInfo:@{NSLocalizedDescriptionKey: message}];
                        }
                    }
                }

                // Create the symbolic link (making sure it stays relative if it was relative before)
                int symlinkError = symlink([destinationPath cStringUsingEncoding:NSUTF8StringEncoding],
                                           [fullPath cStringUsingEncoding:NSUTF8StringEncoding]);

                if (symlinkError != 0) {
                    // Bubble the error up to the completion handler
                    NSString *message = [NSString stringWithFormat:
                                         @"Failed to create symbolic link at \"%@\" to \"%@\" - symlink() error code: %d",
                                         fullPath, destinationPath, errno];
                    AGXLog(@"[AGXUnzipper] %@", message);
                    success = NO;
                    unzippingError = [NSError errorWithDomain:NSPOSIXErrorDomain code:
                                      symlinkError userInfo:@{NSLocalizedDescriptionKey: message}];
                }
            }

            crc_ret = agx_unzCloseCurrentFile(zip);
            if (crc_ret == AGX_UNZ_CRCERROR) {
                // CRC ERROR
                success = NO;
                break;
            }
            ret = agx_unzGoToNextFile(zip);

            // Message delegate
            if ([_delegate respondsToSelector:@selector(unzipperDidUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
                [_delegate unzipperDidUnzipFileAtIndex:currentFileNumber totalFiles:
                 (NSInteger)globalInfo.number_entry archivePath:path fileInfo:fileInfo];
            } else if ([_delegate respondsToSelector: @selector(unzipperDidUnzipFileAtIndex:totalFiles:archivePath:unzippedFilePath:)]) {
                [_delegate unzipperDidUnzipFileAtIndex:currentFileNumber totalFiles:
                 (NSInteger)globalInfo.number_entry archivePath:path unzippedFilePath:fullPath];
            }

            !_progressHandler ?: _progressHandler(strPath, fileInfo, currentFileNumber, globalInfo.number_entry);
        }
    } while (ret == AGX_UNZ_OK && success);

    // Close
    agx_unzClose(zip);

    // The process of decompressing the .zip archive causes the modification times on the folders
    // to be set to the present time. So, when we are done, they need to be explicitly set.
    // set the modification date on all of the directories.
    if (success && _preserveAttributes) {
        NSError *err = nil;
        for (NSDictionary *d in directoriesModificationDates) {
            NSString *path = d[@"path"];
            if (!_destination.setAttributesExtWithNamed(path, @{NSFileModificationDate: d[@"modDate"]}, &err)) {
                AGXLog(@"[AGXUnzipper] Set attributes failed for directory: %@.", _destination.pathWithNamed(path));
            }
            if (err) {
                AGXLog(@"[AGXUnzipper] Error setting directory file modification date attribute: %@", err.localizedDescription);
            }
        }
    }

    // Message delegate
    if (success && [_delegate respondsToSelector:@selector(unzipperDidUnzipArchiveAtPath:zipInfo:unzippedPath:)]) {
        [_delegate unzipperDidUnzipArchiveAtPath:path zipInfo:globalInfo unzippedPath:_destination.path];
    }
    // final progress event = 100%
    if (!canceled && [_delegate respondsToSelector:@selector(unzipperProgressEvent:total:)]) {
        [_delegate unzipperProgressEvent:fileSize total:fileSize];
    }

    NSError *retErr = nil;
    if (crc_ret == AGX_UNZ_CRCERROR) {
        retErr = [NSError errorWithDomain:AGXUnzipperErrorDomain code:
                  AGXUnzipperErrorCodeFileInfoNotLoadable userInfo:
                  @{NSLocalizedDescriptionKey: @"crc check failed for file"}];
    }

    self.error = unzippingError ?: retErr;
    !_completionHandler ?: _completionHandler(path, success, _error);
    return success;
}

- (BOOL)isSymbolicLinkFile:(const agx_unz_file_info *)fileInfo {
    // Determine whether this is a symbolic link:
    // - File is stored with 'version made by' value of UNIX (3),
    //   as per http://www.pkware.com/documents/casestudies/APPNOTE.TXT
    //   in the upper byte of the version field.
    // - BSD4.4 st_mode constants are stored in the high 16 bits of the
    //   external file attributes (defacto standard, verified against libarchive)
    //
    // The original constants can be found here:
    //    http://minnie.tuhs.org/cgi-bin/utree.pl?file=4.4BSD/usr/include/sys/stat.h
    //
    const uLong ZipUNIXVersion = 3;
    const uLong BSD_SFMT = 0170000;
    const uLong BSD_IFLNK = 0120000;
    return((ZipUNIXVersion == (fileInfo->version >> 8)) &&
           (BSD_IFLNK == (BSD_SFMT & (fileInfo->external_fa >> 16))));
}

- (NSString *)filenameStringWithCString:(const char *)filename version_made_by:(uint16_t)version_made_by general_purpose_flag:(uint16_t)flag size:(uint16_t)size_filename {
    // Respect Language encoding flag only reading filename as UTF-8 when this is set
    // when file entry created on dos system.
    //
    // https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT
    //   Bit 11: Language encoding flag (EFS).  If this bit is set,
    //           the filename and comment fields for this file
    //           MUST be encoded using UTF-8. (see APPENDIX D)
    uint16_t made_by = version_made_by >> 8;
    BOOL made_on_dos = made_by == 0;
    BOOL languageEncoding = (flag & (1 << 11)) != 0;
    if (!languageEncoding && made_on_dos) {
        // APPNOTE.TXT D.1:
        //   D.2 If general purpose bit 11 is unset, the file name and comment should conform
        //   to the original ZIP character encoding.  If general purpose bit 11 is set, the
        //   filename and comment must support The Unicode Standard, Version 4.1.0 or
        //   greater using the character encoding form defined by the UTF-8 storage
        //   specification.  The Unicode Standard is published by the The Unicode
        //   Consortium (www.unicode.org).  UTF-8 encoded data stored within ZIP files
        //   is expected to not include a byte order mark (BOM).

        //  Code Page 437 corresponds to kCFStringEncodingDOSLatinUS
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS);
        NSString *strPath = [NSString stringWithCString:filename encoding:encoding];
        if(strPath) return strPath;
    }

    // attempting unicode encoding
    NSString *strPath = @(filename);
    if (strPath) return strPath;

    // if filename is non-unicode, detect and transform Encoding
    NSData *data = [NSData dataWithBytes:(const void *)filename length:sizeof(unsigned char) * size_filename];
    // Testing availability of @available (https://stackoverflow.com/a/46927445/1033581)

    if (@available(macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0, *)) {
        // supported encodings are in [NSString availableStringEncodings]
        [NSString stringEncodingForData:data encodingOptions:nil convertedString:&strPath usedLossyConversion:nil];
    } else {
        // fallback to a simple manual detect for macOS 10.9 or older
        NSArray<NSNumber *> *encodings = @[@(kCFStringEncodingGB_18030_2000), @(kCFStringEncodingShiftJIS)];
        for (NSNumber *encoding in encodings) {
            strPath = [NSString stringWithCString:filename encoding:
                       (NSStringEncoding)CFStringConvertEncodingToNSStringEncoding(encoding.unsignedIntValue)];
            if (strPath) break;
        }
    }
    if (strPath) return strPath;

    // if filename encoding is non-detected, we default to something based on data
    // _hexString is more readable than _base64RFC4648 for debugging unknown encodings
    return [data hexadedimalString];
}

// Format from http://newsgroups.derkeiler.com/Archive/Comp/comp.os.msdos.programmer/2009-04/msg00060.html
// Two consecutive words, or a longword, YYYYYYYMMMMDDDDD hhhhhmmmmmmsssss
// YYYYYYY is years from 1980 = 0
// sssss is (seconds/2).
//
// 3658 = 0011 0110 0101 1000 = 0011011 0010 11000 = 27 2 24 = 2007-02-24
// 7423 = 0111 0100 0010 0011 - 01110 100001 00011 = 14 33 3 = 14:33:06
- (NSDate *)dateWithMSDOSFormat:(UInt32)msdosDateTime {
    // the whole `_dateWithMSDOSFormat:` method is equivalent but faster than this one line,
    // essentially because `mktime` is slow:
    //NSDate *date = [NSDate dateWithTimeIntervalSince1970:dosdate_to_time_t(msdosDateTime)];
    static const UInt32 kYearMask = 0xFE000000;
    static const UInt32 kMonthMask = 0x1E00000;
    static const UInt32 kDayMask = 0x1F0000;
    static const UInt32 kHourMask = 0xF800;
    static const UInt32 kMinuteMask = 0x7E0;
    static const UInt32 kSecondMask = 0x1F;

    NSAssert(0xFFFFFFFF == (kYearMask | kMonthMask | kDayMask | kHourMask | kMinuteMask | kSecondMask),
             @"[AGXUnzipper] MSDOS date masks don't add up");

    NSDateComponents *components = NSDateComponents.instance;
    components.year = 1980 + ((msdosDateTime & kYearMask) >> 25);
    components.month = (msdosDateTime & kMonthMask) >> 21;
    components.day = (msdosDateTime & kDayMask) >> 16;
    components.hour = (msdosDateTime & kHourMask) >> 11;
    components.minute = (msdosDateTime & kMinuteMask) >> 5;
    components.second = (msdosDateTime & kSecondMask) * 2;

    return [NSCalendar.gregorianCalendar dateFromComponents:components];
}

@end
