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

class MissingLicenseException extends BarcodeScanException {
  MissingLicenseException([super.message]);

  @override
  String toString() {
    return "Missing Licence Exception: $message";
  }
}

class CameraPermissionDeniedException extends BarcodeScanException {
  CameraPermissionDeniedException([super.message]);

  @override
  String toString() {
    return "Camera Permission Denied Exception: $message";
  }
}

class CameraInitializationException extends BarcodeScanException {
  CameraInitializationException([super.message]);

  @override
  String toString() {
    return "Camera Initialization Exception: $message";
  }
}

class NoCameraException extends BarcodeScanException {
  NoCameraException([super.message]);

  @override
  String toString() {
    return "No Camera Exception: $message";
  }
}
