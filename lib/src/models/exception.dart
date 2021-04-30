class BarcodeScanException implements Exception {
  static const String defaultErrorMessage = "Unknown platform error";
  final String? _message;

  String get message => _message ?? defaultErrorMessage;

  BarcodeScanException([this._message]);

  @override
  String toString() {
    return "Barcode Scan Exception: $message";
  }
}

class MissingLicenceException extends BarcodeScanException {
  MissingLicenceException([String? message]) : super(message);

  @override
  String toString() {
    return "Missing Licence Exception: $message";
  }
}

class CameraPermissionDeniedException extends BarcodeScanException {
  CameraPermissionDeniedException([String? message]) : super(message);

  @override
  String toString() {
    return "Camera Permission Denied Exception: $message";
  }
}

class CameraInitializationException extends BarcodeScanException {
  CameraInitializationException([String? message]) : super(message);

  @override
  String toString() {
    return "Camera Initialization Exception: $message";
  }
}

class NoCameraException extends BarcodeScanException {
  NoCameraException([String? message]) : super(message);

  @override
  String toString() {
    return "No Camera Exception: $message";
  }
}
