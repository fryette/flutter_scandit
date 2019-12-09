import Flutter
import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture

public class SwiftFlutterScanditPlugin: NSObject, FlutterPlugin {
    private static var LICENSE_KEY = "licenseKey"
    private static var NO_LICENSE = "MISSING_LICENCE"
    
    private static var SYMBOLOGIES_KEY = "symbologies"
    
    private static var SYMBOLOGIES_MAP: Dictionary<String, Symbology> = ["EAN13_UPCA":.ean13UPCA,
                                                                         "UPCE":.upce,
                                                                         "EAN8":.ean8,
                                                                         "CODE39":.code39,
                                                                         "CODE128":.code128,
                                                                         "CODE11":.code11,
                                                                         "CODE25":.code25,
                                                                         "CODABAR":.codabar,
                                                                         "INTERLEAVED_TWO_OF_FIVE":.interleavedTwoOfFive,
                                                                         "MSI_PLESSEY":.msiPlessey,
                                                                         "QR":.qr,
                                                                         "DATA_MATRIX":.dataMatrix,
                                                                         "AZTEC":.aztec,
                                                                         "MAXI_CODE":.maxiCode,
                                                                         "DOT_CODE":.dotCode,
                                                                         "KIX":.kix,
                                                                         "RM4SCC":.rm4scc,
                                                                         "GS1_DATABAR":.gs1Databar,
                                                                         "GS1_DATABAR_EXPANDED":.gs1DatabarExpanded,
                                                                         "GS1_DATABAR_LIMITED":.gs1DatabarLimited,
                                                                         "PDF417":.pdf417,
                                                                         "MICRO_PDF417":.microPDF417,
                                                                         "MICRO_QR":.microQR,
                                                                         "CODE32":.code32,
                                                                         "LAPA4SC":.lapa4SC];
    
    var registrar: FlutterPluginRegistrar!
    
    var result: FlutterResult?
    var hostViewController: UIViewController!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_scandit", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterScanditPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        if let delegate = UIApplication.shared.delegate , let window = delegate.window, let root = window?.rootViewController {
            instance.hostViewController = root
            instance.registrar = registrar
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "scanBarcode") {
            if let args = call.arguments as? NSDictionary {
                if(args[SwiftFlutterScanditPlugin.LICENSE_KEY] != nil){
                    var symbologies = [Symbology]()
                    if let passedSymbologies = args[SwiftFlutterScanditPlugin.SYMBOLOGIES_KEY] as? [String] {
                        symbologies = passedSymbologies.map {convertToSymbology(name: $0)}.filter{$0 != nil}.map{$0!}
                    } else {
                        symbologies = [.ean13UPCA] // default
                    }
                    
                    self.result = result
                    let viewController: BarcodeScannerViewController = BarcodeScannerViewController(with: (args[SwiftFlutterScanditPlugin.LICENSE_KEY]! as? String)!,symbologies: symbologies)
                    let navigationController = UINavigationController(rootViewController: viewController)
                    viewController.delegate = self
                    
                    if hostViewController != nil {
                        let closeIconKey = registrar.lookupKey(forAsset: "assets/close.png", fromPackage: "flutter_scandit")
                        if let closeIconPath = Bundle.main.path(forResource: closeIconKey, ofType: nil) {
                            viewController.closeImage = UIImage(contentsOfFile: closeIconPath)
                        }
                        hostViewController.present(navigationController, animated: true, completion: nil)
                    }
                } else {
                    result(SwiftFlutterScanditPlugin.NO_LICENSE)
                }
            } else {
                result(SwiftFlutterScanditPlugin.NO_LICENSE)
            }
            
        }
        else {
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    private func convertSymbologyToString(symbology: Symbology) -> String? {
        if(SwiftFlutterScanditPlugin.SYMBOLOGIES_MAP.values.contains(symbology)){
            if let match = SwiftFlutterScanditPlugin.SYMBOLOGIES_MAP.first(where: {$1 == symbology}) {
                return match.key
            }
        }
        return symbology.description;
    }
    
    private func convertToSymbology(name: String) -> Symbology? {
        return SwiftFlutterScanditPlugin.SYMBOLOGIES_MAP[name];
    }
    
}



extension SwiftFlutterScanditPlugin: BarcodeScannerDelegate {
    func didScanBarcodeWithResult(data: String, symbology: Symbology) {
        if let channelResult = result {
            channelResult(["data": data,"symbology": convertSymbologyToString(symbology:symbology)])
        }
    }
    
    func didCancel() {
        if let channelResult = result {
            channelResult([String: String]())
        }
    }
    
    func didFailWithErrorCode(code: String) {
        if let channelResult = result {
            channelResult(code as NSString)
        }
    }
}
