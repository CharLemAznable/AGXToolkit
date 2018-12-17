# AGXGcode

条形码/二维码解析组件.

##### Constants

- AGXGcodeFormat

    编码方式枚举.

##### Components

- AGXGcodeCaptureView

    使用摄像头读取图像, 识别解析条形码/二维码.

```objectivec
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

- AGXGcodeReader

    图片条形码/二维码识别解析器.

```objectivec
-decode:hints:error:
-reset
```

- AGXDecodeHints

    识别解析设置.

```objectivec
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

```objectivec
// 属性
text // 结果字符串
format // 识别的编码方式

// 构造方法
+gcodeResultWithText:format:
-initWithText:format:
```
