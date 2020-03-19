# Flutter Scandit

[![pub package](https://img.shields.io/pub/v/flutter_scandit.svg)](https://pub.dev/packages/flutter_scandit) 

Flutter Plugin for [Scandit](https://www.scandit.com/) Barcode Scanning


## Getting Started

Check out the [example](https://github.com/PalotaCompany/flutter_scandit/tree/master/example) directory for a sample app using Firebase Cloud Messaging.

## Features:

* Scan a barcode on demand


## Platforms:
- Android
- iOS

## Installation

First, add `flutter_scandit` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### iOS

Add the following to the `ios/Runner/Info.plist`:

* The key `Privacy - Camera Usage Description` and a usage description.

Or in text format add the key:

```xml
<key>NSCameraUsageDescription</key>
<string>Can I use the camera for scanning?</string>
```
Min target is iOS 9.0


### Android

Min SDK version should be 19 or later

```
minSdkVersion 19
```

### Example

An exmaple with specific symbologies
```dart
BarcodeResult result = await FlutterScandit(symbologies: [
  Symbology.EAN13_UPCA,
  Symbology.CODE128,
  // - any other valid sumbologies
], licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --") // use your scandit key here
    .scanBarcode();
String barcodeData = result.data; // actual barcode string
Symbology scannedSymbology = result.symbology; // the symbology which was scanned
```

Make sure to wrap the invocation of the method in a try catch block to handle any `BarcodeScanException` exceptions that may occur.

You should always pass the intended symbologies along with your call. It is also important to check that the symbologies you are selecting align with your Scandit license restrictions.

Since the actual licence keys may be different per platoform, it is advised to abtract this out using environment variables or global configuration that can be changed per build/environment.
