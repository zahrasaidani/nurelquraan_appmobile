/*import 'package:firstproject/screens/detailmosquepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for the database
import 'package:flutter_map/flutter_map.dart'; // Import Flutter Map to display the map
import 'package:latlong2/latlong.dart'; // Import coordinate types

class ParentPage extends StatefulWidget {
  const ParentPage({Key? key}) : super(key: key);

  @override
  _ParentPageState createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  late List<DocumentSnapshot> _mosques =
      []; // List of documents from the "mosques" collection in Firestore

  @override
  void initState() {
    super.initState();
    _loadMosques(); // Load mosques on page initialization
  }

  // Function to load mosques from Firestore
  Future<void> _loadMosques() async {
    final dataQ = await FirebaseFirestore.instance.collection("mosques").get();
    setState(() {
      _mosques = dataQ.docs; // Update the list of mosques
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Page'), // Page title
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.509364, -0.128928), // Initial center of the map
          zoom: 9.2, // Initial zoom level of the map
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // URL for OpenStreetMap tiles
            userAgentPackageName: 'com.example.app', // User agent package name
          ),
          MarkerLayer(
            markers: [
              for (var mosque in _mosques)
                Marker(
                  point: LatLng(
                    (mosque.data()!['location'] as GeoPoint)
                        .latitude, // Mosque latitude
                    (mosque.data()!['location'] as GeoPoint)
                        .longitude, // Mosque longitude
                  ),
                  width: 80,
                  height: 80,
                  builder: (ctx) => Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Action when the user clicks on a marker
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MosqueDetailsPage(
                                name: mosque.data()!['name'], // Mosque name
                                description: mosque.data()![
                                    'description'], // Mosque description
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.location_on), // Location marker icon
                      ),
                      Text(
                        mosque.data()!['name'], // Display mosque name
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}*/
