import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'models/symbology.dart';
part 'utils/symbology_utils.dart';
part 'models/barcode_result.dart';
part 'models/exception.dart';

class FlutterScandit {
  static const MethodChannel _channel = const MethodChannel('flutter_scandit');

  static const String _licenseKeyField = "licenseKey";
  static const String _symbologiesField = "symbologies";

  // errors
  static const String _errorNoLicence = "MISSING_LICENCE";
  static const String _errorPermissionDenied = "CAMERA_PERMISSION_DENIED";
  static const String _errorCameraInitialisation =
      "CAMERA_INITIALISATION_ERROR";
  static const String _errorNoCamera = "NO_CAMERA";
  static const String _errorUnknown = "UNKNOWN_ERROR";

  final String licenseKey;
  final List<Symbology> symbologies;

  static const List<Symbology> defaultSymbologoes = [Symbology.EAN13_UPCA];

  FlutterScandit(
      {@required this.licenseKey, this.symbologies = defaultSymbologoes});

  /// Scan barcode using camera and get a `BarcodeResult` back
  Future<BarcodeResult> scanBarcode() async {
    Map<String, dynamic> arguments = {
      _licenseKeyField: licenseKey,
      _symbologiesField:
          symbologies.map(SymbologyUtils.getSymbologyString).toList()
    };

    try {
      var result = await _channel.invokeMethod('scanBarcode', arguments);
      final Map<String, dynamic> barcode = Map<String, dynamic>.from(result);

      return BarcodeResult(
        data: barcode["data"],
        symbology: SymbologyUtils.getSymbology(barcode["symbology"] as String),
      );
    } on PlatformException catch (e) {
      throw _resolveException(e);
    }
  }

  static BarcodeScanException _resolveException(PlatformException e) {
    switch (e.code) {
      case _errorNoLicence:
        return MissingLicenceException.fromPlatformException(e);
      case _errorPermissionDenied:
        return CameraPermissionDeniedException.fromPlatformException(e);
      case _errorCameraInitialisation:
        return CameraInitialisationException.fromPlatformException(e);
      case _errorNoCamera:
        return NoCameraException.fromPlatformException(e);
      case _errorUnknown:
        return BarcodeScanException.fromPlatformException(e);
      default:
        return BarcodeScanException(
            e.message ?? e.code ?? BarcodeScanException.defaultErrorMessage);
    }
  }
}
