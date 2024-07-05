import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/components/barcode_area.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_ui/components/outstu.dart';
import 'package:flutter_ui/components/checkinout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ui/components/profile_page.dart';
import 'package:flutter_ui/components/guardprofile.dart';
import 'package:flutter_ui/components/studenthistory.dart';
import 'package:flutter_ui/components/medicalpage.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController manualInputController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void bahar() {
    FirebaseAuth.instance.signOut();
  }

  // void showbarcode(String s) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.deepPurple,
  //         title: Center(
  //           child: Text(
  //             s,
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    h = h <= 400 ? 600 : h;
    return Scaffold(
      appBar: AppBar(
        title: Text('GateSecure'),
        leading: GestureDetector(
          onTap: () {
            if (user.email != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuardProfile(email: user.email!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: Email is null')),
              );
            }
          },
          child: CircleAvatar(
            radius: 20, // Adjust the size of the CircleAvatar here
            backgroundImage: AssetImage('assets/images/logo/profile2.jpg'),
          ),
        ),
        actions: [IconButton(onPressed: bahar, icon: Icon(Icons.logout))],
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 11,
          right: 11,
          top: 11,
        ),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 11,
          mainAxisSpacing: 11,
          childAspectRatio: w / (h / 1.2),
          children: [
            GestureDetector(
              onTap: () async {
                String barcoderes = 'Unknown';
                try {
                  barcoderes = await FlutterBarcodeScanner.scanBarcode(
                    "#ff6666",
                    "Cancel",
                    true,
                    ScanMode.BARCODE,
                  );
                } on PlatformException {
                  barcoderes = 'Failed to get platform version';
                }
                if (!mounted) return;

                if (barcoderes == '-1') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Enter Barcode Manually'),
                        content: TextField(
                          controller: manualInputController,
                          decoration:
                              InputDecoration(hintText: "Enter Barcode"),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Submit'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              barcoderes = manualInputController.text;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GuardScreen(rollNumber: barcoderes),
                                ),
                              );
                              manualInputController.clear();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }

                if (barcoderes != '-1') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuardScreen(rollNumber: barcoderes),
                    ),
                  );
                }
              },
              child: Container(
                height: h / 1.5,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo/barcode.jpg',
                      height: h / 3,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      'Scan',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OutStudents()),
                );
              },
              child: Container(
                height: h / 1.5,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo/out.jpg',
                      height: h / 3,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      'Out Students',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicalPage()),
                );
              },
              child: Container(
                height: h / 1.5,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo/medical.jpg',
                      height: h / 3,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      'Medical Data',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
              child: Container(
                height: h / 1.5,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo/history.jpg',
                      height: h / 3,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      'History',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
