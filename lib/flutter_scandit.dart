import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

class FlutterScandit {
  static const MethodChannel _channel = const MethodChannel('flutter_scandit');

  final String licenseKey;
  final List<Symbology> symbologies;

  static const List<Symbology> defaultSymbologoes = [Symbology.EAN13_UPCA];
  
  FlutterScandit({@required this.licenseKey, this.symbologies = defaultSymbologoes});

  Future<BarcodeResult> scanBarcode() async {
        Map<String,dynamic> arguments = {
          "licenseKey": licenseKey,
          "symbologies": symbologies.map(_getSymbologyString).toList()
        };

        var result = await _channel.invokeMethod('scanBarcode',arguments);
        print(result);
        final Map<String, dynamic> barcode = Map<String, dynamic>.from(result);
        
    return BarcodeResult(
        data: barcode["data"], symbology: barcode["symbology"]);
  }

  static String _getSymbologyString(Symbology symbology) {
    switch (symbology) {
      case Symbology.EAN13_UPCA:
        return "EAN13_UPCA";
      case Symbology.UPCE:
        return "UPCE";
      case Symbology.EAN8:
        return "EAN8";
      case Symbology.CODE39:
        return "CODE39";
      case Symbology.CODE93:
        return "CODE93";
      case Symbology.CODE128:
        return "CODE128";
      case Symbology.CODE11:
        return "CODE11";
      case Symbology.CODE25:
        return "CODE25";
      case Symbology.CODABAR:
        return "CODABAR";
      case Symbology.INTERLEAVED_TWO_OF_FIVE:
        return "INTERLEAVED_TWO_OF_FIVE";
      case Symbology.MSI_PLESSEY:
        return "MSI_PLESSEY";
      case Symbology.QR:
        return "QR";
      case Symbology.DATA_MATRIX:
        return "DATA_MATRIX";
      case Symbology.AZTEC:
        return "AZTEC";
      case Symbology.MAXI_CODE:
        return "MAXI_CODE";
      case Symbology.DOT_CODE:
        return "DOT_CODE";
      case Symbology.KIX:
        return "KIX";
      case Symbology.RM4SCC:
        return "RM4SCC";
      case Symbology.GS1_DATABAR:
        return "GS1_DATABAR";
      case Symbology.GS1_DATABAR_EXPANDED:
        return "GS1_DATABAR_EXPANDED";
      case Symbology.GS1_DATABAR_LIMITED:
        return "GS1_DATABAR_LIMITED";
      case Symbology.PDF417:
        return "PDF417";
      case Symbology.MICRO_PDF417:
        return "MICRO_PDF417";
      case Symbology.MICRO_QR:
        return "MICRO_QR";
      case Symbology.CODE32:
        return "CODE32";
      case Symbology.LAPA4SC:
        return "LAPA4SC";
      default:
        return symbology.toString();
    }
  }
}

class BarcodeResult {
  final String data;
  final String symbology;

  BarcodeResult({this.data, this.symbology});
}

enum Symbology {
  EAN13_UPCA,
  UPCE,
  EAN8,
  CODE39,
  CODE93,
  CODE128,
  CODE11,
  CODE25,
  CODABAR,
  INTERLEAVED_TWO_OF_FIVE,
  MSI_PLESSEY,
  QR,
  DATA_MATRIX,
  AZTEC,
  MAXI_CODE,
  DOT_CODE,
  KIX,
  RM4SCC,
  GS1_DATABAR,
  GS1_DATABAR_EXPANDED,
  GS1_DATABAR_LIMITED,
  PDF417,
  MICRO_PDF417,
  MICRO_QR,
  CODE32,
  LAPA4SC,
}
