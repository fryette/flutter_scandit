import 'package:flutter/material.dart';

import 'package:flutter_scandit/flutter_scandit.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BarcodeResult barcode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                  var result = await FlutterScandit(symbologies: [
                    Symbology.EAN13_UPCA,
                    Symbology.CODE128
                  ], licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE -")
                      .scanBarcode();
                  setState(() {
                    barcode = result;
                  });
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
      ),
    );
  }
}
