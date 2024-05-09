import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final int capacity;
  final int demands;
  final DateTime endDate;
  final String mosqueId;
  final DateTime startDate;

  Session({
    required this.capacity,
    required this.demands,
    required this.endDate,
    required this.mosqueId,
    required this.startDate,
  });

  factory Session.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Session(
      capacity: data['capacity'] ?? 0,
      demands: data['demands'] ?? 0,
      endDate: data['endDate'].toDate(),
      mosqueId: data['mosqueId'] ?? '',
      startDate: data['startDate'].toDate(),
    );
  }
}

class Mosque {
  final String id;
  final String name;
  final String description;
  final String address;

  Mosque({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
  });

  factory Mosque.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Mosque(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Stream<QuerySnapshot> getSessions() {
    return FirebaseFirestore.instance
        .collection('sessions')
        .where('mosqueId', isEqualTo: id)
        .snapshots();
  }
}

class ListMosques extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Mosquées'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Mosques').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return MosqueCard(
                mosque: Mosque.fromSnapshot(document),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class MosqueCard extends StatelessWidget {
  final Mosque mosque;

  MosqueCard({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          mosque.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mosque.description),
            SizedBox(height: 5),
            Text(
              'Sessions ouvertes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: mosque.getSessions(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Aucune session ouverte');
                }
                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.where((element) {
                    return true;
                    var doc = element.data() as Map;
                    var endDate = doc["endDate"] as Timestamp?;
                    if (endDate == null) return false;
                    var now = DateTime.now().isBefore(endDate.toDate());
                    return now;
                  }).map((DocumentSnapshot document) {
                    final session = Session.fromSnapshot(document);
                    return ListTile(
                      title: Text(
                          'Début: ${session.startDate}, Fin: ${session.endDate}'),
                      subtitle: Text(
                          'Capacité: ${session.capacity}, Demandes: ${session.demands}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MosqueDetails(mosque: mosque),
            ),
          );
        },
      ),
    );
  }
}

class MosqueDetails extends StatelessWidget {
  final Mosque mosque;

  MosqueDetails({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mosque.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              mosque.description,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10),
            Text(
              'Adresse:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              mosque.address,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormScreen()),
                );
              },
              child: Text('Ajouter une demande'),
            ),
          ],
        ),
      ),
    );
  }
}

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _niveauScolaireController = TextEditingController();

  // Initialize Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 155, 159, 208),
        title: const Text(
          "استمارة تسجيل",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'اللقب'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال اللقب ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'الاسم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال الاسم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'العمر'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العمر';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _niveauScolaireController,
                decoration: InputDecoration(labelText: 'المستوى الدراسي'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المستوى';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Store data in Firebase
                          _firestore.collection('demandes').add({
                            'nom': _nomController.text,
                            'prenom': _prenomController.text,
                            'age': int.parse(_ageController.text),
                            'niveauScolaire': _niveauScolaireController.text,
                          }).then((value) {
                            // Clear form fields after successful submission
                            _nomController.clear();
                            _prenomController.clear();
                            _ageController.clear();
                            _niveauScolaireController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم الإرسال بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ أثناء الإرسال'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                      },
                      child:
                          Text('إرسال', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 155, 159, 208),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Clear form fields
                        _nomController.clear();
                        _prenomController.clear();
                        _ageController.clear();
                        _niveauScolaireController.clear();
                      },
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                            color: Color.fromARGB(255, 155, 159, 208)),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
