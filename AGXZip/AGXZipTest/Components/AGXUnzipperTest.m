//
//  AGXUnzipperTest.m
//  AGXZipTest
//
//  Created by Char Aznable on 2018/5/15.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXZip.h"

@interface AGXUnzipperProgressDelegate : NSObject <AGXUnzipperDelegate>
@property (nonatomic, AGX_STRONG) NSMutableArray *progressEvents;
@end
@implementation AGXUnzipperProgressDelegate
- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _progressEvents = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc {
    AGX_RELEASE(_progressEvents);
    AGX_SUPER_DEALLOC;
}
- (void)unzipperWillUnzipArchiveAtPath:(NSString *)path zipInfo:(agx_unz_global_info)zipInfo {
    NSLog(@"*** unzipperWillUnzipArchiveAtPath: `%@` zipInfo:", path);
}
- (void)unzipperDidUnzipArchiveAtPath:(NSString *)path zipInfo:(agx_unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    NSLog(@"*** unzipperDidUnzipArchiveAtPath: `%@` zipInfo: unzippedPath: `%@`", path, unzippedPath);
}
- (BOOL)unzipperShouldUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo {
    NSLog(@"*** unzipperShouldUnzipFileAtIndex: `%d` totalFiles: `%d` archivePath: `%@` fileInfo:", (int)fileIndex, (int)totalFiles, archivePath);
    return YES;
}
- (void)unzipperWillUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo {
    NSLog(@"*** unzipperWillUnzipFileAtIndex: `%d` totalFiles: `%d` archivePath: `%@` fileInfo:", (int)fileIndex, (int)totalFiles, archivePath);
}
- (void)unzipperDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo {
    NSLog(@"*** unzipperDidUnzipFileAtIndex: `%d` totalFiles: `%d` archivePath: `%@` fileInfo:", (int)fileIndex, (int)totalFiles, archivePath);
}
- (void)unzipperProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    NSLog(@"*** unzipperProgressEvent: loaded: `%llu` total: `%llu`", loaded, total);
    [_progressEvents addObject:@(loaded)];
}
@end

@interface AGXUnzipperCancelDelegate : NSObject <AGXUnzipperDelegate>
@property (nonatomic, assign) int numFilesUnzipped;
@property (nonatomic, assign) int numFilesToUnzip;
@property (nonatomic, assign) BOOL didUnzipArchive;
@property (nonatomic, assign) int loaded;
@property (nonatomic, assign) int total;
@end
@implementation AGXUnzipperCancelDelegate
- (void)unzipperDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo {
    _numFilesUnzipped = (int)fileIndex + 1;
}
- (BOOL)unzipperShouldUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(agx_unz_file_info)fileInfo {
    return _numFilesUnzipped < _numFilesToUnzip;
}
- (void)unzipperDidUnzipArchiveAtPath:(NSString *)path zipInfo:(agx_unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    _didUnzipArchive = YES;
}
- (void)unzipperProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    _loaded = (int)loaded;
    _total = (int)total;
}
@end

@interface AGXUnzipperCollectingDelegate : NSObject <AGXUnzipperDelegate>
@property(nonatomic, AGX_STRONG) NSMutableArray<NSString *> *files;
@end
@implementation AGXUnzipperCollectingDelegate
- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _files = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc {
    AGX_RELEASE(_files);
    AGX_SUPER_DEALLOC;
}
- (void)unzipperDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath {
    [self.files addObject:unzippedFilePath];
}
@end

@interface AGXUnzipperTest : XCTestCase

@end

@implementation AGXUnzipperTest

- (void)tearDown {
    AGXResources.caches.subpathAs(@"Unzipper").remove();
    [super tearDown];
}

- (void)testIsPasswordProtected {
    AGXUnzipper *unzipper = AGXUnzipper.application;
    XCTAssertFalse(unzipper.unzipArchiveNamed(@"TestArchive.zip").isPasswordProtected(), @"has no password");
    XCTAssertTrue(unzipper.unzipArchiveNamed(@"TestPasswordArchive.zip").isPasswordProtected(), @"has password");
}

- (void)testIsPasswordValid {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestPasswordArchive.zip");
    XCTAssertFalse(unzipper.isPasswordValid(@"passw0rd123"), @"Invalid password reports true.");
    XCTAssertTrue(unzipper.isPasswordValid(@"passw0rd"), @"Valid password reports false.");
}

- (void)testUnzipping {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip");
    AGXResources *destination = [self destinationWithSubpath:@"Regular"];
    XCTAssertTrue(unzipper.unzipTo(destination));
    XCTAssertTrue(destination.isExistsFileNamed(@"Readme.markdown"), @"Readme unzipped");
    XCTAssertTrue(destination.isExistsFileNamed(@"LICENSE"), @"LICENSE unzipped");
    XCTAssertTrue(unzipper.unzipTo(destination));
    XCTAssertTrue(destination.isExistsFileNamed(@"Readme.markdown"), @"Readme unzipped");
    XCTAssertTrue(destination.isExistsFileNamed(@"LICENSE"), @"LICENSE unzipped");
}

- (void)testUnzippingWithPassword {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestPasswordArchive.zip");
    AGXResources *destination = [self destinationWithSubpath:@"Password"];
    XCTAssertTrue(unzipper.passwordAs(@"passw0rd").unzipTo(destination));
    XCTAssertTrue(destination.isExistsFileNamed(@"Readme.markdown"), @"Readme unzipped");
    XCTAssertTrue(destination.isExistsFileNamed(@"LICENSE"), @"LICENSE unzipped");
}

- (void)testUnzippingWithInvalidPassword {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestPasswordArchive.zip");
    AGXResources *destination = [self destinationWithSubpath:@"InvalidPassword"];
    XCTAssertFalse(unzipper.passwordAs(@"passw0rd123").unzipTo(destination));
    XCTAssertFalse(destination.isExistsFileNamed(@"Readme.markdown"), @"Readme not unzipped");
    XCTAssertFalse(destination.isExistsFileNamed(@"LICENSE"), @"LICENSE not unzipped");
}

- (void)testUnzippingProgress {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip");
    AGXUnzipperProgressDelegate *delegate = [AGXUnzipperProgressDelegate instance];
    AGXResources *destination = [self destinationWithSubpath:@"Progress"];
    XCTAssertTrue(unzipper.delegateTo(delegate).unzipTo(destination));
    // 4 events: the first, then for each of the two files one, then the final event
    XCTAssertTrue(4 == [delegate.progressEvents count], @"Expected 4 progress events");
    XCTAssertTrue(0 == [delegate.progressEvents[0] intValue]);
    XCTAssertTrue(619 == [delegate.progressEvents[1] intValue]);
    XCTAssertTrue(1114 == [delegate.progressEvents[2] intValue]);
    XCTAssertTrue(1436 == [delegate.progressEvents[3] intValue]);
}

- (void)testUnzippingTruncatedFileFix {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"IncorrectHeaders.zip");
    AGXResources *destination = [self destinationWithSubpath:@"IncorrectHeaders"];
    XCTAssertTrue(unzipper.unzipTo(destination));
    NSData *data = destination.dataWithFileNamed(@"IncorrectHeaders/Readme.txt");
    NSString *actualReadmeTxtMD5 = data.MD5Sum;
    NSString *intendedReadmeTxtMD5 = @"31ac96301302eb388070c827447290b5";
    XCTAssertTrue([actualReadmeTxtMD5 isEqualToString:intendedReadmeTxtMD5],
                  @"Readme.txt MD5 digest should match original.");
}

- (void)testUnzippingWithSymlinkedFileInside {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"SymbolicLink.zip");
    AGXResources *destination = [self destinationWithSubpath:@"SymbolicLink"];
    XCTAssertTrue(unzipper.unzipTo(destination));
    NSDictionary *info = destination.attributesWithNamed(@"SymbolicLink/Xcode.app");
    XCTAssertTrue(info[NSFileType] == NSFileTypeSymbolicLink,
                  @"Symbolic links should persist from the original archive to the outputted files.");
}

- (void)testUnzippingWithRelativeSymlink {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"RelativeSymbolicLink.zip");
    AGXResources *destination = [self destinationWithSubpath:@"RelativeSymbolicLink"];
    XCTAssertTrue(unzipper.unzipTo(destination));
    NSDictionary *fileInfo = destination.attributesWithNamed(@"symlinks/fileSymlink");
    XCTAssertTrue(fileInfo[NSFileType] == NSFileTypeSymbolicLink,
                  @"Relative symbolic links should persist from the original archive to the outputted files.");
    NSDictionary *folderInfo = destination.attributesWithNamed(@"symlinks/folderSymlink");
    XCTAssertTrue(folderInfo[NSFileType] == NSFileTypeSymbolicLink,
                  @"Relative symbolic links should persist from the original archive to the outputted files.");
}

- (void)testUnzippingWithUnicodeFilenameInside {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"Unicode.zip");
    AGXResources *destination = [self destinationWithSubpath:@"Unicode"];
    XCTAssertTrue(unzipper.unzipTo(destination));
    BOOL unicodeFilenameWasExtracted = destination.isExistsNamed(@"Accént.txt", nil);
    BOOL unicodeFolderWasExtracted = destination.isExistsNamed(@"Fólder/Nothing.txt", nil);
    XCTAssertTrue(unicodeFilenameWasExtracted, @"Files with filenames in unicode should be extracted properly.");
    XCTAssertTrue(unicodeFolderWasExtracted, @"Folders with names in unicode should be extracted propertly.");
}

- (void)testUnzippingEmptyArchive {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"Empty.zip");
    AGXResources *destination = [self destinationWithSubpath:@"Empty"];
    XCTAssertTrue(unzipper.unzipTo(destination));
}

- (void)testUnzippingWithCancel {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip");

    AGXUnzipperCancelDelegate *delegate = [AGXUnzipperCancelDelegate instance];
    delegate.numFilesToUnzip = 1;
    AGXResources *destination = [self destinationWithSubpath:@"Cancel1"];
    XCTAssertFalse(unzipper.delegateTo(delegate).unzipTo(destination));
    XCTAssertEqual(delegate.numFilesUnzipped, 1);
    XCTAssertFalse(delegate.didUnzipArchive);
    XCTAssertNotEqual(delegate.loaded, delegate.total);

    delegate = [AGXUnzipperCancelDelegate instance];
    delegate.numFilesToUnzip = 1000;
    destination = [self destinationWithSubpath:@"Cancel2"];
    XCTAssertTrue(unzipper.delegateTo(delegate).unzipTo(destination));
    XCTAssertEqual(delegate.numFilesUnzipped, 2);
    XCTAssertTrue(delegate.didUnzipArchive);
    XCTAssertEqual(delegate.loaded, delegate.total);
}

- (void)testShouldProvidePathOfUnzippedFileInDelegateCallback {
    AGXUnzipper *unzipper = AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip");
    AGXUnzipperCollectingDelegate *delegate = [AGXUnzipperCollectingDelegate instance];
    AGXResources *destination = [self destinationWithSubpath:@"Collecting"];
    XCTAssertTrue(unzipper.delegateTo(delegate).unzipTo(destination));
    XCTAssertEqualObjects(delegate.files[0], destination.pathWithNamed(@"/LICENSE"));
    XCTAssertEqualObjects(delegate.files[1], destination.pathWithNamed(@"/Readme.markdown"));
}

- (AGXResources *)destinationWithSubpath:(NSString *)subpath {
    return AGXResources.caches.subpathAs(@"Unzipper").subpathAppend(subpath);
}

@end
