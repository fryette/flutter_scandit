import 'symbology.dart';

/// Result of scanning a barcode
class BarcodeResult {
  /// actual data which was encoded in the barcode
  final String data;

  /// symbology which was used to encode the barcode
  final Symbology symbology;

  BarcodeResult({this.data, this.symbology});
}
