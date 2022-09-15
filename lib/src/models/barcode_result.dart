import 'package:flutter_scandit_plugin/src/models/symbology.dart';

class BarcodeResult {
  /// actual data which was encoded in the barcode
  final String data;

  /// symbology which was used to encode the barcode
  final Symbology symbology;

  BarcodeResult({required this.data, required this.symbology});
}
