package za.co.palota.flutter_scandit;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;

public class FlutterScanditPlugin implements FlutterPlugin {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        BinaryMessenger messenger = binding.getBinaryMessenger();
        binding
            .getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory("ScanditPlatformView", new ScanditViewFactory(messenger));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
