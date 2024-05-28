import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modifier le Nom de Profil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> updateProfileName(String newName) async {
    // Ici, vous pouvez ajouter votre logique pour communiquer avec le backend et mettre à jour le nom de profil
    var response = await http.post(
      Uri.parse('https://your-backend-url.com/update-profile-name'),
      body: {'newName': newName},
    );

    if (response.statusCode == 200) {
      // Mise à jour réussie
      print('Le nom de profil a été mis à jour');
    } else {
      // Échec de la mise à jour
      print('Échec de la mise à jour du nom de profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le Nom de Profil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nouveau nom de profil',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateProfileName(_nameController.text);
              },
              child: Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }
}