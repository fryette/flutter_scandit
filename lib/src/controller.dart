import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_scandit_plugin/src/models/index.dart';
import 'package:flutter_scandit_plugin/src/utils/symbology_utils.dart';

const String _errorNoLicence = "MISSING_LICENCE";
const String _errorPermissionDenied = "CAMERA_PERMISSION_DENIED";
const String _errorCameraInitialization = "CAMERA_INITIALIZATION_ERROR";
const String _errorNoCamera = "NO_CAMERA";
const String _errorUnknown = "UNKNOWN_ERROR";

const String _nativeMethodStopCameraAndCapturing = "STOP_CAMERA_AND_CAPTURING";
const String _nativeMethodStartCameraAndCapturing =
    "START_CAMERA_AND_CAPTURING";
const String _nativeMethodStartCapturing = "START_CAPTURING";

const String _callFromNativeScanResult = "SCANDIT_RESULT";
const String _callFromNativeScanDataArgument = "data";
const String _callFromNativeScanSymbologyArgument = "symbology";
const String _callFromNativeErrorCode = "ERROR_CODE";
const String _callFromNativeUnforeseenError = "UNFORESEEN_ERROR";

class ScanditController {
  static const MethodChannel _channel = MethodChannel('ScanditView');
  bool _disposed = false;

  final void Function(BarcodeResult) _scanned;
  final void Function(BarcodeScanException) _onError;

  ScanditController(this._scanned, this._onError) {
    _channel.setMethodCallHandler(_handleCallFromNative);
  }

  @mustCallSuper
  void dispose() {
    _channel.setMethodCallHandler(null);
    _disposed = true;
  }

  Future<void> startCamera() async {
    if (_disposed) return;
    await _channel.invokeMethod(_nativeMethodStartCameraAndCapturing);
  }

  Future<void> stopCamera() async {
    if (_disposed) return;
    await _channel.invokeMethod(_nativeMethodStopCameraAndCapturing);
  }

  Future<void> resumeBarcodeScanning() async {
    if (_disposed) return;
    await _channel.invokeMethod(_nativeMethodStartCapturing);
  }

  Future<dynamic> _handleCallFromNative(MethodCall call) async {
    BarcodeScanException error;
    switch (call.method) {
      case _callFromNativeScanResult:
        _handleScan(Map<String, String>.from(call.arguments as Map));
        return;
      case _callFromNativeErrorCode:
        error = _createExceptionByCode(call.arguments as String);
        break;
      case _callFromNativeUnforeseenError:
        error = BarcodeScanException(call.arguments as String);
        break;
      default:
        error = BarcodeScanException();
        break;
    }

    _onError.call(error);
  }

  static BarcodeScanException _createExceptionByCode(String errorCode) {
    switch (errorCode) {
      case _errorNoLicence:
        return MissingLicenseException();
      case _errorPermissionDenied:
        return CameraPermissionDeniedException();
      case _errorCameraInitialization:
        return CameraInitializationException();
      case _errorNoCamera:
        return NoCameraException();
      case _errorUnknown:
        return BarcodeScanException();
      default:
        return BarcodeScanException();
    }
  }

  void _handleScan(Map<String, String> arguments) {
    _scanned(
      BarcodeResult(
        data: arguments[_callFromNativeScanDataArgument]!,
        symbology: SymbologyUtils.getSymbology(
          arguments[_callFromNativeScanSymbologyArgument]!,
        ),
      ),
    );
  }
}
