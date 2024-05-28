import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChildProfileScreen extends StatelessWidget {
  static const String routeName = '/childProfile';
  final Map<String, dynamic> childData;

  ChildProfileScreen({required this.childData});

  Future<String> fetchGroupName(String sessionId, String groupId) async {
    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .collection('groups')
          .doc(groupId)
          .get();

      if (groupDoc.exists) {
        return groupDoc['name'];
      } else {
        return 'Group not found';
      }
    } catch (e) {
      print('Error fetching group name: $e');
      return 'Error fetching group name';
    }
  }

  Future<String> fetchMosqueName(String sessionId) async {
    try {
      DocumentSnapshot sessionDoc = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .get();

      if (sessionDoc.exists) {
        String mosqueId = sessionDoc['mosqueId'];
        DocumentSnapshot mosqueDoc = await FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueId)
            .get();

        if (mosqueDoc.exists) {
          return mosqueDoc['name'];
        } else {
          return 'Mosque not found';
        }
      } else {
        return 'Session not found';
      }
    } catch (e) {
      print('Error fetching mosque name: $e');
      return 'Error fetching mosque name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9B9FD0),
        title: Text('الملف الشخصي للطفل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: childData['photoUrl'] != null
                    ? NetworkImage(childData['photoUrl'])
                    : null,
                child: childData['photoUrl'] == null
                    ? Icon(Icons.person, size: 60)
                    : null, // Icon if no photo is available
              ),
              SizedBox(height: 20),
              Text(
                childData['firstname'] ?? 'الملف الشخصي للطفل',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '${childData['lastname'] ?? 'N/A'}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age: ${childData['age'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'School Level: ${childData['school level'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: fetchGroupName(childData['sessionId'], childData['groupId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              'Group: ${snapshot.data}',
                              style: TextStyle(fontSize: 20),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: fetchMosqueName(childData['sessionId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              'Mosque: ${snapshot.data}',
                              style: TextStyle(fontSize: 20),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
