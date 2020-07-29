package za.co.palota.flutter_scandit;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.scandit.datacapture.barcode.capture.BarcodeCapture;
import com.scandit.datacapture.barcode.capture.BarcodeCaptureListener;
import com.scandit.datacapture.barcode.capture.BarcodeCaptureSession;
import com.scandit.datacapture.barcode.capture.BarcodeCaptureSettings;
import com.scandit.datacapture.barcode.data.Barcode;
import com.scandit.datacapture.barcode.data.Symbology;
import com.scandit.datacapture.core.capture.DataCaptureContext;
import com.scandit.datacapture.core.data.FrameData;
import com.scandit.datacapture.core.source.Camera;
import com.scandit.datacapture.core.source.FrameSourceState;
import com.scandit.datacapture.core.ui.DataCaptureView;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class ScanditView implements PlatformView, MethodChannel.MethodCallHandler, BarcodeCaptureListener {
    private final MethodChannel _methodChannel;
    private final Context _context;
    private final HashSet<Symbology> _symbologies = new HashSet<>();
    private String _licenceKey;

    private DataCaptureContext _dataCaptureContext;
    private BarcodeCapture _barcodeCapture;
    private Camera _camera;
    private DataCaptureView _dataCaptureView;

    ScanditView(Context context, BinaryMessenger messenger, int id, Object args) {
        _context = context;
        _methodChannel = new MethodChannel(messenger, "ScanditView");
        _methodChannel.setMethodCallHandler(this);

        if (parseInitializationArguments(args))
        {
            initializeAndStartBarcodeScanning();
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "STOP_CAMERA_AND_CAPTURING":
                stopCameraAndCapturing();
                result.success("stopped");
                break;
            case "START_CAMERA_AND_CAPTURING":
                startCameraAndCapturing();
                result.success("started");
                break;
            case "START_CAPTURING":
                startBarcodeCapturing();
                result.success("started");
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public View getView() {
        return _dataCaptureView;
    }

    @Override
    public void dispose() {
        _methodChannel.setMethodCallHandler(null);

        if (_barcodeCapture != null && _dataCaptureContext != null) {
            _barcodeCapture.removeListener(this);
            _dataCaptureContext.removeMode(_barcodeCapture);
        }

        _dataCaptureView = null;
    }

    private boolean parseInitializationArguments(Object arguments) {
        Map<String, Object> argsMap = (Map<String, Object>) arguments;
        if (argsMap.containsKey(MethodCallHandlerImpl.PARAM_LICENSE_KEY)) {
            _licenceKey = (String) argsMap.get(MethodCallHandlerImpl.PARAM_LICENSE_KEY);

            ArrayList<String> passedSymbologies = (ArrayList<String>) argsMap.get(MethodCallHandlerImpl.PARAM_SYMBOLOGIES);
            for (String symbologyName : passedSymbologies) {
                Symbology symbology = MethodCallHandlerImpl.convertToSymbology(symbologyName);
                if (symbology != null) {
                    _symbologies.add(symbology);
                }
            }
            if (_symbologies.isEmpty()) {
                _symbologies.add(Symbology.EAN13_UPCA); // default
            }
            return  true;
        } else {
            handleError(MethodCallHandlerImpl.ERROR_NO_LICENSE);
            return false;
        }
    }

    private void initializeAndStartBarcodeScanning() {
        try {
            _dataCaptureContext = DataCaptureContext.forLicenseKey(_licenceKey);

            // Use the default camera and set it as the frame source of the context.
            // The camera is off by default and must be turned on to start streaming frames to the data
            // capture context for recognition.
            _camera = Camera.getDefaultCamera();
            if (_camera != null) {
                _camera.applySettings(BarcodeCapture.createRecommendedCameraSettings());
                _dataCaptureContext.setFrameSource(_camera);
            } else {
                handleError(MethodCallHandlerImpl.ERROR_NO_CAMERA);
            }

            // The barcode capturing process is configured through barcode capture settings
            // which are then applied to the barcode capture instance that manages barcode recognition.
            BarcodeCaptureSettings barcodeCaptureSettings = new BarcodeCaptureSettings();
            barcodeCaptureSettings.enableSymbologies(_symbologies);

            _barcodeCapture = BarcodeCapture.forDataCaptureContext(_dataCaptureContext, barcodeCaptureSettings);

            // Register self as a listener to get informed whenever a new barcode got recognized.
            _barcodeCapture.addListener(this);

            // To visualize the on-going barcode capturing process on screen, setup a data capture view
            // that renders the camera preview. The view must be connected to the data capture context.
            _dataCaptureView = DataCaptureView.newInstance(_context, _dataCaptureContext);

            startCameraAndCapturing();
        } catch (Exception e) {
            handleError(e);
        }
    }

    private void handleError(Exception exception) {
        _methodChannel.invokeMethod("ERROR", exception.getMessage());
    }

    private void handleError(String code) {
        _methodChannel.invokeMethod("ERROR_CODE", code);
    }

    private void stopCameraAndCapturing() {
        // Switch camera off to stop streaming frames.
        // The camera is stopped asynchronously and will take some time to completely turn off.
        // Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        _barcodeCapture.setEnabled(false);
        _camera.switchToDesiredState(FrameSourceState.OFF, null);
    }

    private void startCameraAndCapturing() {
        // Switch camera on to start streaming frames.
        // The camera is started asynchronously and will take some time to completely turn on.
        _barcodeCapture.setEnabled(true);
        _camera.switchToDesiredState(FrameSourceState.ON, null);
    }

    private void stopBarcodeCapturing() {
        // Note that disabling the capture mode
        // does not stop the camera, the camera continues to stream frames until it is turned off.
        _barcodeCapture.setEnabled(false);
    }

    private void startBarcodeCapturing() {
        _barcodeCapture.setEnabled(true);
    }

    @Override
    public void onBarcodeScanned(
            @NotNull BarcodeCapture barcodeCapture,
            @NotNull BarcodeCaptureSession barcodeCaptureSession,
            @NotNull FrameData frameData) {
        if (barcodeCaptureSession.getNewlyRecognizedBarcodes().isEmpty()) return;

        Barcode barcode = barcodeCaptureSession.getNewlyRecognizedBarcodes().get(0);

        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any
        // new results until the capture mode is enabled again.
        stopBarcodeCapturing();

        final Map<String, String> result = new HashMap<>();
        result.put("data", barcode.getData());
        result.put("symbology", barcode.getSymbology().name());

        _dataCaptureView.post(new Runnable() {
            @Override
            public void run() {
                _methodChannel.invokeMethod("SCANDIT_RESULT", result);
            }
        });
    }

    @Override
    public void onObservationStarted(@NotNull BarcodeCapture barcodeCapture) {
    }

    @Override
    public void onObservationStopped(@NotNull BarcodeCapture barcodeCapture) {
    }

    @Override
    public void onSessionUpdated(
            @NotNull BarcodeCapture barcodeCapture,
            @NotNull BarcodeCaptureSession barcodeCaptureSession,
            @NotNull FrameData frameData) {
    }
}