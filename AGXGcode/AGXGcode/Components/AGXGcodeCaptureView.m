//
//  AGXGcodeCaptureView.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/12.
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
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureSession *_session;
    CALayer *_previewLayer;
    NSValue *_frameValueOfInterest;
}

- (void)agxInitial {
    [super agxInitial];

    AVCaptureDevice *device = [self deviceWithPosition:AVCaptureDevicePositionBack];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if AGX_EXPECT_F(!device || AVAuthorizationStatusRestricted == status || AVAuthorizationStatusDenied == status) {
        _input = nil;
        _output = nil;
        _session = nil;
        _previewLayer = [[CALayer alloc] init];
        _previewLayer.backgroundColor = UIColor.blackColor.CGColor;
    } else {
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];

        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        [_session addInput:_input];
        [_session addOutput:_output];

        _previewLayer = AGX_RETAIN([AVCaptureVideoPreviewLayer layerWithSession:_session]);
        ((AVCaptureVideoPreviewLayer *)_previewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    [self.layer insertSublayer:_previewLayer atIndex:0];

    self.formats = [NSArray instance];
}

- (void)dealloc {
    _delegate = nil;
    AGX_RELEASE(_frameValueOfInterest);
    AGX_RELEASE(_previewLayer);
    AGX_RELEASE(_session);
    AGX_RELEASE(_output);
    AGX_RELEASE(_input);
    AGX_RELEASE(_formats);
    AGX_SUPER_DEALLOC;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _previewLayer.frame = self.bounds;
    if ([_previewLayer isKindOfClass:AVCaptureVideoPreviewLayer.class]) {
        _output.rectOfInterest = AVCaptureDevicePositionBack==_input.device.position&&_frameValueOfInterest ? [((AVCaptureVideoPreviewLayer *)_previewLayer) metadataOutputRectOfInterestForRect:_frameValueOfInterest.CGRectValue] : CGRectMake(0, 0, 1, 1);
    }
}

- (void)setFormats:(NSArray *)formats {
    if AGX_EXPECT_F([_formats isEqualToArray:formats]) return;

    NSArray *temp = [formats copy];
    AGX_RELEASE(_formats);
    _formats = temp;

    NSMutableArray *metadataObjectTypes = [NSMutableArray arrayWithCapacity:_formats.count];
    [_formats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if AGX_EXPECT_F(![obj isKindOfClass:NSNumber.class]) return;
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
            case kGcodeFormatITF:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeInterleaved2of5Code];
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeITF14Code];break;
            case kGcodeFormatPDF417:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypePDF417Code];break;
            case kGcodeFormatQRCode:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeQRCode];break;
            case kGcodeFormatAztec:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeAztecCode];break;
            case kGcodeFormatDataMatrix:
                [metadataObjectTypes addAbsenceObject:AVMetadataObjectTypeDataMatrixCode];break;
            default:return;
        }
    }];
    if (metadataObjectTypes.count == 0) {
        [metadataObjectTypes addObject:AVMetadataObjectTypeUPCECode];
        [metadataObjectTypes addObject:AVMetadataObjectTypeEAN13Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeEAN8Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeCode39Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeCode39Mod43Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeCode93Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeCode128Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeInterleaved2of5Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeITF14Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypePDF417Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeQRCode];
        [metadataObjectTypes addObject:AVMetadataObjectTypeAztecCode];
        [metadataObjectTypes addObject:AVMetadataObjectTypeDataMatrixCode];
    }
    _output.metadataObjectTypes = metadataObjectTypes;
}

- (CGRect)frameOfInterest {
    if (_frameValueOfInterest) return _frameValueOfInterest.CGRectValue;
    if AGX_EXPECT_F(![_previewLayer isKindOfClass:AVCaptureVideoPreviewLayer.class]) return CGRectZero;
    return [((AVCaptureVideoPreviewLayer *)_previewLayer) rectForMetadataOutputRectOfInterest:_output.rectOfInterest];
}

- (void)setFrameOfInterest:(CGRect)frameOfInterest {
    if AGX_EXPECT_F(CGRectEqualToRect(_frameValueOfInterest.CGRectValue, frameOfInterest)) return;
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

- (void)switchCaptureDevice {
    if (!_input) return;
    @synchronized (self) {
        AVCaptureDeviceInput *newInput = [[AVCaptureDeviceInput alloc] initWithDevice:
                                          [self deviceWithPosition:AVCaptureDevicePositionBack==_input.device.position?
                                      AVCaptureDevicePositionFront:AVCaptureDevicePositionBack] error:nil];

        [_session beginConfiguration];
        [_session removeInput:_input];
        [_session addInput:newInput];
        [_session commitConfiguration];

        AGX_RELEASE(_input);
        _input = newInput;

        [self setNeedsLayout];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0 && [self.delegate respondsToSelector:@selector(gcodeCaptureView:didReadResult:)]) {
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        [self.delegate gcodeCaptureView:self didReadResult:
         [AGXGcodeResult gcodeResultWithText:metadataObject.stringValue format:
          gcodeFormatOfMetadataObjectType(metadataObject.type)]];
    }
}

#pragma mark - private methods

AGX_STATIC_INLINE AGXGcodeFormat gcodeFormatOfMetadataObjectType(NSString *metadataObjectType) {
    if (AVMetadataObjectTypeUPCECode == metadataObjectType) {
        return kGcodeFormatUPCE;
    } else if (AVMetadataObjectTypeCode39Code == metadataObjectType ||
               AVMetadataObjectTypeCode39Mod43Code == metadataObjectType) {
        return kGcodeFormatCode39;
    } else if (AVMetadataObjectTypeEAN13Code == metadataObjectType) {
        return kGcodeFormatEan13;
    } else if (AVMetadataObjectTypeEAN8Code == metadataObjectType) {
        return kGcodeFormatEan8;
    } else if (AVMetadataObjectTypeCode93Code == metadataObjectType) {
        return kGcodeFormatCode93;
    } else if (AVMetadataObjectTypeCode128Code == metadataObjectType) {
        return kGcodeFormatCode128;
    } else if (AVMetadataObjectTypePDF417Code == metadataObjectType) {
        return kGcodeFormatPDF417;
    } else if (AVMetadataObjectTypeQRCode == metadataObjectType) {
        return kGcodeFormatQRCode;
    } else if (AVMetadataObjectTypeAztecCode == metadataObjectType) {
        return kGcodeFormatAztec;
    } else if (AVMetadataObjectTypeInterleaved2of5Code == metadataObjectType ||
               AVMetadataObjectTypeITF14Code == metadataObjectType) {
        return kGcodeFormatITF;
    } else if (AVMetadataObjectTypeDataMatrixCode == metadataObjectType) {
        return kGcodeFormatDataMatrix;
    } else return -1;
}

- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:
                        @[ AVCaptureDeviceTypeBuiltInWideAngleCamera ] mediaType:
                        AVMediaTypeVideo position:position].devices;
    for (AVCaptureDevice *device in devices)
    { if (device.position == position) { return device; } }
    return nil;
}

@end
