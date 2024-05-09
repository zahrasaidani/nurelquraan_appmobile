import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: 10, // Nombre de notifications
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF9B9FD0), // Couleur de l'avatar
              child: Icon(
                Icons.notifications, // Icône de la notification
                color: Colors.white, // Couleur de l'icône
              ),
            ),
            title: Text('Notification $index'), // Titre de la notification
            subtitle: Text(
                'Description de la notification $index'), // Description de la notification
            onTap: () {
              // Action à effectuer lors du clic sur une notification
              // Par exemple, ouvrir une autre page ou afficher plus d'informations sur la notification
            },
          );
        },
      ),
    );
  }
}