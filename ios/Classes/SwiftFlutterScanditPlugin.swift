import Flutter
import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture
import Foundation
import WebKit
public class SwiftFlutterScanditPlugin: NSObject, FlutterPlugin {
    private static var VIEW_ID = "ScanditPlatformView"

    var registrar: FlutterPluginRegistrar!
    var result: FlutterResult?
    var hostViewController: UIViewController!
    public static func register(with registrar: FlutterPluginRegistrar) {
        let viewFactory = ScanditViewFactory(messenger: registrar.messenger())
        registrar.register(viewFactory, withId: SwiftFlutterScanditPlugin.VIEW_ID)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    }
}

public class ScanditViewFactory: NSObject, FlutterPlatformViewFactory {
    let messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(withFrame frame: CGRect,
                       viewIdentifier viewId: Int64,
                       arguments args: Any?) -> FlutterPlatformView {
        return ScanditPlatformView( messenger: messenger,
                                 frame: frame, viewId: viewId,
                                 args: args)
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

}
public class ScanditPlatformView: NSObject, FlutterPlatformView {
    private static var LICENSE_KEY = "licenseKey"
    private static var SYMBOLOGIES_KEY = "symbologies"
    private static var SCANDIT_CHANNEL_NAME = "ScanditView"
    private static var SCANDIT_RESULT_METHOD_NAME = "SCANDIT_RESULT"

    let viewId: Int64
    var scanditView: ScanditView
    let messenger: FlutterBinaryMessenger
    let channel: FlutterMethodChannel
    var result: FlutterResult?
    static var SYMBOLOGIES_MAP: Dictionary<String, Symbology> = ["EAN13_UPCA":.ean13UPCA,
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
    init(messenger: FlutterBinaryMessenger,
         frame: CGRect,
         viewId: Int64,
         args: Any?) {
        self.messenger = messenger
        self.viewId = viewId
        self.channel = FlutterMethodChannel(name: ScanditPlatformView.SCANDIT_CHANNEL_NAME, binaryMessenger: messenger)
        let dict = args as! NSDictionary
        var symbologies = [Symbology]()
        if let passedSymbologies = dict[ScanditPlatformView.SYMBOLOGIES_KEY] as? [String] {
            symbologies = passedSymbologies.map {
                ScanditPlatformView.convertToSymbology(name: $0)
            }
            .filter{
                $0 != nil
            }
            .map{
                $0!
            }
        }
        else {
            symbologies = [.ean13UPCA] // default
        }
        self.scanditView = ScanditView(with: (dict[ScanditPlatformView.LICENSE_KEY]! as? String)!,symbologies: symbologies)
        super.init()
        self.scanditView.delegate = self;
    }

    public func sendFromNative(_ value: Dictionary<String, String?>) {
        channel.invokeMethod(ScanditPlatformView.SCANDIT_RESULT_METHOD_NAME, arguments: value)
    }

    public func view() -> UIView {
        return scanditView
    }

    private static func convertSymbologyToString(symbology: Symbology) -> String? {
        if(SYMBOLOGIES_MAP.values.contains(symbology)){
            if let match = SYMBOLOGIES_MAP.first(where: {
                $1 == symbology
            })
            {
                return match.key
            }
        }
        return symbology.description;
    }

    private static func convertToSymbology(name: String) -> Symbology? {
        return SYMBOLOGIES_MAP[name];
    }

}
extension ScanditPlatformView: BarcodeScannerDelegate {
    func didScanBarcodeWithResult(data: String, symbology: Symbology) {
        sendFromNative(["data": data, "symbology": ScanditPlatformView.convertSymbologyToString(symbology:symbology)])
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
class ScanditView: UIView {
    weak var delegate: BarcodeScannerDelegate?
    var licenseKey: String!
    private var symbologies: [Symbology]!
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!
    var closeImage: UIImage?
    private var backButton: UIButton = UIButton(type: .custom)
    func sendFromNative(text: String){
    }

    func receiveFromFlutter(text: String) {
    }

    convenience init(with licenseKey: String, symbologies: [Symbology]) {
        self.init(frame: CGRect.zero)
        self.licenseKey = licenseKey
        self.symbologies = symbologies
        setupRecognition()
        barcodeCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow == nil {
            // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
            // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
            // it's a good idea to first disable barcode capture as well.
            barcodeCapture.isEnabled = false
            camera?.switch(toDesiredState: .off)
        } else {
            // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
            // completely turn on.
            barcodeCapture.isEnabled = true
            camera?.switch(toDesiredState: .on)
        }
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed(licenseKey: licenseKey)
        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)
        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommenededCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommenededCameraSettings)
        // The barcode capturing process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let settings = BarcodeCaptureSettings()
        
        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        //symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        for symbology in self.symbologies {
            settings.set(symbology: symbology, enabled: true)
        }
        // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
        // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
        // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
        // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        let symbologySettings = settings.settings(for: .code39)
        symbologySettings.activeSymbolCounts = Set(7...20) as Set<NSNumber>
        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: settings)
        //barcodeCapture.feedback.success = Feedback(vibration: nil, sound: Sound.default)
        let feedback = BarcodeCaptureFeedback()
        feedback.success = Feedback(vibration: Vibration.default, sound: nil);
        barcodeCapture.feedback = feedback
        
        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(captureView)
        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        
        //overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture)
        //overlay.viewfinder = RectangularViewfinder()
        //captureView.addOverlay(overlay)
    }

}
extension ScanditView: BarcodeCaptureListener {
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcodes.first else {
            return
        }
        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new results until
        // the capture mode is enabled again. Note that disabling the capture mode does not stop the camera, the camera
        // continues to stream frames until it is turned off.
        barcodeCapture.isEnabled = true
        // If you are not disabling barcode capture here and want to continue scanning, consider setting the
        // codeDuplicateFilter when creating the barcode capture settings to around 500 or even -1 if you do not want
        // codes to be scanned more than once.
        // Get the human readable name of the symbology and assemble the result to be shown.
        guard let barcodeData = barcode.data else {
            return
        }
        DispatchQueue.main.async {
            self.delegate?.didScanBarcodeWithResult(data: barcodeData, symbology: barcode.symbology)
            //self.dismiss(animated: false, completion: nil)
        }
    }
}
