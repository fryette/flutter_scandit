package za.co.palota.flutter_scandit;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterScanditPlugin
 */

public class FlutterScanditPlugin implements FlutterPlugin, ActivityAware {
    private static final String TAG = FlutterScanditPlugin.class.getSimpleName();

    private @Nullable
    FlutterPluginBinding flutterPluginBinding;
    private @Nullable
    MethodCallHandlerImpl methodCallHandler;

    public FlutterScanditPlugin() {
    }

    /**
     * Plugin registration V1.
     */
    public static void registerWith(Registrar registrar) {
        FlutterScanditPlugin plugin = new FlutterScanditPlugin();
        plugin.startListening(registrar.activity(),registrar.messenger());
        registrar.addActivityResultListener(plugin.methodCallHandler); // should be set after start listening call
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = binding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        startListening(binding.getActivity(), flutterPluginBinding.getBinaryMessenger());
        binding.addActivityResultListener(methodCallHandler);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        if (methodCallHandler == null) {
            // Could be on too low of an SDK to have started listening originally.
            return;
        }

        methodCallHandler.stopListening();
        methodCallHandler = null;
    }

    private void startListening(Activity activity, BinaryMessenger messenger) {
        methodCallHandler = new MethodCallHandlerImpl(activity, messenger);
    }

}
