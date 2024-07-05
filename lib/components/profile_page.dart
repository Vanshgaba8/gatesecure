import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _hostelNameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _roomNoController = TextEditingController();
  final _statusController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('Email', isEqualTo: widget.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found for the user.'));
          } else {
            var doc = snapshot.data!.docs.first;
            _nameController.text = doc['Full Name'];
            _bloodGroupController.text = doc['Blood Group'];
            _contactNoController.text = doc['Contact No'];
            _hostelNameController.text = doc['Hostel Name'];
            _rollNoController.text = doc['Roll No'];
            _roomNoController.text = doc['Room No'];
            _statusController.text = doc['status'];
            _emailController.text = doc['Email'];

            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField('Full Name', _nameController, false),
                      _buildTextField(
                          'Blood Group', _bloodGroupController, false),
                      _buildTextField('Contact No', _contactNoController),
                      _buildTextField('Hostel Name', _hostelNameController),
                      _buildTextField('Room No', _roomNoController),
                      _buildTextField('Roll No', _rollNoController, false),
                      _buildTextField('Status', _statusController, false),
                      _buildTextField('Email', _emailController, false),
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await doc.reference.update({
                                        'Full Name': _nameController.text,
                                        'Blood Group':
                                            _bloodGroupController.text,
                                        'Contact No': _contactNoController.text,
                                        'Hostel Name':
                                            _hostelNameController.text,
                                        'Roll No': _rollNoController.text,
                                        'Room No': _roomNoController.text,
                                      });
                                      setState(() {
                                        _isLoading = false;
                                        _isEditing = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                          child: Text('Save'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          child: Text('Edit Profile'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      [bool enabled = true]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
      enabled: _isEditing && enabled,
    );
  }
}
