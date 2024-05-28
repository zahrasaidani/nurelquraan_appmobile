import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstproject/imam/creationsession.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget représentant une carte de session
class SessionCard extends StatelessWidget {
  final DocumentSnapshot sessionSnapshot;

  SessionCard({required this.sessionSnapshot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Élévation de la carte pour un effet d'ombre
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Marge autour de la carte
      child: ListTile(
        // Contenu de la carte
        title: Text(
          sessionSnapshot['title'], // Titre de la session
          style: TextStyle(fontWeight: FontWeight.bold), // Style du titre en gras
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description: ${sessionSnapshot['description']}', // Description de la session
              style: TextStyle(color: Colors.grey), // Style de la description en gris
            ),
            SizedBox(height: 4), // Espacement entre la description et les autres informations
            Text(
              'Capacité: ${sessionSnapshot['capacity']}', // Capacité de la session
            ),
            SizedBox(height: 4), // Espacement entre la capacité et les autres informations
            Text(
              'Date de début: ${sessionSnapshot['startDate'].toDate().toString()}', // Date de début de la session
            ),
            SizedBox(height: 4), // Espacement entre la date de début et les autres informations
            Text(
              'Date de fin: ${sessionSnapshot['endDate'].toDate().toString()}', // Date de fin de la session
            ),
          ],
        ),
        // Lorsque l'utilisateur appuie sur la carte, navigue vers la page de demandes
        onTap: () {
         /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DemandPage(sessionSnapshot: sessionSnapshot),
            ),
          );*/
        },
      ),
    );
  }
}

// Widget représentant la page de confirmation affichant toutes les sessions disponibles
class AllSessionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessions du Mosequi'),
        automaticallyImplyLeading: false,
        // Définir la couleur de l'appBar en mauve
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('mosqueId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Filtrer par le mosquée actuellement connectée
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune session trouvée.'));
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
            MaterialPageRoute(builder: (context) => ConfirmationPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor:Color(0xFF9B9FD0), // Définir la couleur du bouton flottant en mauve
      ),
      // Définir la couleur de fond en mauve plus clair
    );
  }
}