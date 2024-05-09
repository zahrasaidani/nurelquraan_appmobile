import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  @override
  _EditProfilScreenState createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'الاسم'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Enregistrer les modifications du profil ici
                // Vous pouvez utiliser les valeurs des contrôleurs (_nameController.text, _emailController.text, etc.) pour sauvegarder les nouvelles informations du profil
                // Une fois que les modifications sont enregistrées, vous pouvez afficher un message de succès ou naviguer vers une autre page
              },
              child: Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs lorsque le widget est supprimé
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}