//
//  AGXGcodeReaderController.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/11.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#if __has_include(<AGXWidget/AGXWidget/AGXImagePickerController.h>)

#import "AGXGcodeReaderController.h"
#import "AGXGcodeReader.h"

@interface AGXGcodeReaderControllerInternalDelegate : NSObject <AGXImagePickerControllerDelegate>
@property (nonatomic, AGX_WEAK)   id<AGXImagePickerControllerDelegate> delegate;
@property (nonatomic, AGX_STRONG) AGXGcodeReader *reader;
@end

@implementation AGXGcodeReaderControllerInternalDelegate

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _reader = [[AGXGcodeReader alloc] init];
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    AGX_RELEASE(_reader);
    AGX_SUPER_DEALLOC;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector]
    || [self.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.delegate;
}

- (void)imagePickerController:(AGXImagePickerController *)picker didFinishPickingImage:(UIImage *)image {
    AGXGcodeReaderController *reader = (AGXGcodeReaderController *)picker;
    NSError *error = nil;
    AGXGcodeResult *result = [_reader decode:image hints:reader.hint error:&error];
    if (result) {
        if ([reader.gcodeReaderDelegate respondsToSelector:@selector(gcodeReaderController:didReadResult:)])
            [reader.gcodeReaderDelegate gcodeReaderController:reader didReadResult:result];
    } else {
        if ([reader.gcodeReaderDelegate respondsToSelector:@selector(gcodeReaderController:failedWithError:)])
            [reader.gcodeReaderDelegate gcodeReaderController:reader failedWithError:error];
    }
}

@end

@implementation AGXGcodeReaderController {
    AGXGcodeReaderControllerInternalDelegate *_readerInternalDelegate;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _readerInternalDelegate = [[AGXGcodeReaderControllerInternalDelegate alloc] init];
        self.imagePickerDelegate = _readerInternalDelegate;

        _hint = [[AGXDecodeHints alloc] init];
    }
    return self;
}

- (void)dealloc {
    _gcodeReaderDelegate = nil;
    AGX_RELEASE(_hint);
    AGX_RELEASE(_readerInternalDelegate);
    AGX_SUPER_DEALLOC;
}

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType {
    return;
}

- (void)setImagePickerDelegate:(id<AGXImagePickerControllerDelegate>)imagePickerDelegate {
    if (!imagePickerDelegate || [imagePickerDelegate isKindOfClass:[AGXGcodeReaderControllerInternalDelegate class]])  {
        [super setImagePickerDelegate:imagePickerDelegate];
        return;
    }
    _readerInternalDelegate.delegate = imagePickerDelegate;
}

@end

#endif // __has_include(<AGXWidget/AGXWidget/AGXImagePickerController.h>)
