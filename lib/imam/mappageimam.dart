import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlng_picker/latlng_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:firstproject/imam/myhomescreenimam.dart'; // Import MyHomeScreenImam

class ImamPage extends StatefulWidget {
  const ImamPage({
    Key? key,
    required this.description,
    required this.mosqueName,
    required this.phoneNumber,
    required this.user,
  }) : super(key: key);

  final String description;
  final String mosqueName;
  final String phoneNumber;
  final User user;

  @override
  _ImamPageState createState() => _ImamPageState();
}

class _ImamPageState extends State<ImamPage> {
  late LatLng _selectedLocation = LatLng(36.4843, 2.8229);
  late String _mosqueName = '';
  late String _mosqueDescription = '';

  @override
  void initState() {
    super.initState();
    _mosqueName = widget.mosqueName;
    _mosqueDescription = widget.description;
  }

  Future<void> _saveMosque() async {
    if (_mosqueName.isNotEmpty && _mosqueDescription.isNotEmpty) {
      await FirebaseFirestore.instance.collection("mosques").add({
        "name": _mosqueName,
        "description": _mosqueDescription,
        "location":
            GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mosque added successfully'),
        ),
      );

      // Naviguer vers MyHomeScreenImam après l'enregistrement réussi
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomeScreenImam()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
    }
  }

  Future<void> _selectLocation() async {
    final latLng = await showLatLngPickerDialog(context: context);
    if (latLng != null && latLng.isNotEmpty) {
      setState(() {
        _selectedLocation = latLng.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imam Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            TextFormField(
              initialValue: _mosqueName,
              enabled: false,
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: _mosqueDescription,
              enabled: false,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectLocation,
              child: Text('Select Location'),
            ),
            SizedBox(height: 16),
            Text('Selected Location: $_selectedLocation'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveMosque,
              child: Text('Save Mosque'),
            ),
          ],
        ),
      ),
    );
  }
}
