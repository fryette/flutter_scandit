package com.ysampir.flutter_scandit_plugin;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ScanditViewFactory extends PlatformViewFactory {
    private final BinaryMessenger _messenger;

    public ScanditViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        _messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new ScanditView(context, _messenger, id, args);
    }
}

