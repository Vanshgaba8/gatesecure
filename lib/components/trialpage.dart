import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class IdPage extends StatefulWidget {
  @override
  _IdPageState createState() => _IdPageState();
}

class _IdPageState extends State<IdPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? user;
  String? profileUrl;
  String? rollNo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadRollNo();
  }

  Future<void> _loadRollNo() async {
    _db
        .collection('students')
        .where('Email', isEqualTo: user!.email)
        .snapshots()
        .listen((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          rollNo = doc.get('Roll No');
          _loadProfileImage();
        });
      }
    });
  }

  Future<void> _loadProfileImage() async {
    final ref = _storage.ref().child('idcards').child('$rollNo.jpg');
    try {
      final url = await ref.getDownloadURL();
      setState(() {
        profileUrl = url;
      });
    } catch (e) {
      print('Failed to load profile image: $e');
    }
  }

  Future<void> _updateProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });
      final ref = _storage.ref().child('idcards').child('$rollNo.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();
      await user!.updatePhotoURL(url);
      setState(() {
        profileUrl = url;
        isLoading = false;
      });
    }
  }

  Future<void> _deleteProfileImage() async {
    setState(() {
      isLoading = true;
    });
    final ref = _storage.ref().child('idcards').child('$rollNo.jpg');
    await ref.delete();
    await user!.updatePhotoURL(null);
    setState(() {
      profileUrl = null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (profileUrl != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Container(
                          child: PhotoView(
                            imageProvider: NetworkImage(profileUrl!),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('No ID Card'),
                        content: Text('No ID Card is Uploaded'),
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
              },
              child: CircleAvatar(
                radius: 80,
                backgroundImage:
                    profileUrl != null ? NetworkImage(profileUrl!) : null,
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfileImage,
                    child: Text('Choose ID Card'),
                  ),
            ElevatedButton(
              onPressed: _deleteProfileImage,
              child: Text('Delete ID Card'),
            ),
          ],
        ),
      ),
    );
  }
}
