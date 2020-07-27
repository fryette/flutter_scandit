import 'package:flutter/material.dart';
import 'package:flutter_scandit/flutter_scandit.dart';
import 'package:flutter_scandit/scandit.dart';

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
    return MagicScreen();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Flutter Scandit example app'),
    //   ),
    //   body: Center(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         RaisedButton(
    //           onPressed: () async {
    //             try {
    //               BarcodeResult result = await FlutterScandit(symbologies: [
    //                 Symbology.EAN13_UPCA,
    //                 Symbology.CODE128
    //               ], licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
    //                   .scanBarcode();
    //               setState(() {
    //                 barcode = result;
    //               });
    //             } on BarcodeScanException catch (e) {
    //               _showError(context, e.toString());
    //             }
    //           },
    //           child: Text('SCAN'),
    //         ),
    //         SizedBox(
    //           height: 32,
    //         ),
    //         barcode != null
    //             ? Text('${barcode.data} ${barcode.symbology}')
    //             : Text('please scan a barcode...'),
    //       ],
    //     ),
    //   ),
    // );
  }
}

class MagicScreen extends StatefulWidget {
  @override
  _MagicScreenState createState() => _MagicScreenState();
}

class _MagicScreenState extends State<MagicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Magic App"),
      ),
      body: Stack(
        children: [
          Container(
            child: Scandit(
              scanned: (result) {
                setState(() {
                  print(result.data);
                });
              },
              licenseKey:
                  "AV7ODgNVHAIAO8A7TAFjY2kQyTwrDPsAxSlvdyFpis0kMaiCsHXxyjxEDzvPKnez3mJi7RNGsy3BUaCaC2NzxLxDXVkmOW8kWHu5LNdQuIuSaqy0g1nReIVLZEvrcHV7xmvhTgMHqoETEDMRnSONdLkEyU7T1GpNmumRuO6Dk71/eEPt6FHb09ynPETZ+EO/Wh/01q3KCAsX5KawrtnknGlaveCz2HAXrFXWSystNBJO7rSnZTJdyIFF9ITFTUsLhuXeyWN2sZwOvaVm1L38lpDQMZLUnPGq6KG8fazsN0uCAOxQMr4ETk3dfw9aN9GqE2BKaeoLl6ZXdSDTwjUhygfISaUVt09l4Ko6OU4YcdUkp2AZPAgv98OUOCxcEadq4cn7tqg2p4Fum2x043EzX02zfTZgC4/UryEGcxXgBboyZMyViDbojXHkoPxN+Ba9kwWGWHJtoYu9GfebhyVjft0fiEguPolxp9SoRTjnq4UpnE//O9HYAuEBD8/6Nr+d10Jf+hn+MzE0mRLPsGFOmBPDmPMJi6+BYob808yhvJ9qTS2IyACE/wtKB2SZdawTC7wh2sbA/H9IWEDrbpxP7HaT2G79GZvx2VkxoNQtSWgR8TqHPtlo4Wjv0xOBPf92RceYz1GX+MtyIcglnh5d83vq04afYxpvZqhHZJiIJCUKkyzLXUPZMB0bBEIzQkntjdE/55u+kFY4aYeO/T0KwRSlafTeGbISUPrP2ozwZRa2CD41Btk2aCWlH+hSTGojbOEXzYNjPrBQQqMKt/0mJ+WA/s3wRNNHE67+HG/4OmEUr9sX6n9de35wO9QZ22JMpJpDow==",
            ),
          ),
          Center(
            child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.teal),
                )),
          )
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }
}
