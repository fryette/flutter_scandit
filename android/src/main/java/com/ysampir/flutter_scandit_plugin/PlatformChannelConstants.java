package com.ysampir.flutter_scandit_plugin;

public final class PlatformChannelConstants {
    public static final String CHANNEL_NAME = "ScanditView";

    public static final String PARAM_SYMBOLOGIES = "symbologies";
    public static final String PARAM_LICENSE_KEY = "licenseKey";

    public static final String ERROR_NO_LICENSE = "MISSING_LICENCE";
    public static final String ERROR_PERMISSION_DENIED = "CAMERA_PERMISSION_DENIED";
    public static final String ERROR_CAMERA_INITIALIZATION = "CAMERA_INITIALIZATION_ERROR";
    public static final String ERROR_NO_CAMERA = "NO_CAMERA";

    public static final String METHOD_STOP_CAMERA_AND_CAPTURING = "STOP_CAMERA_AND_CAPTURING";
    public static final String METHOD_START_CAMERA_AND_CAPTURING = "START_CAMERA_AND_CAPTURING";
    public static final String METHOD_START_CAPTURING = "START_CAPTURING";

    public static final String METHOD_SCAN_RESULT = "SCANDIT_RESULT";
    public static final String METHOD_ERROR_CODE = "ERROR_CODE";
    public static final String METHOD_UNFORESEEN_ERROR = "UNFORESEEN_ERROR";

    public static final String PARAM_DATA = "data";
    public static final String PARAM_SYMBOLOGY = "symbology";

}
