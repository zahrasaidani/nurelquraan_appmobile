import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstproject/imam/addsession.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllSessionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جلسات المسجد'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('mosqueId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('.لايوجد جلسات'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return SessionCard(sessionSnapshot: doc);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => addsessionPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF9B9FD0),
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final DocumentSnapshot sessionSnapshot;

  SessionCard({required this.sessionSnapshot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          sessionSnapshot['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الوصف: ${sessionSnapshot['description']}',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text(
                'تاريح الفتح: ${sessionSnapshot['startDate'].toDate().toString()}'),
            SizedBox(height: 4),
            Text(
                'تاريخ الاغلاق: ${sessionSnapshot['endDate'].toDate().toString()}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditSessionPage(sessionSnapshot: sessionSnapshot),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteSession(context, sessionSnapshot.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupsPage(sessionId: sessionSnapshot.id),
            ),
          );
        },
      ),
    );
  }

  void _deleteSession(BuildContext context, String sessionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session deleted successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting session: $error')));
    }
  }
}

class EditSessionPage extends StatefulWidget {
  final DocumentSnapshot sessionSnapshot;

  EditSessionPage({required this.sessionSnapshot});

  @override
  _EditSessionPageState createState() => _EditSessionPageState();
}

class _EditSessionPageState extends State<EditSessionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;

  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _startDate = widget.sessionSnapshot['startDate'].toDate();
    _endDate = widget.sessionSnapshot['endDate'].toDate();

    _title = widget.sessionSnapshot['title'];
    _description = widget.sessionSnapshot['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الجلسة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('تاريخ الفتح', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_startDate.toString(),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('تاريخ الاغلاق', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_endDate.toString(),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'عنوان',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'الرجاء إدخال عنوان الجلسة';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'وصف',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'الرجاء إدخال وصف الجلسة';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _updateSession();
                    }
                  },
                  child: const Text('تحديث الجلسة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _updateSession() async {
    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionSnapshot.id)
          .update({
        'title': _title,
        'description': _description,
        'startDate': _startDate,
        'endDate': _endDate,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session updated successfully')));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating session: $error')));
    }
  }
}

class GroupsPage extends StatelessWidget {
  final String sessionId;

  GroupsPage({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groupes de la session'),
      ),
      body: FutureBuilder<List<Group>>(
        future: getGroupsFromFirestore(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            List<Group> groups = snapshot.data ?? [];
            if (groups.isEmpty) {
              return Center(child: Text('Pas de groupes pour cette session'));
            } else {
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(groups[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RequestsPage(groupId: groups[index].id),
                        ),
                      );
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<List<Group>> getGroupsFromFirestore(String sessionId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .collection('groups')
        .get();
    return querySnapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
  }
}

class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}

class RequestsPage extends StatelessWidget {
  final String groupId;

  RequestsPage({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demandes pour le groupe'),
      ),
      body: FutureBuilder<List<Request>>(
        future: getRequestsFromFirestore(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            List<Request> requests = snapshot.data ?? [];
            if (requests.isEmpty) {
              return Center(child: Text('Pas de demandes pour ce groupe'));
            } else {
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        '${requests[index].firstname} ${requests[index].lastname}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Niveau scolaire: ${requests[index].schoolLevel}'),
                        Text('Parent UID: ${requests[index].parentUid}'),
                        Text('Session ID: ${requests[index].sessionId}'),
                        Text('État: ${requests[index].state}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => acceptRequest(requests[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => rejectRequest(requests[index]),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<List<Request>> getRequestsFromFirestore(String groupId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('demands')
        .where('groupId', isEqualTo: groupId)
        .get();
    return querySnapshot.docs.map((doc) => Request.fromFirestore(doc)).toList();
  }
}

class Request {
  final String demandId;
  final String firstname;
  final String lastname;
  final String groupId;
  final String parentUid;
  final String schoolLevel;
  final String sessionId;
  final String state;

  Request({
    required this.demandId,
    required this.firstname,
    required this.lastname,
    required this.groupId,
    required this.parentUid,
    required this.schoolLevel,
    required this.sessionId,
    required this.state,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Request(
      demandId: data['demandId'] ?? '',
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      groupId: data['groupId'] ?? '',
      parentUid: data['parentUid'] ?? '',
      schoolLevel: data['schoolLevel'] ?? '',
      sessionId: data['sessionId'] ?? '',
      state: data['state'] ?? '',
    );
  }
}

void acceptRequest(Request request) async {
  await FirebaseFirestore.instance
      .collection('demands')
      .doc(request.demandId)
      .update({'state': 'accept'});
}

void rejectRequest(Request request) async {
  await FirebaseFirestore.instance
      .collection('demands')
      .doc(request.demandId)
      .update({'state': 'refuse'});
}

