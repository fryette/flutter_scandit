import 'package:flutter/material.dart';
import 'package:flutter_scandit/flutter_scandit.dart';
import 'package:flutter_scandit/scandit.dart';
import 'package:permission_handler/permission_handler.dart';

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
  }
}

class MagicScreen extends StatefulWidget {
  @override
  _MagicScreenState createState() => _MagicScreenState();
}

class _MagicScreenState extends State<MagicScreen> {
  String _message = '';
  PermissionStatus _cameraPermissionsStatus = PermissionStatus.undetermined;

  Future _requestCameraPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (_cameraPermissionsStatus != status) {
      setState(() {
        _cameraPermissionsStatus = status;
      });
    }

    if (_cameraPermissionsStatus != PermissionStatus.granted)
      _message = "Permissions problem";
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _requestCameraPermissions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Magic App"),
      ),
      body: Stack(
        children: [
          if (_cameraPermissionsStatus == PermissionStatus.granted)
            _buildScanditView(),
          Center(
            child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.teal),
                )),
          ),
          Center(child: Text(_message)),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }

  Widget _buildScanditView() {
    return Scandit(
      scanned: (result) {
        setState(() {
          print(result.data);
          _message = result.data;
        });
      },
      onError: (e) {
        setState(() {
          print(e.message);
          _message = e.message;
        });
      },
      licenseKey:
          "AYBu8TlYJtB6DFps/Dgz/cIdIvvrMIv3k3Eal8Q1qNH+dNvyfVjOOT9/nzbTeJxiIET6TjBi68GET/9HVkHlVf9FAmdYdMHic38yMnVECnM/aqFtjyaLPaoN+oWqBco/zCTtT4URRQJFlZXwNIU3szPt8+mS+20bgJtQKvd9O5wHuRFgsB8IBxcTdURFz1hQPkF89jkl+A/g1/3GZHeuunISOetQspJ6ER+wVOdA54kMJ42Us6l9m10qsuTG7NfwsL+4ZX7HuSMJUmfIJx/YQSwan7es9biqrGb+K9cIZPPyqM6LWsqDls6SnKi8g5sijcQE+l7B3Gnu5hBv8QjcFtI7s3YA45iAPB47mt9ao+Nq9+AkX7n8nB41ykhyDVoHI8BaouyxihgxGFe7YUy5tBTo6XnnJxXfwgtW3O798UIM8yFF4QxVnL9rIleqT49XOWKNDr8uK7e03syPglLNHefdcY2mb5oOROkayREXut+psjkVhY3au6TUDhy9gqKvoWGp2dkJZcwL+yPdjtgPEDrHCT23L5Rvfj0p4ja85oTSuekHL/zeKxguWNs1lSP1ir4e9SFX5mhF+8NV7xyrDyAnqkwo07AReu8SiTTERURb1rQhdltVY1+ZcjIKhXRtYsD1BEhwWmQxSjVlZUNXgGc70wOY6yXZgcFXb3KEIFDnnVVnfGdDribMR4R4in2YHnNXkn8dT0vLVhzskEcuAXSocYQON4/Kf0FQWbOsxysdx0QPDmUVK8s5/Ld6aF34/q0GVN3mhVWxd9CqU+g62Km6987xej3k6RFIqmCHvGwniEPA94oy",
    );
  }
}
