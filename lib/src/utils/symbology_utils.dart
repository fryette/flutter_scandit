import '../models/symbology.dart';

/// Simple utilities for dealing with symbology
class SymbologyUtils {
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

  /// get symbology string representation
  static String getSymbologyString(Symbology symbology) {
    if (_symbologyMap.containsKey(symbology)) {
      return _symbologyMap[symbology]!;
    } else {
      return symbology.toString(); // fallback
    }
  }

  /// get symbology from string
  static Symbology getSymbology(String symbologyString) {
    if (_symbologyMap.containsValue(symbologyString)) {
      return _symbologyMap.entries
          .firstWhere((MapEntry<Symbology, String> entry) => entry.value == symbologyString)
          .key;
    } else {
      return Symbology.UNKNOWN;
    }
  }
}
