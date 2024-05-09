import 'package:firstproject/imam/myhomescreenimam.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreenImam extends StatefulWidget {
  const SettingsScreenImam({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreenImam> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'العربية'; // Langue par défaut
  String mosqueName = ''; // Nom de la mosquée

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Récupérer l'utilisateur actuellement connecté
      User? user = FirebaseAuth.instance.currentUser;

      // Vérifier si l'utilisateur est connecté
      if (user != null) {
        // Récupérer les données de l'utilisateur depuis Firestore
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Mosques')
            .doc(user.uid)
            .get();

        // Vérifier si les données existent dans Firestore
        if (userData.exists) {
          // Récupérer le nom de la mosquée associé à l'utilisateur
          setState(() {
            mosqueName = userData['name'] ??
                ''; // Utiliser le nom de la mosquée ou une chaîne vide si non trouvé
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_circle, size: 50), // Icone d'homme
            SizedBox(width: 10), // Espacement entre l'icône et le texte
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            title: const Text('تفعيل الإشعارات '),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('اللغة'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: <String>['العربية', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('تسجيل الخروج'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomeScreenImam()),
              );
            },
          ),
        ],
      ),
    );
  }
}
