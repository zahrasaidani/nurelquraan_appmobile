import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUserInfoPage extends StatefulWidget {
  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const String newNameLabel = 'New Name';
  static const String newDescriptionLabel = 'New Description';
  static const String saveButtonLabel = 'Save';
  static const String nameRequiredError = 'Please enter a new name';
  static const String descriptionRequiredError =
      'Please enter a new description';
  static const String successMessage = 'User info updated successfully';

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> updateUserInfo(String newName, String newDescription) async {
    try {
      User? currentUser = await getCurrentUser();
      if (currentUser != null) {
        String userId = currentUser.uid;
        await FirebaseFirestore.instance
            .collection('mosques')
            .doc(userId)
            .update({'name': newName, 'description': newDescription});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (error) {
      print(':خطا في تعديل المعلومات $error');
      // Handle Firestore update errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل  المعلومات'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: newNameLabel),
                validator: (value) {
                  if (value!.isEmpty) {
                    return nameRequiredError;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: newDescriptionLabel),
                validator: (value) {
                  if (value!.isEmpty) {
                    return descriptionRequiredError;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String newName = _nameController.text.trim();
                    String newDescription = _descriptionController.text.trim();
                    await updateUserInfo(newName, newDescription);
                    Navigator.pop(context); // Go back
                  }
                },
                child: Text(saveButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
