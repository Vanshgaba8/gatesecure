import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IDCardPage extends StatefulWidget {
  @override
  _IDCardPageState createState() => _IDCardPageState();
}

class _IDCardPageState extends State<IDCardPage> {
  File? _image;
  String? _uploadedFileURL;
  String? _rollNo;

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('idcards/${_rollNo}}');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() => null);
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  Future fetchRollNo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('Email', isEqualTo: user.email)
          .get();
      _rollNo = querySnapshot.docs.first['Roll No'];
    }
  }

  Future fetchUploadedFile() async {
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('idcards/${_rollNo}}');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRollNo().then((_) => fetchUploadedFile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            _uploadedFileURL != null
                ? CachedNetworkImage(
                    imageUrl: _uploadedFileURL!,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                : Container(),
            ElevatedButton(
              child: Text('Choose Image'),
              onPressed: getImage,
            ),
            ElevatedButton(
              child: Text('Upload Image'),
              onPressed: uploadFile,
            ),
          ],
        ),
      ),
    );
  }
}
