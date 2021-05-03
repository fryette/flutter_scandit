<p align="center">
    <img src="https://github.com/fryette/flutter_scandit/blob/master/assets/scandit_logo.png" width="50%" alt="logo" />
  <h2 align="center">
    Barcode Scanning on Smart Devices
  </h2>
  <p align="center">
  <a align="center" href="https://pub.dev/packages/flutter_scandit_plugin">
    <img alt="Pub Package" src="https://img.shields.io/pub/v/scandit.svg">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
  </p>
</p>

## Overview

Scandit mobile computer vision software brings unrivaled scanning performance to any app on any smart device, turning it into a powerful data-capture tool.

## Setup project

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

### Flutter

First, we need to do add `flutter_scandit_plugin` to the dependencies of the `pubspec.yaml`

```yaml
dependencies:
  flutter_scandit_plugin: any
```

Next, we need to install it:

```sh
# Dart
pub get

# Flutter
flutter packages get
```

## Usage

Add `Scandit` widget to the tree

```dart
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';

ScanditController? _controller;

Scandit(
  scanned: (result) {
    // handle scanned result here
  },
  onError: (e) {
    // handle errors here
  },
  onScanditCreated: (controller) => _controller = controller,
  licenseKey: '', // 'INSERT YOUR TEST KEY'
)

```

After a successful scan you need to manually resume scanning if needed:

```dart
_controller?.resumeBarcodeScanning()
```

## Full Example
Please check example folder and do not forget to add `Scandit Key` to main.dart
