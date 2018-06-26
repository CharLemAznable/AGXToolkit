# AGXWidgetGcode

自定义页面组件 - 条形码/二维码解析扩展.

##### Categories

- AGXWebView+AGXWidgetGcode

    扩展AGXWebView, 增加条形码/二维码解析的JS方法.

```javascript
string AGXB.recogniseGraphicCode({ "url":"image url string", "formats":[ AGXGcodeFormat EnumValue ] }) // 识别图片中的二维码, 参数url为图片URL字符串, 返回识别的二维码内容字符串
```
