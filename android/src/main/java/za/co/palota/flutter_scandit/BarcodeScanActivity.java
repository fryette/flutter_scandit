package za.co.palota.flutter_scandit;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import com.scandit.datacapture.barcode.capture.*;
import com.scandit.datacapture.barcode.data.Barcode;
import com.scandit.datacapture.barcode.data.Symbology;
import com.scandit.datacapture.barcode.ui.overlay.BarcodeCaptureOverlay;
import com.scandit.datacapture.core.capture.DataCaptureContext;
import com.scandit.datacapture.core.data.FrameData;
import com.scandit.datacapture.core.source.Camera;
import com.scandit.datacapture.core.source.FrameSourceState;
import com.scandit.datacapture.core.ui.DataCaptureView;
import com.scandit.datacapture.core.ui.viewfinder.RectangularViewfinder;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

public class BarcodeScanActivity
        extends CameraPermissionActivity implements BarcodeCaptureListener {
    public static final String BARCODE_ERROR = "error";
    public static final String BARCODE_DATA = "data";
    public static final String BARCODE_SYMBOLOGY = "symbology";

    private DataCaptureContext dataCaptureContext;
    private BarcodeCapture barcodeCapture;
    private Camera camera;
    private DataCaptureView dataCaptureView;

    private AlertDialog dialog;

    private String licenseKey;
    private HashSet<Symbology> symbologies;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        this.licenseKey = intent.getStringExtra(FlutterScanditPlugin.LICENSE_KEY);
        ArrayList<String> passedSymbologies = intent.getStringArrayListExtra(FlutterScanditPlugin.SYMBOLOGIES_KEY);
        symbologies = new HashSet<>();

        if(passedSymbologies != null) {
            for (String symbologyName : passedSymbologies) {
                Symbology symbology = FlutterScanditPlugin.convertToSymbology(symbologyName);
                if (symbology != null) {
                    symbologies.add(symbology);
                }
            }
        }
        if(symbologies.isEmpty()){
            symbologies.add(Symbology.EAN13_UPCA); // default
        }

        // Initialize and start the barcode recognition.
        initializeAndStartBarcodeScanning();
    }

    private void finishWithError(String errorReason) {
        Intent data = new  Intent();
        data.putExtra(BARCODE_ERROR, errorReason);
        setResult(Activity.RESULT_CANCELED, data);
        finish();
    }

    private void initializeAndStartBarcodeScanning() {
        // Create data capture context using your license key.
        dataCaptureContext = DataCaptureContext.forLicenseKey(this.licenseKey != null ? this.licenseKey : "");

        // Use the default camera and set it as the frame source of the context.
        // The camera is off by default and must be turned on to start streaming frames to the data
        // capture context for recognition.
        // See resumeFrameSource and pauseFrameSource below.
        camera = Camera.getDefaultCamera();
        if (camera != null) {
            // Use the recommended camera settings for the BarcodeCapture mode.
            camera.applySettings(BarcodeCapture.createRecommendedCameraSettings());
            dataCaptureContext.setFrameSource(camera);
        } else {
            finishWithError("NO_CAMERA");
        }

        // The barcode capturing process is configured through barcode capture settings
        // which are then applied to the barcode capture instance that manages barcode recognition.
        BarcodeCaptureSettings barcodeCaptureSettings = new BarcodeCaptureSettings();

        // The settings instance initially has all types of barcodes (symbologies) disabled.
        // For the purpose of this sample we enable a very generous set of symbologies.
        // In your own app ensure that you only enable the symbologies that your app requires as
        // every additional enabled symbology has an impact on processing times.

        barcodeCaptureSettings.enableSymbologies(this.symbologies);

        // Some linear/1d barcode symbologies allow you to encode variable-length data.
        // By default, the Scandit Data Capture SDK only scans barcodes in a certain length range.
        // If your application requires scanning of one of these symbologies, and the length is
        // falling outside the default range, you may need to adjust the "active symbol counts"
        // for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        SymbologySettings symbologySettings =
                barcodeCaptureSettings.getSymbologySettings(Symbology.CODE39);

        HashSet<Short> activeSymbolCounts = new HashSet<>(
                Arrays.asList(new Short[] { 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }));

        symbologySettings.setActiveSymbolCounts(activeSymbolCounts);

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture.forDataCaptureContext(dataCaptureContext, barcodeCaptureSettings);

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(this);

        // To visualize the on-going barcode capturing process on screen, setup a data capture view
        // that renders the camera preview. The view must be connected to the data capture context.
        dataCaptureView = DataCaptureView.newInstance(this, dataCaptureContext);

        // Add a barcode capture overlay to the data capture view to render the location of captured
        // barcodes on top of the video preview.
        // This is optional, but recommended for better visual feedback.
        BarcodeCaptureOverlay overlay = BarcodeCaptureOverlay.newInstance(barcodeCapture, dataCaptureView);
        overlay.setViewfinder(new RectangularViewfinder());

        setContentView(dataCaptureView);
    }

    @Override
    protected void onPause() {
        pauseFrameSource();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        barcodeCapture.removeListener(this);
        dataCaptureContext.removeMode(barcodeCapture);
        super.onDestroy();
    }

    private void pauseFrameSource() {
        // Switch camera off to stop streaming frames.
        // The camera is stopped asynchronously and will take some time to completely turn off.
        // Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        barcodeCapture.setEnabled(false);
        camera.switchToDesiredState(FrameSourceState.OFF, null);
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Check for camera permission and request it, if it hasn't yet been granted.
        // Once we have the permission the onCameraPermissionGranted() method will be called.
        requestCameraPermission();
    }

    @Override
    public void onCameraPermissionGranted() {
        resumeFrameSource();
    }

    @Override
    public void onCameraPermissionDenied() {
        finishWithError("CAMERA_PERMISSION_DENIED");
    }

    private void resumeFrameSource() {
        dismissScannedCodesDialog();

        // Switch camera on to start streaming frames.
        // The camera is started asynchronously and will take some time to completely turn on.
        barcodeCapture.setEnabled(true);
        camera.switchToDesiredState(FrameSourceState.ON, null);
    }

    private void dismissScannedCodesDialog() {
        if (dialog != null) {
            dialog.dismiss();
            dialog = null;
        }
    }


    @Override
    public void onBarcodeScanned(
            @NonNull BarcodeCapture barcodeCapture,
            @NonNull BarcodeCaptureSession session,
            @NonNull FrameData frameData
    ) {
        if (session.getNewlyRecognizedBarcodes().isEmpty()) return;

        Barcode barcode = session.getNewlyRecognizedBarcodes().get(0);


        Intent data = new Intent();
        data.putExtra(BARCODE_DATA, barcode.getData());
        data.putExtra(BARCODE_SYMBOLOGY, barcode.getSymbology().name());
        setResult(Activity.RESULT_OK, data);
        finish();
    }


    @Override
    public void onSessionUpdated(@NonNull BarcodeCapture barcodeCapture,
                                 @NonNull BarcodeCaptureSession session, @NonNull FrameData data) {}

    @Override
    public void onObservationStarted(@NonNull BarcodeCapture barcodeCapture) {}

    @Override
    public void onObservationStopped(@NonNull BarcodeCapture barcodeCapture) {}
}