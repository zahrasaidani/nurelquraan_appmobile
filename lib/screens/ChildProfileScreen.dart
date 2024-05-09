import 'package:flutter/material.dart';

class ChildProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي للطفل'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 60), // Icône d'homme
            ),
            SizedBox(height: 20),
            Text(
              'الملف الشخصي للطفل',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'الملف الشخصي للطفل',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
