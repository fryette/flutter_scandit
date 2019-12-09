import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

class FlutterScandit {
  static const MethodChannel _channel = const MethodChannel('flutter_scandit');

  static const String _licenseKeyField = "licenseKey";
  static const String _symbologiesField = "symbologies";

  final String licenseKey;
  final List<Symbology> symbologies;

  static const Map<Symbology, String> _symbologyMap = {
    Symbology.EAN13_UPCA: "EAN13_UPCA",
    Symbology.UPCE: "UPCE",
    Symbology.EAN8: "EAN8",
    Symbology.CODE39: "CODE39",
    Symbology.CODE93: "CODE93",
    Symbology.CODE128: "CODE128",
    Symbology.CODE11: "CODE11",
    Symbology.CODE25: "CODE25",
    Symbology.CODABAR: "CODABAR",
    Symbology.INTERLEAVED_TWO_OF_FIVE: "INTERLEAVED_TWO_OF_FIVE",
    Symbology.MSI_PLESSEY: "MSI_PLESSEY",
    Symbology.QR: "QR",
    Symbology.DATA_MATRIX: "DATA_MATRIX",
    Symbology.AZTEC: "AZTEC",
    Symbology.MAXI_CODE: "MAXI_CODE",
    Symbology.DOT_CODE: "DOT_CODE",
    Symbology.KIX: "KIX",
    Symbology.RM4SCC: "RM4SCC",
    Symbology.GS1_DATABAR: "GS1_DATABAR",
    Symbology.GS1_DATABAR_EXPANDED: "GS1_DATABAR_EXPANDED",
    Symbology.GS1_DATABAR_LIMITED: "GS1_DATABAR_LIMITED",
    Symbology.PDF417: "PDF417",
    Symbology.MICRO_PDF417: "MICRO_PDF417",
    Symbology.MICRO_QR: "MICRO_QR",
    Symbology.CODE32: "CODE32",
    Symbology.LAPA4SC: "LAPA4SC",
  };

  static const List<Symbology> defaultSymbologoes = [Symbology.EAN13_UPCA];

  FlutterScandit(
      {@required this.licenseKey, this.symbologies = defaultSymbologoes});

  Future<BarcodeResult> scanBarcode() async {
    Map<String, dynamic> arguments = {
      _licenseKeyField: licenseKey,
      _symbologiesField: symbologies.map(getSymbologyString).toList()
    };

    var result = await _channel.invokeMethod('scanBarcode', arguments);
    final Map<String, dynamic> barcode = Map<String, dynamic>.from(result);

    return BarcodeResult(
      data: barcode["data"],
      symbology: barcode["symbology"],
    );
  }

  static String getSymbologyString(Symbology symbology) {
    if (_symbologyMap.containsKey(symbology)) {
      return _symbologyMap[symbology];
    } else {
      return symbology.toString();
    }
  }

  static Symbology getSymbology(String symbologyString) {
    if (_symbologyMap.containsValue(symbologyString)) {
      return _symbologyMap.entries
          .firstWhere((MapEntry<Symbology, String> entry) =>
              entry.value == symbologyString)
          .key;
    } else {
      return null;
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
