import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OutStudents extends StatefulWidget {
  OutStudents({super.key});

  @override
  State<OutStudents> createState() => _OutStudentsState();
}

class _OutStudentsState extends State<OutStudents> {
  bool _isLoading = false;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  final int _fetchLimit = 10;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _students = [];
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchStudents();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    if (!_hasMore) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('students')
        .where('status', isEqualTo: 'out')
        .orderBy('Full Name')
        .limit(_fetchLimit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = querySnapshot.docs.last;
        _students.addAll(querySnapshot.docs);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Out Students'),
      ),
      body: _students.isEmpty && !_isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo/study.png',
                  fit: BoxFit.cover,
                ),
                Text(
                  'Seems like no one is out!',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.black),
              itemCount:
                  _students.length + (_isLoading ? 1 : 0) + (_hasMore ? 0 : 1),
              itemBuilder: (context, index) {
                if (index < _students.length) {
                  var doc = _students[index];
                  return ListTile(
                    title: Text('Full Name: ${doc['Full Name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Roll No: ${doc['Roll No']}'),
                        Text('Blood Group: ${doc['Blood Group']}'),
                        Text('Contact No.: ${doc['Contact No']}'),
                        Text('Hostel Name: ${doc['Hostel Name']}'),
                        Text('Room No.: ${doc['Room No']}'),
                        Text('Purpose: ${doc['purpose']}'),
                        Text('Status: ${doc['status']}'),
                        Text('Out By: ${doc['out by']}'),
                        Text('Out Time: ${doc['out time'].toDate()}'),
                      ],
                    ),
                  );
                } else if (_isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'End of list',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
