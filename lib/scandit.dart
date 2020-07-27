import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_scandit.dart';

class Scandit extends StatefulWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  final String licenseKey;
  final List<Symbology> symbologies;
  final Function(BarcodeResult) scanned;

  static const List<Symbology> defaultSymbologoes = [Symbology.EAN13_UPCA];

  Scandit(
      {Key key,
      @required this.licenseKey,
      this.symbologies = defaultSymbologoes,
      @required this.scanned})
      : super(key: key);

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
    _channel.setMethodCallHandler(_handleMethod);
    super.initState();
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

    // final Map<String, String> args = {
    //   "licenseKey":
    //       "AV7ODgNVHAIAO8A7TAFjY2kQyTwrDPsAxSlvdyFpis0kMaiCsHXxyjxEDzvPKnez3mJi7RNGsy3BUaCaC2NzxLxDXVkmOW8kWHu5LNdQuIuSaqy0g1nReIVLZEvrcHV7xmvhTgMHqoETEDMRnSONdLkEyU7T1GpNmumRuO6Dk71/eEPt6FHb09ynPETZ+EO/Wh/01q3KCAsX5KawrtnknGlaveCz2HAXrFXWSystNBJO7rSnZTJdyIFF9ITFTUsLhuXeyWN2sZwOvaVm1L38lpDQMZLUnPGq6KG8fazsN0uCAOxQMr4ETk3dfw9aN9GqE2BKaeoLl6ZXdSDTwjUhygfISaUVt09l4Ko6OU4YcdUkp2AZPAgv98OUOCxcEadq4cn7tqg2p4Fum2x043EzX02zfTZgC4/UryEGcxXgBboyZMyViDbojXHkoPxN+Ba9kwWGWHJtoYu9GfebhyVjft0fiEguPolxp9SoRTjnq4UpnE//O9HYAuEBD8/6Nr+d10Jf+hn+MzE0mRLPsGFOmBPDmPMJi6+BYob808yhvJ9qTS2IyACE/wtKB2SZdawTC7wh2sbA/H9IWEDrbpxP7HaT2G79GZvx2VkxoNQtSWgR8TqHPtlo4Wjv0xOBPf92RceYz1GX+MtyIcglnh5d83vq04afYxpvZqhHZJiIJCUKkyzLXUPZMB0bBEIzQkntjdE/55u+kFY4aYeO/T0KwRSlafTeGbISUPrP2ozwZRa2CD41Btk2aCWlH+hSTGojbOEXzYNjPrBQQqMKt/0mJ+WA/s3wRNNHE67+HG/4OmEUr9sX6n9de35wO9QZ22JMpJpDow=="
    // };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          viewType: 'ScanditPlatformView',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: arguments,
          creationParamsCodec: Scandit._decoder);
    }
    return UiKitView(
        viewType: 'ScanditPlatformView',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: arguments,
        creationParamsCodec: Scandit._decoder);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print(call.method);
    switch (call.method) {
      case 'SCANDIT_RESULT':
        try {
          final barcode = Map<String, dynamic>.from(call.arguments);

          widget.scanned(BarcodeResult(
              data: barcode["data"],
              symbology:
                  SymbologyUtils.getSymbology(barcode["symbology"] as String)));
        } on PlatformException catch (e) {
          throw _resolveException(e);
        }
    }
  }

  void _onPlatformViewCreated(int id) {}

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
