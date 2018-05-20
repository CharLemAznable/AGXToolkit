//
//  AGXZipperTest.m
//  AGXZipTest
//
//  Created by Char Aznable on 2018/5/20.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXZip.h"

@interface AGXZipperTest : XCTestCase

@end

@implementation AGXZipperTest

- (void)tearDown {
    AGXResources.caches.subpathAs(@"Zipper").remove();
    AGXResources.caches.subpathAs(@"Zipped").remove();
    AGXResources.caches.subpathAs(@"Unzipper").remove();
    [super tearDown];
}

- (void)testZipping {
    NSString *zipArchiveName = @"Zipped/Regular/CreatedArchive.zip";
    AGXResources *source = [self sourceWithSubpath:@"Regular"];
    AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip").unzipTo(source);
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");
    XCTAssertFalse(AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).isPasswordProtected(), @"has no password");

    AGXResources *destination = [self destinationWithSubpath:@"Regular"];
    AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).unzipTo(destination);
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"Readme.markdown"),
                          source.dataWithFileNamed(@"Readme.markdown"));
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"LICENSE"),
                          source.dataWithFileNamed(@"LICENSE"));
}

- (void)testZippingWithPassword {
    NSString *zipArchiveName = @"Zipped/Password/CreatedArchive.zip";
    AGXResources *source = [self sourceWithSubpath:@"Password"];
    AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip").unzipTo(source);
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).passwordAs(@"dolphins🐋").zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");
    XCTAssertTrue(AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).isPasswordProtected(), @"has password");

    AGXResources *destination = [self destinationWithSubpath:@"Password"];
    AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).passwordAs(@"dolphins🐋").unzipTo(destination);
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"Readme.markdown"),
                          source.dataWithFileNamed(@"Readme.markdown"));
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"LICENSE"),
                          source.dataWithFileNamed(@"LICENSE"));
}

- (void)testZippingWithZeroLengthPassword {
    NSString *zipArchiveName = @"Zipped/ZeroLengthPassword/CreatedArchive.zip";
    AGXResources *source = [self sourceWithSubpath:@"ZeroLengthPassword"];
    AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip").unzipTo(source);
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).passwordAs(@"").zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");
    XCTAssertTrue(AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).isPasswordProtected(), @"has password");

    AGXResources *destination = [self destinationWithSubpath:@"ZeroLengthPassword"];
    AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).passwordAs(@"").unzipTo(destination);
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"Readme.markdown"),
                          source.dataWithFileNamed(@"Readme.markdown"));
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"LICENSE"),
                          source.dataWithFileNamed(@"LICENSE"));
}

- (void)testDirectoryZipping {
    NSString *zipArchiveName = @"Zipped/DirectoryZipping/CreatedArchive.zip";
    AGXResources *source = [self sourceWithSubpath:@"DirectoryZipping"];
    AGXUnzipper.application.unzipArchiveNamed(@"Unicode.zip").unzipTo(source);
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");

    AGXResources *destination = [self destinationWithSubpath:@"DirectoryZipping"];
    AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).unzipTo(destination);
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"Accént.txt"),
                          source.dataWithFileNamed(@"Accént.txt"));
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"Fólder/Nothing.txt"),
                          source.dataWithFileNamed(@"Fólder/Nothing.txt"));
}

- (void)testMultipleZippping{
    AGXResources *source = AGXResources.application.subpathAs(@"MultipleZippping");
    NSString *zipArchivePath = @"Zipped/MultipleZippping";
    // this is a monster
    // if testing on iOS, within 30 loops it will fail; however, on OS X, it may take about 900 loops
    for (int test = 0; test < 30; test++) {
        // Zipping
        NSString *zipArchiveName = [zipArchivePath stringByAppendingPathComponent:
                                    [NSString stringWithFormat:@"queue_test_%d.zip", test]];
        XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).zipFrom(source));
        long long threshold = 510000; // 510kB:size slightly smaller than a successful zip, but much larger than a failed one
        long long fileSize = [AGXResources.caches.attributesWithNamed(zipArchiveName)[NSFileSize] longLongValue];
        XCTAssertTrue(fileSize > threshold, @"zipping failed at %@!", zipArchiveName);
    }
}

- (void)testZippingAndUnzippingWithUnicodePassword {
    NSString *zipArchiveName = @"Zipped/UnicodePassword/CreatedUnicodePasswordArchive.zip";
    AGXResources *source = [self sourceWithSubpath:@"UnicodePassword"];
    AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip").unzipTo(source);
    /********** Zipping ********/
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).passwordAs(@"ꊐ⌒Ⅳ🤐").zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");
    /********** Unzipping ********/
    AGXResources *destination = [self destinationWithSubpath:@"UnicodePassword"];
    XCTAssertTrue(AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).passwordAs(@"ꊐ⌒Ⅳ🤐").unzipTo(destination));
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"Readme.markdown"),
                          source.dataWithFileNamed(@"Readme.markdown"));
    XCTAssertEqualObjects(destination.dataWithFileNamed(@"LICENSE"),
                          source.dataWithFileNamed(@"LICENSE"));
}

- (void)testZippingAndUnzippingForDate {
    NSString *zipArchiveName = @"Zipped/ForDate/CreatedArchive.zip";
    AGXResources *source = [self sourceWithSubpath:@"ForDate"];
    AGXUnzipper.application.unzipArchiveNamed(@"TestArchive.zip").unzipTo(source);
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");
    AGXResources *destination = [self destinationWithSubpath:@"ForDate"];
    AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).unzipTo(destination);
    NSDictionary *originalFileAttributes = source.attributesWithNamed(@"Readme.markdown");
    NSDictionary *createdFileAttributes = destination.attributesWithNamed(@"Readme.markdown");
    XCTAssertEqualObjects(originalFileAttributes[NSFileCreationDate],
                          createdFileAttributes[NSFileCreationDate],
                          @"Original file creationDate should match created one");
}

- (void)testZippingAndUnzippingForPermissions {
    NSString *zipArchiveName = @"Zipped/PermissionsTest/TestAppArchive.zip";
    /********** Zipping ********/
    AGXResources *source = AGXResources.application.subpathAs(@"PermissionsTestApp.app");
    // File we're going to test permissions on before and after zipping
    NSString *targetFile = @"/Contents/MacOS/TestProject";
    // Atribtues for the target file before zipping
    NSDictionary *originalFileAttributes = source.attributesWithNamed(targetFile);
    XCTAssertTrue(AGXZipper.caches.zipArchiveNamed(zipArchiveName).zipFrom(source));
    XCTAssertTrue(AGXResources.caches.isExistsFileNamed(zipArchiveName), @"Archive created");
    /********** Un-zipping *******/
    AGXResources *destination = [self destinationWithSubpath:@"PermissionsTest"];
    AGXUnzipper.caches.unzipArchiveNamed(zipArchiveName).unzipTo(destination);
    // Get the file attributes of the target file following the unzipping
    NSDictionary *createdFileAttributes = source.attributesWithNamed(targetFile);
    // Compare the value of the permissions attribute to assert equality
    XCTAssertEqual([originalFileAttributes[NSFilePosixPermissions] longValue],
                   [createdFileAttributes[NSFilePosixPermissions] longValue],
                   @"File permissions should be retained during compression and de-compression");
}

- (AGXResources *)sourceWithSubpath:(NSString *)subpath {
    return AGXResources.caches.subpathAs(@"Zipper").subpathAppend(subpath);
}

- (AGXResources *)destinationWithSubpath:(NSString *)subpath {
    return AGXResources.caches.subpathAs(@"Unzipper").subpathAppend(subpath);
}

@end
