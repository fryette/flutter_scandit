import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scandit/flutter_scandit.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_scandit');
  final FlutterScandit plugin = FlutterScandit(licenseKey: "123", symbologies: [Symbology.EAN13_UPCA]);

  setUp(() {
    
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('scanBarcode', () async {
    expect(await plugin.scanBarcode(), '42');
  });
}
