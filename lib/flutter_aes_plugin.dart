import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAesPlugin {
  // 定义一个通道方法。注意他的参数通常为字符串，且必须跟原生代码的一致，否则无法通信
  static const MethodChannel _channel =
      const MethodChannel('flutter_aes_zeropadding');

  static Future<dynamic> goNativeWithValue(String methodName,
      [Map<String, dynamic> map]) async {
    if (null == map) {
      //无参数
      dynamic future = await _channel.invokeMethod(methodName); //methodName方法名
      return future;
    } else {
      //带有参数
      dynamic future = await _channel.invokeMethod(methodName, map);
      return future;
    }
  }
}
