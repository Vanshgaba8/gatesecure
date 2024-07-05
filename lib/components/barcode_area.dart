import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ui/components/checkinout.dart';

class BarcodeArea extends StatefulWidget {
  BarcodeArea({Key? key}) : super(key: key);

  @override
  _BarcodeAreaState createState() => _BarcodeAreaState();
}

class _BarcodeAreaState extends State<BarcodeArea> {
  String barcode = 'unknown';

  Future<void> scanBarcodeNormal() async {
    String barcodeRes;
    try {
      barcodeRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      debugPrint(barcodeRes);
    } on PlatformException {
      barcodeRes = 'Failed to get platform version';
      debugPrint(barcodeRes);
    }
    if (!mounted) return;

    // Check if the roll number exists in the Firestore database
    final result = await FirebaseFirestore.instance
        .collection('students')
        .doc(barcodeRes)
        .get();

    if (result.exists) {
      // Navigate to the GuardScreen with the scanned roll number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuardScreen(rollNumber: barcodeRes),
        ),
      );
    } else {
      // If the roll number does not exist, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('The roll number does not exist in the database.'),
            actions: <Widget>[
              TextButton(
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

    setState(() {
      barcode = barcodeRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Scan result : $barcode\n', style: TextStyle(fontSize: 20)),
        ElevatedButton(
          onPressed: () => scanBarcodeNormal(),
          child: Text('Start barcode scan'),
        ),
      ],
    );
  }
}
