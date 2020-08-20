package com.ysampir.flutter_scandit_plugin;

import com.scandit.datacapture.barcode.data.Symbology;

public final class SymbologyEx {
    public static Symbology convertToSymbology(String name) {
        switch (name) {
            case "EAN13_UPCA":
                return Symbology.EAN13_UPCA;
            case "UPCE":
                return Symbology.UPCE;
            case "EAN8":
                return Symbology.EAN8;
            case "CODE39":
                return Symbology.CODE39;
            case "CODE128":
                return Symbology.CODE128;
            case "CODE11":
                return Symbology.CODE11;
            case "CODE25":
                return Symbology.CODE25;
            case "CODABAR":
                return Symbology.CODABAR;
            case "INTERLEAVED_TWO_OF_FIVE":
                return Symbology.INTERLEAVED_TWO_OF_FIVE;
            case "MSI_PLESSEY":
                return Symbology.MSI_PLESSEY;
            case "QR":
                return Symbology.QR;
            case "DATA_MATRIX":
                return Symbology.DATA_MATRIX;
            case "AZTEC":
                return Symbology.AZTEC;
            case "MAXI_CODE":
                return Symbology.MAXI_CODE;
            case "DOT_CODE":
                return Symbology.DOT_CODE;
            case "KIX":
                return Symbology.KIX;
            case "RM4SCC":
                return Symbology.RM4SCC;
            case "GS1_DATABAR":
                return Symbology.GS1_DATABAR;
            case "GS1_DATABAR_EXPANDED":
                return Symbology.GS1_DATABAR_EXPANDED;
            case "GS1_DATABAR_LIMITED":
                return Symbology.GS1_DATABAR_LIMITED;
            case "PDF417":
                return Symbology.PDF417;
            case "MICRO_PDF417":
                return Symbology.MICRO_PDF417;
            case "MICRO_QR":
                return Symbology.MICRO_QR;
            case "CODE32":
                return Symbology.CODE32;
            case "LAPA4SC":
                return Symbology.LAPA4SC;
            default:
                return null;
        }
    }
}
