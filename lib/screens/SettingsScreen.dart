// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstproject/screens/EditProfilScreen.dart';
import 'package:firstproject/screens/MyHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'العربية';
  String _currentUserFullName = '';

  Future<void> _getCurrentUserFullName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _currentUserFullName = userData['fullName'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserFullName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.account_circle, size: 50),
            SizedBox(width: 10),
            Text(
              FirebaseAuth.instance.currentUser?.displayName ?? 'الوالد',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('تعديل الملف الشخصي'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilScreen()),
              );
            },
          ),
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            title: Text('تفعيل الإشعارات '),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('اللغة'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: <String>['العربية', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('تسجيل الخروج'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _updateUserFullName(String fullName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance
        .collection('parents')
        .doc(user.uid)
        .set({'fullName': fullName}, SetOptions(merge: true));
  }
}
