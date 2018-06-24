# AGXGcode

条形码/二维码解析组件.

##### Constants

- AGXGcodeLocalizedStringDefault / AGXGcodeLocalizedString

    本地化工具宏.

- AGXGcodeFormat

    编码方式枚举.

##### Components

- AGXGcodeCaptureView

    使用摄像头读取图像, 识别解析条形码/二维码.

```objective-c
// 属性
formats // 设置需要识别的编码方式
frameOfInterest // 设置摄像头识别的区域

// 启停方法
-startCapture
-stopCapture

// 切换摄像头
-switchCaptureDevice

// AGXGcodeCaptureViewDelegate
// 为防止重复识别产生重复回调, 在识别成功并回调后, 请首先停止捕获, 在处理识别结果完成后按需要重启捕获.
-gcodeCaptureView:didReadResult:
```

- AGXGcodeCaptureViewController

    识别解析条形码/二维码控制器.

```objective-c
// 属性
formats // 设置需要识别的编码方式
frameOfInterest // 设置摄像头识别的区域
tintColor // 按钮文字颜色
autoDismissViewController // 是否自动关闭控制器
allowPhotoPickingReader // 是否展示相册读取按钮

// AGXGcodeCaptureViewControllerDelegate
-gcodeCaptureViewControllerDidCancel:
-gcodeCaptureViewController:didReadResult:
-gcodeCaptureViewController:failedWithError:
```

- AGXGcodeReader

    图片条形码/二维码识别解析器.

```objective-c
-decode:hints:error:
-reset
```

- AGXGcodeReaderController

    使用相册读取图片, 识别解析条形码/二维码.

```objective-c
// 属性
gcodeReaderDelegate // 图片识别解析后的回调代理
hint // 识别解析设置

// AGXGcodeReaderControllerDelegate
-gcodeReaderController:didReadResult:
-gcodeReaderController:failedWithError:
```

- AGXDecodeHints

    识别解析设置.

```objective-c
// 属性
encoding // 识别解析QRCode时使用的字符集
formats // 设置需要识别的编码方式

// 构造方法
+hints
+hintsWithFormats:
-init
-initWithFormats:

// 判断方法
-containsFormat:
```

- AGXGcodeResult

    识别解析结果.

```objective-c
// 属性
text // 结果字符串
format // 识别的编码方式

// 构造方法
+gcodeResultWithText:format:
-initWithText:format:
```
