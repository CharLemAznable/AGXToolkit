//
//  AGXGcodeReaderController.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/11.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXGcodeReaderController.h"
#import "AGXGcodeReader.h"

@interface AGXGcodeReaderControllerInternalPhotoPickerDelegate : NSObject <AGXPhotoPickerControllerDelegate>
@property (nonatomic, AGX_WEAK)     id<AGXPhotoPickerControllerDelegate> photoPickerDelegate;
@property (nonatomic, AGX_STRONG)   AGXGcodeReader *reader;
@end
@implementation AGXGcodeReaderControllerInternalPhotoPickerDelegate

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _reader = [[AGXGcodeReader alloc] init];
    }
    return self;
}

- (void)dealloc {
    _photoPickerDelegate = nil;
    AGX_RELEASE(_reader);
    AGX_SUPER_DEALLOC;
}

- (void)photoPickerControllerDidCancel:(AGXPhotoPickerController *)picker {
    if ([_photoPickerDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [_photoPickerDelegate photoPickerControllerDidCancel:picker];
    }
}

- (void)photoPickerController:(AGXPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[AGXAlbumControllerPickedImage];

    AGXGcodeReaderController *reader = (AGXGcodeReaderController *)picker;
    NSError *error = nil;
    AGXGcodeResult *result = [_reader decode:image hints:reader.hint error:&error];
    if (result) {
        if ([reader.gcodeReaderDelegate respondsToSelector:@selector(gcodeReaderController:didReadResult:)]) {
            [reader.gcodeReaderDelegate gcodeReaderController:reader didReadResult:result];
        }
    } else {
        if ([reader.gcodeReaderDelegate respondsToSelector:@selector(gcodeReaderController:failedWithError:)]) {
            [reader.gcodeReaderDelegate gcodeReaderController:reader failedWithError:error];
        }
    }

    if ([_photoPickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingMediaWithInfo:)]) {
        [_photoPickerDelegate photoPickerController:picker didFinishPickingMediaWithInfo:info];
    }
}

@end

@implementation AGXGcodeReaderController {
    AGXGcodeReaderControllerInternalPhotoPickerDelegate *_internalPhotoPickerDelegate;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _internalPhotoPickerDelegate = [[AGXGcodeReaderControllerInternalPhotoPickerDelegate alloc] init];
        super.photoPickerDelegate = _internalPhotoPickerDelegate;

        _hint = [[AGXDecodeHints alloc] init];
    }
    return self;
}

- (void)dealloc {
    _gcodeReaderDelegate = nil;
    AGX_RELEASE(_hint);
    AGX_RELEASE(_internalPhotoPickerDelegate);
    AGX_SUPER_DEALLOC;
}

- (void)setPhotoPickerDelegate:(id<AGXPhotoPickerControllerDelegate>)photoPickerDelegate {
    _internalPhotoPickerDelegate.photoPickerDelegate = photoPickerDelegate;
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {}

- (void)setAllowPickingGif:(BOOL)allowPickingGif {}

- (void)setAllowPickingLivePhoto:(BOOL)allowPickingLivePhoto {}

- (void)setAllowPickingOriginal:(BOOL)allowPickingOriginal {}

- (void)setAutoDismissViewController:(BOOL)autoDismissViewController {}

@end
