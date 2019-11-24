import Flutter
import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture

public class SwiftFlutterScanditPlugin: NSObject, FlutterPlugin {
    private static var LICENSE_KEY = "licenseKey"
    private static var NO_LICENSE = "MISSING_LICENCE"
    
    private static var SYMBOLOGIES_KEY = "symbologies"
    
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
                    viewController.delegate = self
                    let navigationController = UINavigationController(rootViewController: viewController)
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
    
    private func convertToSymbology(name: String) -> Symbology? {
        switch name {
        case "EAN13_UPCA":
            return .ean13UPCA
        case "UPCE":
            return .upce
        case "EAN8":
            return .ean8
        case "CODE39":
            return .code39
        case "CODE128":
            return .code128
        case "CODE11":
            return .code11
        case "CODE25":
            return .code25
        case "CODABAR":
            return .codabar
        case "INTERLEAVED_TWO_OF_FIVE":
            return .interleavedTwoOfFive
        case "MSI_PLESSEY":
            return .msiPlessey
        case "QR":
            return .qr
        case "DATA_MATRIX":
            return .dataMatrix
        case "AZTEC":
            return .aztec
        case "MAXI_CODE":
            return .maxiCode
        case "DOT_CODE":
            return .dotCode
        case "KIX":
            return .kix
        case "RM4SCC":
            return .rm4scc
        case "GS1_DATABAR":
            return .gs1Databar
        case "GS1_DATABAR_EXPANDED":
            return .gs1DatabarExpanded
        case "GS1_DATABAR_LIMITED":
            return .gs1DatabarLimited
        case "PDF417":
            return .pdf417
        case "MICRO_PDF417":
            return .microPDF417
        case "MICRO_QR":
            return .microQR
        case "CODE32":
            return .code32
        case "LAPA4SC":
            return .lapa4SC
        default:
            return nil
        }
    }
    
}



extension SwiftFlutterScanditPlugin: BarcodeScannerDelegate {
    func didScanBarcodeWithResult(data: String, symbology: String) {
        if let channelResult = result {
            channelResult(["data": data,"symbology": symbology])
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
