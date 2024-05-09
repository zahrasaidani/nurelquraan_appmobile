/*import 'package:firstproject/screens/detailmosquepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importation de Firestore pour la base de données
import 'package:flutter_map/flutter_map.dart'; // Importation de Flutter Map pour afficher la carte
import 'package:latlong2/latlong.dart'; // Importation des types de coordonnées
import 'package:firstproject/imam/mappageimam.dart';
class ParentPage extends StatefulWidget {
  const ParentPage({Key? key}) : super(key: key);

  @override
  _ParentPageState createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  late List<DocumentSnapshot> _mosques = []; // Liste des documents de la collection "mosques" dans Firestore

  @override
  void initState() {
    super.initState();
    _loadMosques(); // Chargement des mosquées au démarrage de la page
  }

  // Fonction pour charger les mosquées depuis Firestore
  Future<void> _loadMosques() async {
    final dataQ = await FirebaseFirestore.instance.collection("mosques").get();
    setState(() {
      _mosques = dataQ.docs; // Mise à jour de la liste des mosquées
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Page'), // Titre de la page
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(51.509364, -0.128928), // Centre initial de la carte
          initialZoom: 9.2, // Zoom initial de la carte
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // URL du fond de carte OpenStreetMap
            userAgentPackageName: 'com.example.app', // Nom du package utilisateur
          ),
          MarkerLayer(
            markers: [
              for (var mosque in _mosques)
                Marker(
                  point: LatLng(
                    (mosque.data()!['location'] as GeoPoint).latitude, // Latitude de la mosquée
                    (mosque.data()!['location'] as GeoPoint).longitude, // Longitude de la mosquée
                  ),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    onPressed: () {
                      // Action à effectuer lorsque l'utilisateur clique sur un marqueur
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MosqueDetailsPage(
                            name: mosque.data()!['name'], // Nom de la mosquée
                            description: mosque.data()!['description'], // Description de la mosquée
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.location_on), // Icône de marqueur de localisation
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}*/
