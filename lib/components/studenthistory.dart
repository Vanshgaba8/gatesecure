import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final _limit = 10;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchRollNo = '';
  bool _noResults = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchDocuments();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _fetchDocuments() async {
    if (!_hasMore) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Query ref = FirebaseFirestore.instance
        .collection('history')
        .orderBy('out time', descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      ref = ref.startAfterDocument(_lastDocument!);
    }

    final docs = (await ref.get()).docs;

    setState(() {
      _documents.addAll(docs);
      _lastDocument = docs.isNotEmpty ? docs.last : null;
      _isLoading = false;
      if (docs.length < _limit) _hasMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredDocuments = _documents
        .where((doc) =>
            _searchRollNo.isEmpty || doc['roll no'].contains(_searchRollNo))
        .toList();
    _noResults = filteredDocuments.isEmpty && _searchRollNo.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 11),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchRollNo = value;
                  _noResults = false;
                });
              },
              decoration: InputDecoration(
                labelText: "Search by Roll No",
              ),
            ),
          ),
          Expanded(
            child: _documents.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/logo/study.png',
                          fit: BoxFit.cover,
                        ),
                        Text(
                          'No history entries found!',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.black),
                    itemCount: filteredDocuments.length +
                        (_isLoading ? 1 : 0) +
                        (_hasMore ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index == filteredDocuments.length && _isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (index ==
                          filteredDocuments.length + (_isLoading ? 1 : 0)) {
                        return _noResults
                            ? Center(
                                child: Text(
                                    'No results found for the given roll number.'))
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'End of List',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              );
                      }

                      var doc = filteredDocuments[index];
                      return ListTile(
                        title: Text('Name: ${doc['name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Roll No: ${doc['roll no']}'),
                            Text('Room No: ${doc['room no']}'),
                            Text('Contact No: ${doc['contact details']}'),
                            Text('Purpose: ${doc['purpose']}'),
                            Text('Out By: ${doc['out by']}'),
                            if (doc['in by'] != null && doc['in by'] != '')
                              Text('In By: ${doc['in by']}'),
                            Text('Out Time: ${doc['out time'].toDate()}'),
                            if (doc['in time'] != null && doc['in time'] != '')
                              Text('In Time: ${doc['in time'].toDate()}'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
