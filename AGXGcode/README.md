# AGXGcode

条形码/二维码解析组件.

#####Constant

- AGXGcodeFormat

    编码方式枚举.

#####Components

- AGXGcodeCaptureView

    使用摄像头读取图像, 识别解析条形码/二维码.

```objective-c
// 属性
formats // 设置需要识别的编码方式
frameOfInterest // 设置摄像头识别的区域

// 启停方法
-startCapture
-stopCapture

// AGXGcodeCaptureViewDelegate
// 为防止重复识别产生重复回调, 在识别成功并回调后, 请首先停止捕获, 在处理识别结果完成后按需要重启捕获.
-gcodeCaptureView:didReadResult:
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

// 使用以下方法展示相册控制器
-presentAnimated:completion:

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
