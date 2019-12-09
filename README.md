# Flutter Scandit

[![pub package](https://img.shields.io/pub/v/flutter_scandit.svg)](https://pub.dev/packages/flutter_scandit) 

Flutter Plugin for [Scandit](https://www.scandit.com/) Barcode Scanning

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

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
], licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE -") // use your scandit key here
    .scanBarcode();
String barcodeData = result.data; // actual barcode string
```

You should always pass the intended symbologies along with your call. It is also important to check that the symbologies you are selecting align with your Scandit license restrictions.

Since the actual keys will be different per platoform, it is advised to abtract this out using environment variables or global configuration that can be changed per build/environment.
