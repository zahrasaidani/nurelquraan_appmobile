import 'package:firstproject/imam/creationsession.dart';
import 'package:flutter/material.dart';


class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Sessions'),
        automaticallyImplyLeading: false, // Ne pas afficher le bouton de retour
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConfirmationPage(),
            ),
          );
          // Ajoutez ici la logique pour créer une nouvelle session
          // Vous pouvez naviguer vers une autre page ou afficher un dialogue pour saisir les détails de la session
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Demandes de la session en cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  // Affichez ici la liste des demandes de la session en cours
                  // Vous pouvez utiliser des éléments de liste pour afficher chaque demande
                  // Exemple : ListTile, Card, etc.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
