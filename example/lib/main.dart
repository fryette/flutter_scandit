import 'package:flutter/material.dart';
import 'package:flutter_scandit/flutter_scandit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BarcodeScanPage(),
    );
  }
}

class BarcodeScanPage extends StatefulWidget {
  @override
  _BarcodeScanPageState createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  BarcodeResult barcode;

  Future<void> _showError(BuildContext context, String errorMessage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Barcode scan error'),
          content: Text(errorMessage ?? "Unknown error"),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Scandit example app'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                try {
                  BarcodeResult result = await FlutterScandit(symbologies: [
                    Symbology.EAN13_UPCA,
                    Symbology.CODE128
                  ], licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
                      .scanBarcode();
                  setState(() {
                    barcode = result;
                  });
                } on BarcodeScanException catch (e) {
                  _showError(context, e.toString());
                }
              },
              child: Text('SCAN'),
            ),
            SizedBox(
              height: 32,
            ),
            barcode != null
                ? Text('${barcode.data} ${barcode.symbology}')
                : Text('please scan a barcode...'),
          ],
        ),
      ),
    );
  }
}
