// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text('User not logged in'),
      );
    }
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('demands')
              .where('parentUid', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No demands found'),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                String state = data['state'];
                String message = ''; // Provide an initial value
                Widget? actionButton;

                if (state == 'accept') {
                  message = 'La demande est acceptée';
                  actionButton = ElevatedButton(
                    onPressed: () {
                      // Action à effectuer lors du clic sur le bouton
                      _confirmRegistration(context, data, doc.reference);
                    },
                    child: Text('Fermer'),
                  );
                } else if (state == 'refuse') {
                  message = 'La demande est refusée';
                } else if (state == 'pending') {
                  message = 'Demande en attente';
                } else {
                  // Handle the case where state is not one of the expected values
                  // Assign a default message or handle it according to your requirements
                  message = 'Unknown state';
                }

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(data['firstname'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(
                          'Demande : $state',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(message),
                      ],
                    ),
                    trailing: actionButton,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmRegistration(BuildContext context,
      Map<String, dynamic> data, DocumentReference demandRef) async {
    final String firstname = data['firstname'];
    final String parentUid = data['parentUid'];

    // Vérifier si l'enfant est déjà inscrit
    final QuerySnapshot childSnapshot = await FirebaseFirestore.instance
        .collection('enfants')
        .where('firstname', isEqualTo: firstname)
        .where('parentUid', isEqualTo: parentUid)
        .get();

    if (childSnapshot.docs.isNotEmpty) {
      // Afficher une alerte si l'enfant est déjà inscrit
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enfant déjà inscrit'),
            content: Text('L\'enfant est déjà inscrit.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Afficher une alerte de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text(
                'Êtes-vous sûr de vouloir valider l\'inscription de votre enfant ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Fermer la boîte de dialogue de confirmation
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context)
                      .pop(); // Fermer la boîte de dialogue de confirmation
                  await _registerChild(data,
                      demandRef); // Enregistrer l'enfant et mettre à jour l'état de la demande
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Enregistrement réussi !'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('Valider'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _registerChild(
      Map<String, dynamic> data, DocumentReference demandRef) async {
    final String firstname = data['firstname'];
    final String parentUid = data['parentUid'];

    // Enregistrer les informations de l'enfant dans la collection enfant
    await FirebaseFirestore.instance.collection('enfants').add({
      'lastname': data['lastname'],
      'firstname': data['firstname'],
      'parentUid': data['parentUid'],
      'school level': data['school level'],
      'age': data['age'],
      'groupId': data['groupId'],
      'sessionId': data['sessionId'],
    });

    // Mettre à jour l'état de la demande à "valide"
    await demandRef.update({'state': 'valide'});
  }
}
