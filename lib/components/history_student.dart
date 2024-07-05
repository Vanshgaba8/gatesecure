// Import the necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryStudentPage extends StatefulWidget {
  @override
  _HistoryStudentPageState createState() => _HistoryStudentPageState();
}

class _HistoryStudentPageState extends State<HistoryStudentPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please sign in first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('History Student Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('students')
            .where('Email', isEqualTo: user!.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
                'Something went wrong. Please check your internet connection.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // Get the history array
          List<dynamic> historyArray = snapshot.data?.docs[0]?.get('history');

          // Check if the history array is null or empty
          if (historyArray == null || historyArray.isEmpty) {
            return Text('No out entries available');
          }

          // Fetch the history documents from last to first with a fetch limit
          return FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('history')
                .where(FieldPath.documentId, whereIn: historyArray)
                .orderBy(FieldPath.documentId, descending: false)
                .limit(10) // Set your fetch limit here
                .get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(
                    'Something went wrong. Please check your internet connection.');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              // Display the fields in a ListView.separated
              return ListView.separated(
                itemCount: (snapshot.data?.docs.length ?? 0) + 1,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.black),
                itemBuilder: (BuildContext context, int index) {
                  if (index == snapshot.data?.docs.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'End of Results',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ); // Display 'End of Results' for the last item
                  }
                  QueryDocumentSnapshot? doc = snapshot.data?.docs[index];

                  if (doc == null) {
                    return Container(); // Return an empty container if doc is null
                  }

                  // Check if 'out time' is empty
                  if (doc.get('out time') == '') {
                    return Text('No results found');
                  }

                  return ListTile(
                    title: Text(
                        'Out Time: ${doc.get('out time').toDate().toString()} \nOut By: ${doc.get('out by')}'),
                    subtitle: doc.get('in time') != null &&
                            doc.get('in time') != '' &&
                            doc.get('in by') != null &&
                            doc.get('in by') != ''
                        ? Text(
                            'In Time: ${doc.get('in time').toDate().toString()} \nIn By: ${doc.get('in by')}')
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
