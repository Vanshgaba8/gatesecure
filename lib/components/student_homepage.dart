import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/components/barcode_area.dart';
import 'package:flutter_ui/components/profile_page.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//import 'package:flutter_ui/components/idpage.dart';
import 'package:flutter_ui/components/trialpage.dart';
import 'package:flutter_ui/components/history_student.dart';

class studentpage extends StatefulWidget {
  studentpage({super.key});

  @override
  State<studentpage> createState() => _studentpageState();
}

class _studentpageState extends State<studentpage> {
  final user = FirebaseAuth.instance.currentUser!;

  void bahar() {
    FirebaseAuth.instance.signOut();
  }

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
                  builder: (context) => ProfilePage(email: user.email!),
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
          crossAxisCount: 1,
          crossAxisSpacing: 11,
          mainAxisSpacing: 11,
          childAspectRatio: w / (h / 3),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IdPage()),
                );
              },
              child: Container(
                height: h / 2,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo/idcard.png',
                      height: h / 4,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      'ID Card',
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
                  MaterialPageRoute(builder: (context) => HistoryStudentPage()),
                );
              },
              child: Container(
                height: h / 2,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo/history.jpg',
                      height: h / 3.8,
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
