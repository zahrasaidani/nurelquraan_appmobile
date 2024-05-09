import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstproject/screens/NotificationScreen.dart';
import 'package:firstproject/screens/ChildProfileScreen.dart';
import 'package:firstproject/screens/SettingsScreen.dart';

class PublicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publication'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // Header
              return const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF9B9FD0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.white, size: 32),
                    SizedBox(width: 10),
                    Text(
                      'اااااااàààلوالد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              );
            } else if (index == 1) {
              // First additional option
              return ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('الإعدادات'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              );
            } else if (index == 2) {
              // Second additional option
              return ListTile(
                leading: const Icon(Icons.accessibility_new_outlined),
                title: Text('طفل'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChildProfileScreen()),
                  );
                },
              );
            } else if (index == 3) {
              // Third additional option
              return ListTile(
                leading: const Icon(Icons.help),
                title: const Text('مساعدة'),
                onTap: () {
                  // Handle the tap event for the help option
                },
              );
            } else {
              // Handle other indices if needed
              return const SizedBox(); // Placeholder widget
            }
          },
          itemCount: 4,
        ),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('publications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final publications = snapshot.data!.docs;
            return ListView.builder(
              itemCount: publications.length,
              itemBuilder: (context, index) {
                final publication = publications[index];
                return ListTile(
                  title: Text(publication['title']),
                  subtitle: Text(publication['content']),
                  onTap: () {
                    // Add logic to navigate to publication details if necessary
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
