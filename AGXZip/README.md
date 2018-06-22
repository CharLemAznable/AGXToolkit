# AGXZip

Zip压缩/解压缩组件.

##### Components

- AGXUnzipper

    解压缩工具.

```objective-c
// 源zip文件根目录
+application
+document
+caches
+temporary

-unzipArchiveNamed(NSString*)
-preserveAttributesAs(BOOL)
-overwriteAs(BOOL)
-nestedZipLevelAs(NSInteger)
-passwordAs(NSString*)
-delegateTo(id<AGXUnzipperDelegate>)
-progressHandleWith(void (^)(NSString *entry, agx_unz_file_info zipInfo, long entryNumber, long total))
-completionHandleWith(void (^)(NSString *path, BOOL succeeded, NSError *error))
-destinationAs(AGXResources*)

-isPasswordProtected()
-isPasswordValid(NSString*)
-unzip()
-unzipTo(AGXResources*)

// 属性
error

// AGXUnzipperDelegate
-unzipperWillUnzipArchiveAtPath:zipInfo:
-unzipperDidUnzipArchiveAtPath:zipInfo:unzippedPath:
-unzipperShouldUnzipFileAtIndex:totalFiles:archivePath:fileInfo:
-unzipperWillUnzipFileAtIndex:totalFiles:archivePath:fileInfo:
-unzipperDidUnzipFileAtIndex:totalFiles:archivePath:fileInfo:
-unzipperDidUnzipFileAtIndex:totalFiles:archivePath:unzippedFilePath:
-unzipperProgressEvent:total:
```

- AGXZipper

    压缩工具.

```objective-c
// 目标zip文件根目录
+document
+caches
+temporary

-zipArchiveNamed(NSString*)
-keepParentDirectoryAs(BOOL)
-compressionLevelAs(AGXZipperCompressionLevel)
-passwordAs(NSString*)
-aesAs(BOOL)
-progressHandleWith(void (^)(NSUInteger entryNumber, NSUInteger total))
-sourceAs(AGXResources*)

-zip()
-zipFrom(AGXResources*)
```
