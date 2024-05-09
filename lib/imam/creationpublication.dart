import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPublicationPage extends StatefulWidget {
  @override
  _AddPublicationPageState createState() => _AddPublicationPageState();
}

class _AddPublicationPageState extends State<AddPublicationPage> {
  final _contenuController = TextEditingController();

  @override
  void dispose() {
    _contenuController.dispose();
    super.dispose();
  }

  void _submitPublication() async {
    String contenu = _contenuController.text;

    // Récupérer l'utilisateur actuellement authentifié
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String mosequiId = user.uid;

      try {
        // Créer une nouvelle publication avec l'ID du mosequi authentifié
        await FirebaseFirestore.instance.collection('publications').add({
          'mosequiId': mosequiId,
          'contenu': contenu,
          'timestamp': FieldValue.serverTimestamp(), // Optionnel: pour garder une trace de l'heure de la publication
        });

        // Réinitialiser le formulaire après la soumission
        _contenuController.clear();
      } catch (e) {
        print('Erreur lors de l\'ajout de la publication: $e');
      }
    } else {
      print('Aucun utilisateur authentifié.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Publication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
  'Vous êtes connecté en tant que : ${FirebaseAuth.instance.currentUser?.phoneNumber ?? "Anonyme"}',
  style: TextStyle(fontSize: 16.0),
),

            SizedBox(height: 16.0),
            TextField(
              controller: _contenuController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Contenu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPublication,
              child: Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}