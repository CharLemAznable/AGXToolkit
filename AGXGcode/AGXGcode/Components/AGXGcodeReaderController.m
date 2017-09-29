//
//  AGXGcodeReaderController.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/11.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import "AGXGcodeReaderController.h"
#import "AGXGcodeReader.h"

@interface AGXGcodeReaderControllerInternalDelegate : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, AGX_WEAK)   id<UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;
@property (nonatomic, AGX_STRONG) AGXGcodeReader *reader;
@end

@implementation AGXGcodeReaderControllerInternalDelegate

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];

    NSString *key = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage;
    UIImage *image = [info objectForKey:key];
    if AGX_EXPECT_F(!image) return;

    AGXGcodeReaderController *reader = (AGXGcodeReaderController *)picker;
    NSError *error = nil;
    AGXGcodeResult *result = [_reader decode:image hints:reader.hint error:&error];
    if (result) {
        if ([reader.gcodeReaderDelegate respondsToSelector:@selector(gcodeReaderController:didReadResult:)])
            agx_async_main([reader.gcodeReaderDelegate gcodeReaderController:reader didReadResult:result];)
    } else {
        if ([reader.gcodeReaderDelegate respondsToSelector:@selector(gcodeReaderController:failedWithError:)])
            agx_async_main([reader.gcodeReaderDelegate gcodeReaderController:reader failedWithError:error];)
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation AGXGcodeReaderController {
    AGXGcodeReaderControllerInternalDelegate *_readerInternalDelegate;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _readerInternalDelegate = [[AGXGcodeReaderControllerInternalDelegate alloc] init];
        self.delegate = _readerInternalDelegate;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setDelegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:[AGXGcodeReaderControllerInternalDelegate class]])  {
        [super setDelegate:delegate];
        return;
    }
    _readerInternalDelegate.delegate = delegate;
}

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType {
    if (UIImagePickerControllerSourceTypeCamera == sourceType) return;
    [super setSourceType:sourceType];
}

- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIApplication.sharedRootViewController presentViewController:self animated:animated completion:completion];
}

@end
