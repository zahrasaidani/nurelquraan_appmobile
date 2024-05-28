import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstproject/imam/editprofil.dart';
import 'package:firstproject/imam/registerationformimam.dart';
import 'package:flutter/material.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled =
      true; // Déclaration unique pour _notificationsEnabled

  String _selectedLanguage = 'العربية'; // Langue par défaut
  String _parentFullName = ''; // Nom complet du parent

  @override
  void initState() {
    super.initState();
    _fetchParentFullName();
  }

  Future<void> _fetchParentFullName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            // Utilisation de la méthode .get() pour obtenir la donnée de type Map<String, dynamic>
            Map<String, dynamic> data =
                documentSnapshot.data() as Map<String, dynamic>;
            _parentFullName = data['fullName'] ?? '';
          });
        } else {
          print('User does not exist');
        }
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegistrationFormImam()),
      );
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('تعديل الملف الشخصي'),
            onTap: () async {
             await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditUserInfoPage()),
              );
              await _fetchParentFullName();
              setState(() {});
            },
          ),
          SwitchListTile(
            title: Text('تفعيل الإشعارات '),
            value: true, // La valeur actuelle de l'option de notification
            onChanged: (bool value) {
              // Mettre à jour la valeur de l'option de notification
            },
            secondary: Icon(Icons.notifications_active),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Langue'),
            onTap: () {
              // Naviguer vers la page de sélection de la langue
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('تسجيل الخروج'),
            onTap: _handleLogout,
          ),
      /* ListTile(
  leading: Icon(Icons.report_problem), // Icône "exit_to_app" en rouge
  title: Text('ابلاغ عن مشكل'), // Titre du ListTile
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProblemReportPage()), // Redirige vers la page de signalement de problème
    );
  },
)*/

          
          
        ],
      ),
    );
  }
}
