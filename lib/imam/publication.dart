import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MosequiPublicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publications du Mosequi'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('publications')
            .where('mosequiId',
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
            return Center(child: Text('Aucune publication trouvée.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Timestamp timestamp = doc['timestamp'];
              DateTime dateTime = timestamp.toDate();
              String time = DateFormat('HH:mm').format(dateTime);

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(doc['contenu']),
                  subtitle: Text('Publié à $time'),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPublicationPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor:
            Color(0xFF9B9FD0), // Définir la couleur du bouton flottant en mauve
      ),
    );
  }
}

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

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String mosequiId = user.uid;

      try {
        await FirebaseFirestore.instance.collection('publications').add({
          'mosequiId': mosequiId,
          'contenu': contenu,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _contenuController.clear();
        Navigator.pop(context);
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
