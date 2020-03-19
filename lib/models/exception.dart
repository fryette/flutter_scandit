part of '../flutter_scandit.dart';


/// Generic Flutter Scandit Barcode Exception
class BarcodeScanException implements Exception {
  final String message;
  static const String defaultErrorMessage = "Unknown platform error";

  BarcodeScanException([String errorMessage = defaultErrorMessage])
      : this.message = errorMessage;

  factory BarcodeScanException.fromPlatformException(
          PlatformException exception) =>
      BarcodeScanException(exception.message);

  @override
  String toString() {
    if (message == null) return "Barcode Scan Exception";
    return "Barcode Scan Exception: $message";
  }
}

/// Exception caused by missing Scandit licence key
class MissingLicenceException implements BarcodeScanException {
  final String message;

  MissingLicenceException([String errorMessage]) : this.message = errorMessage;

  factory MissingLicenceException.fromPlatformException(
          PlatformException exception) =>
      MissingLicenceException(exception.message);

  @override
  String toString() {
    if (message == null) return "Missing Licence Exception";
    return "Missing Licence Exception: $message";
  }
}

/// Exception caused denied camera permissions
class CameraPermissionDeniedException implements BarcodeScanException {
  final String message;

  CameraPermissionDeniedException([String errorMessage])
      : this.message = errorMessage;

  factory CameraPermissionDeniedException.fromPlatformException(
          PlatformException exception) =>
      CameraPermissionDeniedException(exception.message);

  @override
  String toString() {
    if (message == null) return "Camera Permission Denied Exception";
    return "Camera Permission Denied Exception: $message";
  }
}

/// Exception caused by unexpected failure in initialising the camera
class CameraInitialisationException implements BarcodeScanException {
  final String message;

  CameraInitialisationException([String errorMessage])
      : this.message = errorMessage;

  factory CameraInitialisationException.fromPlatformException(
          PlatformException exception) =>
      CameraInitialisationException(exception.message);

  @override
  String toString() {
    if (message == null) return "Camera Initialisation Exception";
    return "Camera Initialisation Exception: $message";
  }
}

/// Exception caused by not finding a camera to use for scanning
class NoCameraException implements BarcodeScanException {
  final String message;

  NoCameraException([String errorMessage]) : this.message = errorMessage;

  factory NoCameraException.fromPlatformException(
          PlatformException exception) =>
      NoCameraException(exception.message);

  @override
  String toString() {
    if (message == null) return "No Camera Exception";
    return "No Camera Exception: $message";
  }
}
