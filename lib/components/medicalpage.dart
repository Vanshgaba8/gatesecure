import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalPage extends StatefulWidget {
  @override
  _MedicalPageState createState() => _MedicalPageState();
}

class _MedicalPageState extends State<MedicalPage> {
  List<DocumentSnapshot> _students = [];
  bool _reachedEnd = false;
  bool _onlyInStatus = false;
  String _searchBloodGroup = '';
  ScrollController _scrollController = ScrollController();

  // Variable to control the number of documents fetched at a time
  int _fetchLimit = 10;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getMedicalRecords();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMedicalRecords();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getMedicalRecords() async {
    if (!_reachedEnd && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      Query medicalRecordsQuery =
          FirebaseFirestore.instance.collection('students').limit(_fetchLimit);

      if (_onlyInStatus) {
        medicalRecordsQuery =
            medicalRecordsQuery.where('status', isEqualTo: 'in');
      }

      // Add the search query
      if (_searchBloodGroup.isNotEmpty) {
        medicalRecordsQuery = medicalRecordsQuery.where('Blood Group',
            isEqualTo: _searchBloodGroup);
      }

      medicalRecordsQuery = medicalRecordsQuery.orderBy('Full Name');

      if (_students.length > 0) {
        medicalRecordsQuery =
            medicalRecordsQuery.startAfterDocument(_students.last);
      }

      QuerySnapshot querySnapshot = await medicalRecordsQuery.get();

      if (querySnapshot.docs.length < _fetchLimit) {
        _reachedEnd = true;
      }

      setState(() {
        _students.addAll(querySnapshot.docs);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Page'),
      ),
      body: Column(
        children: [
          CheckboxListTile(
            title: Text("Show only 'in' students"),
            value: _onlyInStatus,
            onChanged: (newValue) {
              setState(() {
                _onlyInStatus = newValue!;
                _students = [];
                _reachedEnd = false;
                _getMedicalRecords();
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 11),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchBloodGroup = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: "Search by Blood Group",
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_students.isEmpty
                    ? Center(
                        child: Text(_onlyInStatus
                            ? "No 'in' students found"
                            : "No students found"),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _students.length + (_reachedEnd ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _students.length) {
                            // Display indication at the end of the list
                            return _reachedEnd
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "End of List",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  );
                          }

                          var doc = _students[index];
                          if (_searchBloodGroup.isEmpty ||
                              doc['Blood Group']
                                  .toLowerCase()
                                  .contains(_searchBloodGroup)) {
                            return Card(
                              child: ListTile(
                                title: Text('Full Name: ${doc['Full Name']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Roll No: ${doc['Roll No']}'),
                                    Text('Blood Group: ${doc['Blood Group']}'),
                                    Text('Contact No.: ${doc['Contact No']}'),
                                    Text('Hostel Name: ${doc['Hostel Name']}'),
                                    Text('Room No.: ${doc['Room No']}'),
                                    Text('Status: ${doc['status']}'),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
