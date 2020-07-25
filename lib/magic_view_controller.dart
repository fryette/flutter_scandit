import 'package:flutter/services.dart';

class MagicViewController {
  MethodChannel _channel;
  MagicViewController() {
    _channel = MethodChannel('ScanditView');
    _channel.setMethodCallHandler(_handleMethod);
  }
  Future<dynamic> _handleMethod(MethodCall call) async {
    print(call.method);
    switch (call.method) {
      case 'SCANDIT_RESULT':
      // String text = call.arguments as String;
      // return new Future.value("Text from native: $text");
    }
  }

  Future<void> receiveFromFlutter(String text) async {
    try {
      final String result =
          await _channel.invokeMethod('receiveFromFlutter', {"text": text});
      print("Result from native: $result");
    } on PlatformException catch (e) {
      print("Error from native: $e.message");
    }
  }
}
