import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GuardScreen extends StatefulWidget {
  final String rollNumber;

  GuardScreen({required this.rollNumber});

  @override
  _GuardScreenState createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  String? _status;
  bool _isLoading = false;
  String? _error;

  Future<String> getGuardName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email ?? '';

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('Email', isEqualTo: userEmail)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String guardName = snapshot.docs.first['Full Name'];
          return guardName;
        } else {
          return '';
        }
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> updateStudentHistoryList(
      String studentId, String historyDocId) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .update({
      'history': FieldValue.arrayUnion([historyDocId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If data is still loading or an update is in progress, prevent pop
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Guard Screen'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .where('Roll No', isEqualTo: widget.rollNumber)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No data found for the roll number.'));
            } else {
              var doc = snapshot.data!.docs.first;
              _status = doc['status'];
              if (_purposeController.text.isEmpty) {
                _purposeController.text = doc['purpose'];
              }
              return ListView(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Full Name: ${doc['Full Name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Roll Number: ${doc['Roll No']}'),
                          Text('Blood Group: ${doc['Blood Group']}'),
                          Text('Contact No: ${doc['Contact No']}'),
                          Text('Hostel Name: ${doc['Hostel Name']}'),
                          Text('Room No: ${doc['Room No']}'),
                          Text('Status: $_status'),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              'Una',
                              'Jaijon Morh',
                              'Gym',
                              'HPMC',
                              'Mandir',
                              'Transit',
                              'Medical'
                            ]
                                .map((text) => TextButton(
                                      child: Text(text),
                                      onPressed: _status == 'in'
                                          ? () {
                                              _purposeController.text = text;
                                            }
                                          : null,
                                    ))
                                .toList(),
                          ),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _purposeController,
                              decoration: InputDecoration(
                                labelText: 'Purpose',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: _status == 'in'
                                      ? () {
                                          _purposeController.clear();
                                        }
                                      : null,
                                ),
                              ),
                              validator: (value) {
                                if (_status == 'in' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter a purpose';
                                }
                                return null;
                              },
                              enabled: _status == 'in',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                        _error = null;
                                      });
                                      try {
                                        String guardName = await getGuardName();
                                        _status =
                                            _status == 'in' ? 'out' : 'in';

                                        // Update student status and purpose
                                        await doc.reference.update({
                                          'status': _status,
                                          'purpose': _purposeController.text,
                                        });

                                        if (_status == 'out') {
                                          // Create a new document in 'history' collection
                                          DocumentReference historyDocRef =
                                              await FirebaseFirestore.instance
                                                  .collection('history')
                                                  .add({
                                            'studentId': doc.id,
                                            'roll no': doc['Roll No'],
                                            'room no': doc['Room No'],
                                            'name': doc['Full Name'],
                                            'contact details':
                                                doc['Contact No'],
                                            'out by': guardName,
                                            'purpose': _purposeController.text,
                                            'out time': DateTime.now(),
                                            'in by': '',
                                            'in time': '',
                                            'status': _status,
                                          });

                                          // Update 'doc id' in student document
                                          await doc.reference.update({
                                            'doc id': historyDocRef.id,
                                            'out by': guardName,
                                            'out time': DateTime.now(),
                                          });
                                          await updateStudentHistoryList(
                                              doc.id, historyDocRef.id);
                                        } else {
                                          // Access existing document in 'history' collection
                                          DocumentReference historyDocRef =
                                              FirebaseFirestore.instance
                                                  .collection('history')
                                                  .doc(doc['doc id']);

                                          // Update 'in by' and 'in time' in history document
                                          await historyDocRef.update({
                                            'in by': guardName,
                                            'in time': DateTime.now(),
                                            'status': 'in',
                                          });
                                          _purposeController.clear();
                                        }

                                        if (_error == null) {
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        setState(() {
                                          _error = e.toString();
                                        });
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            child: Text(_status == 'in' ? 'Out' : 'In'),
                          ),
                          if (_isLoading) CircularProgressIndicator(),
                          if (_error != null) Text('Error: $_error'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
