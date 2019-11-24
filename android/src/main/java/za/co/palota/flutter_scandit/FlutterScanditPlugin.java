package za.co.palota.flutter_scandit;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.scandit.datacapture.barcode.data.Symbology;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/** FlutterScanditPlugin */
public class FlutterScanditPlugin implements MethodCallHandler, ActivityResultListener {
  private static final String TAG = FlutterScanditPlugin.class.getSimpleName();
  private static final String PLUGIN_CHANNEL = "flutter_scandit";
  private static final int BARCODE_CAPTURE_CODE = 1111;

  public static final String LICENSE_KEY = "licenseKey";
  public static final String NO_LICENSE = "MISSING_LICENCE";

  public static final String SYMBOLOGIES_KEY = "symbologies";

  private static FlutterScanditPlugin instance;
  private static Activity activity;
  private static Result pendingResult;

  private final Registrar registrar;

  private FlutterScanditPlugin(FlutterActivity activity, final Registrar registrar) {
    FlutterScanditPlugin.activity = activity;
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), PLUGIN_CHANNEL);
    instance = new FlutterScanditPlugin((FlutterActivity)registrar.activity(), registrar);
    registrar.addActivityResultListener(instance);
    channel.setMethodCallHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    pendingResult = result;
    if(call.method.equals("scanBarcode")){
      Map<String, Object> args = (Map<String, Object>) call.arguments;
      if(args.containsKey(LICENSE_KEY)) {
        ArrayList<String> passedSymbologies = (ArrayList<String>)args.get(SYMBOLOGIES_KEY);
        List<Symbology> symbologies = new ArrayList<Symbology>();
        for(String symbologyName:passedSymbologies){
          Symbology symbology = convertToSymbology(symbologyName);
          if(symbology != null){
            symbologies.add(symbology);
          }
        }
        if(symbologies.isEmpty()){
          symbologies.add(Symbology.EAN13_UPCA); // default
        }

        startBarcodeScanner((String)args.get(LICENSE_KEY),passedSymbologies);
      } else {
        result.error(NO_LICENSE,null,null);
      }
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if(requestCode == BARCODE_CAPTURE_CODE) {
      if(resultCode == Activity.RESULT_OK){
        try{
          String barcode = data.getStringExtra(BarcodeScanActivity.BARCODE_DATA);
          String symbology = data.getStringExtra(BarcodeScanActivity.BARCODE_SYMBOLOGY);
          Map<String,String> result = new HashMap<String,String>();
          result.put("data",barcode);
          result.put("symbology",symbology);
          pendingResult.success(result);
        } catch(Exception e) {
          pendingResult.error(e.toString(),null,null);
        }
      } else if(resultCode == Activity.RESULT_CANCELED){
        pendingResult.success(new HashMap<String,String>());
      }
      else if(data != null) {
        String errorCode = data.getStringExtra(BarcodeScanActivity.BARCODE_ERROR);
        pendingResult.error(errorCode,null,null);
      } else {
        pendingResult.error("UNKNOWN_ERROR",null,null);
      }
    }
    return false;
  }

  private void startBarcodeScanner(String licenseKey, ArrayList<String> symbologies) {
    try {
      Intent intent = new Intent(activity, BarcodeScanActivity.class);
      intent.putExtra(LICENSE_KEY,licenseKey);
      intent.putStringArrayListExtra(SYMBOLOGIES_KEY,symbologies);
      activity.startActivityForResult(intent, BARCODE_CAPTURE_CODE);
    } catch (Exception e) {
      Log.e(TAG, "startView: " + e.getLocalizedMessage());
    }
  }

  public static Symbology convertToSymbology(String name){
    switch (name){
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
