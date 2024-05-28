import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Enseignant {
  final String idEnseignant;

  final String nom;
  final String prenom;
  final String mosequiId;

  Enseignant({required this.idEnseignant, required this.nom, required this.prenom, required this.mosequiId});
}

class EnseignantsMosequiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اساتذة المسجد'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('enseignants')
            .where('mosequiId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(child: Text('.لايوجد اي استاذ'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Enseignant enseignant = Enseignant(
                idEnseignant: doc.id,
                nom: doc['nom'],
                prenom: doc['prenom'],
                mosequiId: doc['mosequiId'],
              );

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    '${enseignant.nom} ${enseignant.prenom}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        // Supprimer l'enseignant de Firestore en utilisant son ID de document
                        await FirebaseFirestore.instance.collection('enseignants').doc(enseignant.idEnseignant).delete();
                      } catch (e) {
                        // Gérer les erreurs éventuelles
                        print(':خطا في حذف لاستاذ $e');
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers l'écran de création d'enseignant
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEnseignantPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateEnseignantPage extends StatelessWidget {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اضف استاذ'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(labelText: 'لقب'),
            ),
            TextField(
              controller: prenomController,
              decoration: InputDecoration(labelText: 'الاسم'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Générer un ID unique pour l'enseignant
                String idEnseignant = FirebaseFirestore.instance.collection('enseignants').doc().id;

                // Créer et enregistrer l'enseignant dans Firestore
                String nom = nomController.text;
                String prenom = prenomController.text;
                String mosequiId = FirebaseAuth.instance.currentUser?.uid ?? '';
                Enseignant enseignant = Enseignant(idEnseignant: idEnseignant, nom: nom, prenom: prenom, mosequiId: mosequiId);

                FirebaseFirestore.instance.collection('enseignants').doc(idEnseignant).set({
                  'idEnseignant': idEnseignant,
                  'nom': enseignant.nom,
                  'prenom': enseignant.prenom,
                  'mosequiId': enseignant.mosequiId,
                });

                // Retour à l'écran précédent
                Navigator.pop(context);
              },
              child: Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}