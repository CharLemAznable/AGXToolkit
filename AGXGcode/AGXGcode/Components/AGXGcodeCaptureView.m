//
//  AGXGcodeCaptureView.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/12.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import "AGXGcodeCaptureView.h"

@interface AGXGcodeCaptureView () <AVCaptureMetadataOutputObjectsDelegate>
@end

@implementation AGXGcodeCaptureView {
    AVCaptureMetadataOutput *_output;
    AVCaptureSession *_session;
    CALayer *_previewLayer;
    NSValue *_frameValueOfInterest;
}

- (void)agxInitial {
    [super agxInitial];

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AGX_EXPECT_F(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
                     status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)) {
        _output = nil;
        _session = nil;
        _previewLayer = [[CALayer alloc] init];
        _previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    } else {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        [_session addInput:input];
        [_session addOutput:_output];

        _previewLayer = AGX_RETAIN([AVCaptureVideoPreviewLayer layerWithSession:_session]);
        ((AVCaptureVideoPreviewLayer *)_previewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    [self.layer insertSublayer:_previewLayer atIndex:0];

    _formats = [[NSArray alloc] init];
}

- (void)dealloc {
    _delegate = nil;
    AGX_RELEASE(_frameValueOfInterest);
    AGX_RELEASE(_previewLayer);
    AGX_RELEASE(_session);
    AGX_RELEASE(_output);
    AGX_RELEASE(_formats);
    AGX_SUPER_DEALLOC;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _previewLayer.frame = self.bounds;
    if ([_previewLayer isKindOfClass:[AVCaptureVideoPreviewLayer class]] && _frameValueOfInterest) {
        _output.rectOfInterest = [((AVCaptureVideoPreviewLayer *)_previewLayer) metadataOutputRectOfInterestForRect:_frameValueOfInterest.CGRectValue];
    }
}

- (void)setFormats:(NSArray *)formats {
    if (AGX_EXPECT_F([_formats isEqualToArray:formats])) return;
    AGX_RELEASE(_formats);
    _formats = [formats copy];

    NSMutableArray *metadataObjectTypes = [NSMutableArray arrayWithCapacity:_formats.count];
    [_formats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (AGX_EXPECT_F(![obj isKindOfClass:[NSNumber class]])) return;
        switch ([obj unsignedIntegerValue]) {
            case kGcodeFormatUPCE:
            case kGcodeFormatUPCA:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeUPCECode];break;
            case kGcodeFormatEan13:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeEAN13Code];break;
            case kGcodeFormatEan8:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeEAN8Code];break;
            case kGcodeFormatCode39:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeCode39Code];
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeCode39Mod43Code];break;
            case kGcodeFormatCode93:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeCode93Code];break;
            case kGcodeFormatCode128:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeCode128Code];break;
            case kGcodeFormatPDF417:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypePDF417Code];break;
            case kGcodeFormatQRCode:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeQRCode];break;
            case kGcodeFormatAztec:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeAztecCode];break;
            case kGcodeFormatITF:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeInterleaved2of5Code];
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeITF14Code];
                break;
            case kGcodeFormatDataMatrix:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeDataMatrixCode];
                break;
            default:return;
        }
    }];
    _output.metadataObjectTypes = metadataObjectTypes;
}

- (CGRect)frameOfInterest {
    if (_frameValueOfInterest) return _frameValueOfInterest.CGRectValue;
    if (AGX_EXPECT_F(![_previewLayer isKindOfClass:[AVCaptureVideoPreviewLayer class]])) return CGRectZero;
    return [((AVCaptureVideoPreviewLayer *)_previewLayer) rectForMetadataOutputRectOfInterest:_output.rectOfInterest];
}

- (void)setFrameOfInterest:(CGRect)frameOfInterest {
    if (AGX_EXPECT_F(CGRectEqualToRect(_frameValueOfInterest.CGRectValue, frameOfInterest))) return;
    AGX_RELEASE(_frameValueOfInterest);
    _frameValueOfInterest = AGX_RETAIN([NSValue valueWithCGRect:frameOfInterest]);
    [self setNeedsLayout];
}

- (void)startCapture {
    [_session startRunning];
}

- (void)stopCapture {
    [_session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0 && [self.delegate respondsToSelector:@selector(gcodeCaptureView:didReadResult:)]) {
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        [self.delegate gcodeCaptureView:self didReadResult:
         [AGXGcodeResult resultWithText:metadataObject.stringValue
                                 format:gcodeFormatOfMetadataObjectType(metadataObject.type)]];
    }
}

#pragma mark - private methods

AGX_STATIC_INLINE AGXGcodeFormat gcodeFormatOfMetadataObjectType(NSString *metadataObjectType) {
    if (metadataObjectType == AVMetadataObjectTypeUPCECode) {
        return kGcodeFormatUPCE;
    } else if (metadataObjectType == AVMetadataObjectTypeCode39Code ||
               metadataObjectType == AVMetadataObjectTypeCode39Mod43Code) {
        return kGcodeFormatCode39;
    } else if (metadataObjectType == AVMetadataObjectTypeEAN13Code) {
        return kGcodeFormatEan13;
    } else if (metadataObjectType == AVMetadataObjectTypeEAN8Code) {
        return kGcodeFormatEan8;
    } else if (metadataObjectType == AVMetadataObjectTypeCode93Code) {
        return kGcodeFormatCode93;
    } else if (metadataObjectType == AVMetadataObjectTypeCode128Code) {
        return kGcodeFormatCode128;
    } else if (metadataObjectType == AVMetadataObjectTypePDF417Code) {
        return kGcodeFormatPDF417;
    } else if (metadataObjectType == AVMetadataObjectTypeQRCode) {
        return kGcodeFormatQRCode;
    } else if (metadataObjectType == AVMetadataObjectTypeAztecCode) {
        return kGcodeFormatAztec;
    } else if (metadataObjectType == AVMetadataObjectTypeInterleaved2of5Code ||
               metadataObjectType == AVMetadataObjectTypeITF14Code) {
        return kGcodeFormatITF;
    } else if (metadataObjectType ==  AVMetadataObjectTypeDataMatrixCode) {
        return kGcodeFormatDataMatrix;
    } else return -1;
}

@end
