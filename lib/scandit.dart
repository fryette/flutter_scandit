import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_scandit.dart';

typedef ResumeBarcodeScanning = Future Function();

/// Make sure that you display this widghet only after the app was granted the camera
/// permissions from the user. You can use 'permission_handler' package or similar for this
/// matters.
class Scandit extends StatefulWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  static const List<Symbology> defaultSymbologies = [Symbology.EAN13_UPCA];
  final String licenseKey;
  final List<Symbology> symbologies;
  final Function(BarcodeResult, ResumeBarcodeScanning) scanned;
  final Function(BarcodeScanException) onError;

  const Scandit({
    Key key,
    @required this.licenseKey,
    @required this.scanned,
    @required this.onError,
    this.symbologies = defaultSymbologies,
  }) : super(key: key);

  @override
  _ScanditState createState() => _ScanditState();
}

class _ScanditState extends State<Scandit> with WidgetsBindingObserver {
  static const _channel = MethodChannel('ScanditView');

  static const String _licenseKeyField = "licenseKey";
  static const String _symbologiesField = "symbologies";

  // errors
  static const String _errorNoLicence = "MISSING_LICENCE";
  static const String _errorPermissionDenied = "CAMERA_PERMISSION_DENIED";
  static const String _errorCameraInitialisation =
      "CAMERA_INITIALISATION_ERROR";
  static const String _errorNoCamera = "NO_CAMERA";
  static const String _errorUnknown = "UNKNOWN_ERROR";

  static const String _platformViewId = "ScanditPlatformView";

  static const String _nativeMethodStopCameraAndCapturing =
      "STOP_CAMERA_AND_CAPTURING";
  static const String _nativeMethodStartCameraAndCapturing =
      "START_CAMERA_AND_CAPTURING";
  static const String _nativeMethodStartCapturing = "START_CAPTURING";

  static const String _callFromNativeScanResult = "SCANDIT_RESULT";
  static const String _callFromNativeScanDataArgument = "data";
  static const String _callFromNativeScanSymbologyArgument = "symbology";

  static const String _callFromNativeErrorCode = "ERROR_CODE";
  static const String _callFromNativeUnforeseenError = "UNFORESEEN_ERROR";

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleCallFromNative);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _channel.invokeMethod(_nativeMethodStopCameraAndCapturing);
    }
    if (state == AppLifecycleState.resumed) {
      _channel.invokeMethod(_nativeMethodStartCameraAndCapturing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildScanditPlatformView();
  }

  Widget _buildScanditPlatformView() {
    final arguments = {
      _licenseKeyField: widget.licenseKey,
      _symbologiesField:
          widget.symbologies.map(SymbologyUtils.getSymbologyString).toList()
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: _platformViewId,
        creationParams: arguments,
        creationParamsCodec: Scandit._decoder,
      );
    }

    return UiKitView(
      viewType: _platformViewId,
      creationParams: arguments,
      creationParamsCodec: Scandit._decoder,
    );
  }

  Future _resumeBarcodeScanning() async {
    await _channel.invokeMethod(_nativeMethodStartCapturing);
  }

  Future<dynamic> _handleCallFromNative(MethodCall call) async {
    switch (call.method) {
      case _callFromNativeScanResult:
        _hanldeScan(Map<String, String>.from(call.arguments as Map));
        break;
      case _callFromNativeErrorCode:
        widget.onError(_createExceptionByCode(call.arguments as String));
        break;
      case _callFromNativeUnforeseenError:
        widget.onError(BarcodeScanException(call.arguments as String));
        break;
      default:
        widget.onError(BarcodeScanException());
        break;
    }
  }

  void _hanldeScan(Map<String, String> arguments) {
    widget.scanned(
      BarcodeResult(
        data: arguments[_callFromNativeScanDataArgument],
        symbology: SymbologyUtils.getSymbology(
            arguments[_callFromNativeScanSymbologyArgument]),
      ),
      _resumeBarcodeScanning,
    );
  }

  static BarcodeScanException _createExceptionByCode(String errorCode) {
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
        return BarcodeScanException();
    }
  }
}
