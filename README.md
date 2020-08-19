# flutter_aes_plugin

AES加密模式:CBC
填充模式:zeropadding (针对此模式开发,其他模式大家可以找的到)
秘钥:16位字符串(不需要的可不传,根据业务情况选择)
偏移量:16位字符串 (不需要的可不传,根据业务情况选择)
输出:base64类型的字符串

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.


使用
await FlutterAesPlugin.goNativeWithValue( {
        'pw': 'yourPassWord',
        'key': 'xxxxxxxxxxxxxxxx',
        'iv': 'xxxxxxxxxxxxxxxx'
      });