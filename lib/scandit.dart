import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_scandit.dart';

class Scandit extends StatefulWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  final String licenseKey;
  final List<Symbology> symbologies;
  final Function(BarcodeResult) scanned;
  final Function(BarcodeScanException) onError;

  static const List<Symbology> defaultSymbologies = [Symbology.EAN13_UPCA];

  Scandit({
    Key key,
    @required this.licenseKey,
    @required this.scanned,
    @required this.onError,
    this.symbologies = defaultSymbologies,
  }) : super(key: key);

  @override
  _ScanditState createState() => _ScanditState();
}

class _ScanditState extends State<Scandit> {
  static const MethodChannel _channel = const MethodChannel('ScanditView');

  static const String _licenseKeyField = "licenseKey";
  static const String _symbologiesField = "symbologies";

  // errors
  static const String _errorNoLicence = "MISSING_LICENCE";
  static const String _errorPermissionDenied = "CAMERA_PERMISSION_DENIED";
  static const String _errorCameraInitialisation =
      "CAMERA_INITIALISATION_ERROR";
  static const String _errorNoCamera = "NO_CAMERA";
  static const String _errorUnknown = "UNKNOWN_ERROR";
  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethod);
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments = {
      _licenseKeyField: widget.licenseKey,
      _symbologiesField:
          widget.symbologies.map(SymbologyUtils.getSymbologyString).toList()
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'ScanditPlatformView',
        creationParams: arguments,
        creationParamsCodec: Scandit._decoder,
      );
    }

    return UiKitView(
      viewType: 'ScanditPlatformView',
      creationParams: arguments,
      creationParamsCodec: Scandit._decoder,
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print(call.method);
    switch (call.method) {
      case 'SCANDIT_RESULT':
        final barcode = Map<String, dynamic>.from(call.arguments);

        widget.scanned(
          BarcodeResult(
            data: barcode["data"],
            symbology:
                SymbologyUtils.getSymbology(barcode["symbology"] as String),
          ),
        );
        break;
      case 'ERROR_CODE':
        final exception = _resolveException(call.arguments as String);
        widget.onError(exception);
        break;
    }
  }

  static BarcodeScanException _resolveException(String errorCode) {
    switch (errorCode) {
      case _errorNoLicence:
        return MissingLicenceException();
      case _errorPermissionDenied:
        return CameraPermissionDeniedException();
      case _errorCameraInitialisation:
        return CameraInitialisationException();
      case _errorNoCamera:
        return NoCameraException();
      case _errorUnknown:
        return BarcodeScanException();
      default:
        return BarcodeScanException(BarcodeScanException.defaultErrorMessage);
      //e.message ?? e.code ?? BarcodeScanException.defaultErrorMessage);
    }
  }
}
