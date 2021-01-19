import 'package:flutter/services.dart';

/// Generic Flutter Scandit Barcode Exception
class BarcodeScanException implements Exception {
  final String message;
  static const String defaultErrorMessage = "Unknown platform error";

  BarcodeScanException([this.message = defaultErrorMessage]);

  factory BarcodeScanException.fromPlatformException(PlatformException exception) =>
      BarcodeScanException(exception.message);

  @override
  String toString() {
    if (message == null) return "Barcode Scan Exception";
    return "Barcode Scan Exception: $message";
  }
}

/// Exception caused by missing Scandit licence key
class MissingLicenceException implements BarcodeScanException {
  @override
  final String message;

  MissingLicenceException([this.message]);

  factory MissingLicenceException.fromPlatformException(PlatformException exception) =>
      MissingLicenceException(exception.message);

  @override
  String toString() {
    if (message == null) return "Missing Licence Exception";
    return "Missing Licence Exception: $message";
  }
}

/// Exception caused denied camera permissions
class CameraPermissionDeniedException implements BarcodeScanException {
  @override
  final String message;

  CameraPermissionDeniedException([this.message]);

  factory CameraPermissionDeniedException.fromPlatformException(PlatformException exception) =>
      CameraPermissionDeniedException(exception.message);

  @override
  String toString() {
    if (message == null) return "Camera Permission Denied Exception";
    return "Camera Permission Denied Exception: $message";
  }
}

/// Exception caused by unexpected failure in initializing the camera
class CameraInitializationException implements BarcodeScanException {
  @override
  final String message;

  CameraInitializationException([this.message]);

  factory CameraInitializationException.fromPlatformException(PlatformException exception) =>
      CameraInitializationException(exception.message);

  @override
  String toString() {
    if (message == null) return "Camera Initialization Exception";
    return "Camera Initialization Exception: $message";
  }
}

/// Exception caused by not finding a camera to use for scanning
class NoCameraException implements BarcodeScanException {
  @override
  final String message;

  NoCameraException([this.message]);

  factory NoCameraException.fromPlatformException(PlatformException exception) =>
      NoCameraException(exception.message);

  @override
  String toString() {
    if (message == null) return "No Camera Exception";
    return "No Camera Exception: $message";
  }
}
